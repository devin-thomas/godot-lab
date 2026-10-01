import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { cappy } from "./cappy-cli.mjs";
import { root } from "./cappy-setup.mjs";

const scenario = process.argv[2] || "motion";
assert.ok(["motion", "physics", "navigation", "materials", "audio", "persistence"].includes(scenario), "Choose a registered lab id");
const localObs = JSON.parse(await readFile(path.join(root, ".local/obs/config/obs-studio/plugin_config/obs-websocket/config.json"), "utf8"));
process.env.GODOT_LAB_OBS_PASSWORD = localObs.server_password;
await mkdir(path.join(root, ".artifacts"), { recursive: true });
const result = await cappy(["run", scenario], "cappy.capture.local.json");
assert.equal(result.state, "succeeded", "A capture must finish with verified artifacts");
const manifest = JSON.parse(await readFile(path.join(root, ".cappy", result.manifest), "utf8"));
const master = manifest.artifacts.find(artifact => artifact.role === "master");
assert.ok(master, "Capture must have an OBS master");
const masterFile = path.join(root, ".cappy", master.path);
async function ffmpeg(args) {
  return new Promise((resolve, reject) => {
    const child = spawn(process.env.FFMPEG_BIN || "ffmpeg", ["-v", "error", "-threads", "2", "-filter_threads", "2", ...args], { stdio: ["ignore", "pipe", "pipe"], windowsHide: true });
    const chunks = [];
    let stderr = "";
    child.stdout.on("data", chunk => chunks.push(chunk));
    child.stderr.on("data", chunk => { stderr += chunk; });
    child.once("error", reject);
    child.once("close", code => code === 0 ? resolve(Buffer.concat(chunks)) : reject(new Error(`FFmpeg verification failed (${code}): ${stderr}`)));
  });
}
const pixels = await ffmpeg(["-i", masterFile, "-vf", "fps=1,scale=64:36", "-pix_fmt", "rgb24", "-f", "rawvideo", "-threads", "2", "pipe:1"]);
assert.ok(pixels.length > 0, "Capture has no decodable frames");
const min = pixels.reduce((value, pixel) => Math.min(value, pixel), 255);
const max = pixels.reduce((value, pixel) => Math.max(value, pixel), 0);
assert.ok(max - min > 24 && max > 50, "OBS captured black or flat frames; game pixels were not verified");
await ffmpeg(["-ss", String(master.durationMs / 2000), "-i", masterFile, "-frames:v", "1", "-threads", "2", "-y", path.join(root, `.artifacts/capture-${scenario}-frame.png`)]);
result.pixelCheck = { minimumChannel: min, maximumChannel: max, sampledFrames: pixels.length / (64 * 36 * 3), threads: 2 };
await writeFile(path.join(root, `.artifacts/capture-${scenario}.json`), `${JSON.stringify(result, null, 2)}\n`);
console.log(JSON.stringify({ captureId: result.captureId, state: result.state, scenario, manifest: result.manifest, master: { durationMs: master.durationMs, bytes: master.bytes, sha256: master.sha256 }, proof: result.events.find(event => event.type === "LAB_PROOF")?.payload, pixelCheck: result.pixelCheck }, null, 2));
