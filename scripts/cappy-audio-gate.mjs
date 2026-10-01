import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { root } from "./cappy-setup.mjs";

const capture = JSON.parse(await readFile(path.join(root, ".artifacts/capture-audio.json"), "utf8"));
const master = capture.artifacts.find(artifact => artifact.role === "master");
assert.ok(master, "Audio proof requires the real OBS master");
const wavFile = path.join(root, ".artifacts/capture-audio.wav");
await new Promise((resolve, reject) => {
  const child = spawn(process.env.FFMPEG_BIN || "ffmpeg", ["-v", "error", "-threads", "2", "-filter_threads", "2", "-i", path.join(root, ".cappy", master.path), "-map", "0:a:0", "-ac", "2", "-ar", "24000", "-c:a", "pcm_s16le", "-threads", "2", "-y", wavFile], { stdio: ["ignore", "ignore", "pipe"], windowsHide: true });
  let stderr = "";
  child.stderr.on("data", chunk => { stderr += chunk; });
  child.once("error", reject);
  child.once("close", code => code === 0 ? resolve() : reject(new Error(`FFmpeg PCM extraction failed (${code}): ${stderr}`)));
});
const wav = await readFile(wavFile);
assert.equal(wav.toString("ascii", 0, 4), "RIFF");
let dataOffset = 0;
let dataLength = 0;
let sampleRate = 0;
for (let offset = 12; offset + 8 <= wav.length;) {
  const chunk = wav.toString("ascii", offset, offset + 4);
  const length = wav.readUInt32LE(offset + 4);
  if (chunk === "fmt ") {
    assert.equal(wav.readUInt16LE(offset + 8), 1, "WAV must use PCM");
    assert.equal(wav.readUInt16LE(offset + 10), 2, "WAV must have stereo channels");
    sampleRate = wav.readUInt32LE(offset + 12);
    assert.equal(wav.readUInt16LE(offset + 22), 16);
  }
  if (chunk === "data") { dataOffset = offset + 8; dataLength = length; break; }
  offset += 8 + length + (length % 2);
}
assert.ok(dataOffset > 0 && sampleRate > 0, "WAV lacks format or PCM data");
const phases = capture.timeline.filter(event => event.type === "AUDIO_PHASE");
assert.equal(phases.length, 4, "The captured timeline must mark near, far, left and right phases");
const completed = capture.timeline.find(event => event.type === "LAB_PROOF");
const observations = {};
for (let index = 0; index < phases.length; index++) {
  const phase = phases[index];
  const phaseEnd = phases[index + 1]?.t ?? completed.t;
  const start = Math.ceil((phase.t + 400) * sampleRate / 1000);
  const end = Math.min(Math.floor((phaseEnd - 250) * sampleRate / 1000), dataLength / 4);
  assert.ok(end - start > sampleRate / 2, `Phase ${phase.payload.phase} must provide at least half a second of PCM`);
  let leftEnergy = 0;
  let rightEnergy = 0;
  let crossings = 0;
  let previous = 0;
  for (let frame = start; frame < end; frame++) {
    const left = wav.readInt16LE(dataOffset + frame * 4) / 32768;
    const right = wav.readInt16LE(dataOffset + frame * 4 + 2) / 32768;
    leftEnergy += left * left;
    rightEnergy += right * right;
    const mono = left + right;
    if (frame > start && (mono >= 0) !== (previous >= 0)) crossings++;
    previous = mono;
  }
  observations[phase.payload.phase] = { leftRms: Math.sqrt(leftEnergy / (end - start)), rightRms: Math.sqrt(rightEnergy / (end - start)), zeroCrossingEstimateHz: crossings * sampleRate / (2 * (end - start)), durationMs: (end - start) * 1000 / sampleRate };
}
const energy = phase => Math.hypot(phase.leftRms, phase.rightRms);
// Spectral energy identifies the tone despite AAC ringing and brief capture gaps,
// which can bias an all-window zero-crossing count. Analyze one second of PCM.
const nearStart = Math.ceil((phases[0].t + 400) * sampleRate / 1000);
const nearEnd = Math.floor((phases[1].t - 250) * sampleRate / 1000);
const windowLength = Math.min(sampleRate, nearEnd - nearStart);
const windowStart = Math.floor((nearStart + nearEnd - windowLength) / 2);
let spectralPeak = { frequencyHz: 0, energy: 0 };
for (let frequencyHz = 100; frequencyHz <= 500; frequencyHz++) {
  const coefficient = 2 * Math.cos(2 * Math.PI * frequencyHz / sampleRate);
  let previous = 0;
  let previousPrevious = 0;
  for (let index = 0; index < windowLength; index++) {
    const frame = windowStart + index;
    const sample = (wav.readInt16LE(dataOffset + frame * 4) + wav.readInt16LE(dataOffset + frame * 4 + 2)) / 65536;
    const value = sample + coefficient * previous - previousPrevious;
    previousPrevious = previous;
    previous = value;
  }
  const magnitude = previous * previous + previousPrevious * previousPrevious - coefficient * previous * previousPrevious;
  if (magnitude > spectralPeak.energy) spectralPeak = { frequencyHz, energy: magnitude };
}
observations.near.dominantFrequencyHz = spectralPeak.frequencyHz;
const gates = {
  nonSilent: energy(observations.near) > 0.002,
  distanceAttenuation: energy(observations.near) > energy(observations.far) * 1.3,
  stereoPanSwap: (observations.left.leftRms - observations.left.rightRms) * (observations.right.leftRms - observations.right.rightRms) < 0,
  authoredTone: spectralPeak.frequencyHz >= 215 && spectralPeak.frequencyHz <= 225
};
const report = { generatedAt: new Date().toISOString(), passed: Object.values(gates).every(Boolean), captureId: capture.captureId, source: "OBS game-process-only audio", sampleRate, gates, observations, ffmpegThreads: 2 };
await writeFile(path.join(root, ".artifacts/cappy-audio-gate.json"), `${JSON.stringify(report, null, 2)}\n`);
console.log(JSON.stringify(report, null, 2));
assert.equal(report.passed, true, `Real audio capture failed: ${Object.keys(gates).filter(gate => !gates[gate]).join(", ")}`);
