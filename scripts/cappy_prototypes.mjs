import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { createHash, randomBytes } from "node:crypto";
import { appendFileSync } from "node:fs";
import { mkdir, readFile, stat, statfs, writeFile } from "node:fs/promises";
import net from "node:net";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { connectObs } from "./cappy-obs-client.mjs";
import { root, setup } from "./cappy-setup.mjs";

const script = fileURLToPath(import.meta.url);
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
const sha = bytes => createHash("sha256").update(bytes).digest("hex");
const MAX_BYTES = 128 * 1024 * 1024;

export function parseOptions(args) {
  let mode = "capture", help = false;
  const seen = new Set();
  for (const argument of args) {
    if (argument === "--help" || argument === "-h") { help = true; continue; }
    if (!["--discovery-only", "--probe-only"].includes(argument)) throw new Error("Unknown option; use --help");
    if (seen.has(argument)) throw new Error("Repeated mode option; use --help");
    seen.add(argument);
    if (mode !== "capture") throw new Error("Choose either --discovery-only or --probe-only");
    mode = argument === "--discovery-only" ? "discovery" : "probe";
  }
  return { mode, help };
}

function helpText() {
  return [
    "Usage: node scripts/cappy_prototypes.mjs [--discovery-only | --probe-only]",
    "       node scripts/cappy_prototypes.mjs --help",
    "",
    "Default: official Cappy discovery, 4-second freeform recording, then real OBS",
    "captures of lab-013 and lab-007 with same-process HTTP and decoded-frame proof.",
    "",
    "  --discovery-only  Discovery and replayable freeform session; no OBS recording.",
    "  --probe-only      Launch LAB-013 and save the owned OBS source screenshot;",
    "                    no recording. Inspect it before the first capture.",
    "  --help, -h        Show this help without setup, launches, or artifact writes.",
    "",
    "Requires installed Node 24+, official Cappy, Godot, and FFmpeg. Capture/probe",
    "also require the existing project-owned portable OBS instance on port 4467",
    "and its active Godot Lab scene. This harness never changes OBS settings.",
    "Generated configuration, credentials, sessions, and evidence stay local and",
    "ignored. Each operation is bounded; selected captures are under 30 seconds."
  ].join("\n");
}

export function ownedScene(scene, items, inputs) {
  assert.equal(scene, "Godot Lab", "Owned scene must already be active; no switching");
  assert.deepEqual(items.map(item => item.sourceName).sort(), ["Godot Lab Game Audio", "Godot Lab Game Window"].sort(), "Refuse unrelated scene sources");
  assert.ok(items.every(item => item.sceneItemEnabled));
  assert.equal(inputs.window.inputKind, "window_capture");
  assert.equal(inputs.window.inputSettings.method, 2, "Require window capture without display fallback");
  assert.equal(inputs.window.inputSettings.priority, 0);
  assert.equal(inputs.window.inputSettings.client_area, true);
  assert.ok(inputs.window.inputSettings.window.includes("Godot Lab | Signal Observatory"));
  assert.equal(inputs.audio.inputKind, "wasapi_process_output_capture");
  assert.equal(inputs.audio.inputSettings.window, inputs.window.inputSettings.window);
  return { scene, sourceKinds: [inputs.window.inputKind, inputs.audio.inputKind], windowOnly: true, displayFallback: false };
}

export function bundlePath(relative) {
  assert.equal(typeof relative, "string");
  assert.ok(relative && !path.isAbsolute(relative) && !relative.includes("\\") && !relative.includes(":"));
  assert.ok(relative.split("/").every(part => part && part !== "." && part !== ".."));
  const base = path.join(root, ".cappy");
  const resolved = path.resolve(base, relative);
  assert.ok(resolved.startsWith(base + path.sep));
  return resolved;
}

export function validateCapture(result, manifest, scenario) {
  assert.equal(result.state, "succeeded");
  assert.equal(manifest.status, "succeeded");
  assert.equal(manifest.identity.captureId, result.captureId);
  assert.equal(manifest.identity.source.scenarioId, scenario.toLowerCase());
  assert.equal(manifest.build.cappyVersion, "0.1.0");
  const master = manifest.artifacts.find(artifact => artifact.role === "master");
  assert.ok(master && master.bytes > 0 && master.bytes <= MAX_BYTES);
  assert.match(master.sha256, /^[a-f0-9]{64}$/);
  assert.equal(master.source.tool, "obs");
  assert.ok(master.durationMs > 0 && master.durationMs <= 31000);
  assert.equal(master.width, 1280);
  assert.equal(master.height, 720);
  const proof = result.events.find(event => event.type === "LAB_PROOF");
  assert.ok(proof?.payload?.passed, "Scenario must emit successful LAB_PROOF");
  assert.equal(proof.payload.lab, scenario);
  return { master, proof: proof.payload };
}

async function command(binary, args, maxBytes = 8 * 1024 * 1024) {
  return await new Promise((resolve, reject) => {
    const child = spawn(binary, args, { cwd: root, stdio: ["ignore", "pipe", "pipe"], windowsHide: true });
    const chunks = [];
    let bytes = 0;
    let stderr = "";
    const timer = setTimeout(() => { child.kill(); reject(new Error("TOOL_TIMEOUT")); }, 15000);
    child.stdout.on("data", chunk => {
      bytes += chunk.length;
      if (bytes > maxBytes) { child.kill(); reject(new Error("TOOL_OUTPUT_BUDGET")); } else chunks.push(chunk);
    });
    child.stderr.on("data", chunk => { stderr = (stderr + chunk.toString()).slice(-8192); });
    child.once("error", error => { clearTimeout(timer); reject(error); });
    child.once("close", code => { clearTimeout(timer); code === 0 ? resolve(Buffer.concat(chunks)) : reject(new Error("TOOL_FAILED_" + code + ": " + stderr)); });
  });
}

async function fingerprint() {
  const files = (await command("git", ["ls-files", "--cached", "--others", "--exclude-standard", "game"])).toString().trim().split(/\r?\n/).filter(Boolean).filter(file => !file.endsWith(".uid")).sort();
  const hash = createHash("sha256");
  for (const file of files) { hash.update(file + "\0"); hash.update(Buffer.from(sha(await readFile(path.join(root, file))), "hex")); }
  return { commit: (await command("git", ["rev-parse", "HEAD"])).toString().trim(), treeHash: hash.digest("hex"), dirty: (await command("git", ["status", "--porcelain", "--", "game"])).length > 0, inputFiles: files.length };
}

async function freePort() {
  const server = net.createServer();
  await new Promise((resolve, reject) => { server.once("error", reject); server.listen(0, "127.0.0.1", resolve); });
  const port = server.address().port;
  await new Promise(resolve => server.close(resolve));
  return port;
}

async function live(url, token, route, request) {
  const response = await fetch(url + route, { method: request ? "POST" : "GET", headers: { Authorization: "Bearer " + token, ...(request ? { "Content-Type": "application/json" } : {}) }, ...(request ? { body: JSON.stringify(request) } : {}), signal: AbortSignal.timeout(1000) });
  const result = await response.json();
  assert.equal(typeof result.ok, "boolean");
  return result;
}

async function packageIdentity() {
  const base = path.join(root, "node_modules/@uppercut-labs/cappy");
  const pkg = JSON.parse(await readFile(path.join(base, "package.json"), "utf8"));
  assert.equal(pkg.version, "0.1.0");
  const vendor = {};
  for (const file of ["cappy_adapter.gd", "cappy_operation.gd", "plugin.cfg", "plugin.gd"]) {
    const released = await readFile(path.join(base, "addons/cappy", file));
    const installed = await readFile(path.join(root, "game/addons/cappy", file));
    assert.deepEqual(installed, released, "Released adapter bytes differ: " + file);
    vendor[file] = sha(installed);
  }
  return { version: pkg.version, cliHash: sha(await readFile(path.join(base, "dist/cappy.js"))), vendor };
}

async function inspectProvider() {
  assert.equal(process.platform, "win32");
  const instance = JSON.parse(await readFile(path.join(root, ".artifacts/obs-instance.json"), "utf8"));
  const binary = path.join(root, ".local/obs/bin/64bit/obs64.exe");
  assert.equal(path.resolve(instance.binary), binary);
  assert.equal(instance.port, 4467);
  assert.ok(Number.isSafeInteger(instance.pid) && instance.pid > 0);
  const actual = (await command("powershell.exe", ["-NoProfile", "-Command", "(Get-Process -Id " + instance.pid + " -ErrorAction Stop).Path"])).toString().trim();
  assert.equal(path.resolve(actual), binary, "Owned OBS process identity changed");
  const auth = JSON.parse(await readFile(path.join(root, ".local/obs/config/obs-studio/plugin_config/obs-websocket/config.json"), "utf8"));
  assert.equal(auth.server_port, 4467);
  assert.equal(auth.auth_required, true);
  assert.ok(typeof auth.server_password === "string" && auth.server_password);
  const obs = await connectObs();
  try {
    const scenes = await obs.request("GetSceneList");
    const recording = await obs.request("GetRecordStatus");
    assert.equal(recording.outputActive, false, "Refuse another run's active recording");
    const items = await obs.request("GetSceneItemList", { sceneName: "Godot Lab" });
    const window = await obs.request("GetInputSettings", { inputName: "Godot Lab Game Window" });
    const audio = await obs.request("GetInputSettings", { inputName: "Godot Lab Game Audio" });
    const scene = ownedScene(scenes.currentProgramSceneName, items.sceneItems, { window, audio });
    const version = await obs.request("GetVersion");
    return { password: auth.server_password, report: { ...scene, version: version.obsVersion } };
  } finally { obs.close(); }
}

async function official(args, config, env, { observe = false, freeform = false } = {}) {
  const port = await freePort();
  const token = randomBytes(32).toString("hex");
  const url = "http://127.0.0.1:" + port;
  const label = args[0] + (args[1] ? "-" + args[1].replaceAll(/[^a-zA-Z0-9_-]/g, "_") : "");
  const log = path.join(root, ".artifacts", "cappy-prototype-" + label + "-game.log");
  await writeFile(log, "");
  const childEnv = { ...env, GODOT_LAB_API_PORT: String(port), GODOT_LAB_API_TOKEN: token, GODOT_LAB_CAPPY_GAME_LOG: log };
  const child = spawn(process.execPath, [path.join(root, "node_modules/@uppercut-labs/cappy/dist/cappy.js"), ...args, "--config", path.join(root, config), "--json"], { cwd: root, env: childEnv, stdio: ["pipe", "pipe", "pipe"], windowsHide: true });
  let done = false, stdout = "", stderr = "", outputBytes = 0, runId = "";
  const samples = [];
  let blocked = null, watcherError = null;
  const processResult = new Promise((resolve, reject) => {
    child.stdout.on("data", chunk => { outputBytes += chunk.length; stdout += chunk; if (outputBytes > 8 * 1024 * 1024) { child.stdin.write("\n"); reject(new Error("CAPPY_OUTPUT_BUDGET")); } });
    child.stderr.on("data", chunk => { stderr = (stderr + chunk.toString()).slice(-8192); });
    child.once("error", reject);
    child.once("close", code => { done = true; resolve({ code }); });
  });
  const deadline = Date.now() + 45000;
  const watcher = (async () => {
    while (!done && Date.now() < deadline) {
      try {
        const health = await live(url, token, "/health");
        assert.equal(health.service, "godot-lab-live");
        if (runId) assert.equal(health.run_id, runId); else runId = health.run_id;
        const state = await live(url, token, "/v1/state");
        assert.equal(state.run_id, runId);
        samples.push({ lab: state.state.lab, tick: state.state.tick, revision: state.state.operation_bus.revision });
        if (freeform && !blocked && state.state.lab === "motion" && state.state.tick > 8) {
          blocked = await live(url, token, "/v1/operations", { operation: "host.enter", arguments: { id: "LAB-013" }, request_id: "freeform-scope-probe" });
          assert.equal(blocked.ok, false);
          assert.equal(blocked.code, "INPUT_V1_RECORDING_SCOPE");
          const after = await live(url, token, "/v1/state");
          assert.equal(after.state.lab, "motion");
          assert.equal(after.state.operation_bus.revision, state.state.operation_bus.revision);
        }
      } catch (error) {
        if (error.name === "AssertionError" || (!error.message.includes("fetch failed") && !["TimeoutError", "AbortError"].includes(error.name))) { watcherError = error; break; }
      }
      await delay(15);
    }
  })();
  const stopTimer = setTimeout(() => { child.stdin.write("\n"); }, 30000);
  const killTimer = setTimeout(() => { child.kill(); }, 45000);
  let exit;
  try { exit = await processResult; } finally { clearTimeout(stopTimer); clearTimeout(killTimer); done = true; await watcher; }
  assert.ok(!watcherError, watcherError?.message);
  assert.ok(!stdout.includes(token) && !stderr.includes(token));
  const envelope = JSON.parse(stdout);
  await writeFile(path.join(root, ".artifacts", "cappy-prototype-" + label + "-envelope.json"), JSON.stringify(envelope, null, 2) + "\n");
  if (observe) {
    assert.ok(samples.length > 0, "Official Cappy launch must concurrently serve live state");
    const gameLog = await readFile(log, "utf8");
    const identity = gameLog.split(/\r?\n/).filter(line => line.startsWith("LIVE_API ")).map(line => JSON.parse(line.slice(9))).at(-1);
    assert.equal(identity?.run_id, runId, "Live identity must match this official launch's stdout");
    assert.equal(identity.bound_port, port);
    assert.ok(!gameLog.includes("SCRIPT ERROR") && !gameLog.includes("ERROR:"));
  }
  if (freeform) assert.ok(blocked, "Scope probe must run during official recording");
  return { envelope, exitCode: exit.code, coexistence: { runId, samples: samples.length, firstTick: samples[0]?.tick, lastTick: samples.at(-1)?.tick, labs: [...new Set(samples.map(item => item.lab))], ...(blocked ? { compatibilityCode: blocked.code } : {}) } };
}

async function inspectPixels(master, scenario) {
  const file = bundlePath(master.path);
  assert.equal((await stat(file)).size, master.bytes);
  const bytes = await readFile(file);
  assert.equal(bytes.length, master.bytes);
  assert.equal(sha(bytes), master.sha256);
  const pixels = await command(process.env.FFMPEG_BIN || "ffmpeg", ["-v", "error", "-threads", "2", "-filter_threads", "2", "-i", file, "-vf", "fps=4,scale=128:72", "-pix_fmt", "rgb24", "-f", "rawvideo", "-threads", "2", "pipe:1"], 4 * 1024 * 1024);
  assert.ok(pixels.length > 0);
  let minimum = 255, maximum = 0, temporalDifference = 0;
  for (const value of pixels) { minimum = Math.min(minimum, value); maximum = Math.max(maximum, value); }
  assert.ok(maximum - minimum > 24 && maximum > 50, "Reject black/flat output");
  const frameBytes = 128 * 72 * 3;
  for (let index = frameBytes; index < pixels.length; index++) temporalDifference += Math.abs(pixels[index] - pixels[index - frameBytes]);
  temporalDifference /= Math.max(1, pixels.length - frameBytes);
  assert.ok(temporalDifference > 0.02, "Reject frozen frame sequences");
  const frame = path.join(root, ".artifacts", "cappy-prototype-" + scenario + "-frame.png");
  await command(process.env.FFMPEG_BIN || "ffmpeg", ["-v", "error", "-threads", "2", "-filter_threads", "2", "-ss", String(master.durationMs / 2000), "-i", file, "-frames:v", "1", "-threads", "2", "-y", frame]);
  return { sampledFrames: pixels.length / frameBytes, minimum, maximum, temporalDifference, frame: path.relative(root, frame).replaceAll("\\", "/") };
}

async function gameWrapper() {
  const [binary, ...args] = process.argv.slice(3);
  assert.ok(binary && process.env.GODOT_LAB_CAPPY_GAME_LOG);
  const env = { ...process.env };
  let relay;
  const sockets = new Set();
  if (env.CAPPY_ENDPOINT) {
    const endpoint = new URL(env.CAPPY_ENDPOINT);
    assert.equal(endpoint.hostname, "127.0.0.1");
    // A byte-transparent startup barrier gives short discovery a live HTTP sample.
    relay = net.createServer(socket => {
      sockets.add(socket);
      socket.once("close", () => sockets.delete(socket));
      socket.on("error", () => socket.destroy());
      socket.pause();
      const timer = setTimeout(() => {
        if (socket.destroyed) return;
        const upstream = net.connect({ host: "127.0.0.1", port: Number(endpoint.port) });
        sockets.add(upstream);
        upstream.once("close", () => sockets.delete(upstream));
        upstream.on("error", () => { socket.destroy(); upstream.destroy(); });
        socket.once("close", () => upstream.destroy());
        upstream.once("connect", () => { socket.pipe(upstream); upstream.pipe(socket); socket.resume(); });
      }, 500);
      socket.once("close", () => clearTimeout(timer));
    });
    await new Promise((resolve, reject) => { relay.once("error", reject); relay.listen(0, "127.0.0.1", resolve); });
    const local = new URL(endpoint);
    local.port = String(relay.address().port);
    env.CAPPY_ENDPOINT = local.toString();
  }
  const child = spawn(binary, args, { cwd: root, env, stdio: ["ignore", "pipe", "pipe"], windowsHide: false });
  appendFileSync(process.env.GODOT_LAB_CAPPY_GAME_LOG, JSON.stringify({ event: "owned_game_started", pid: child.pid, binary: path.basename(binary) }) + "\n");
  for (const stream of [child.stdout, child.stderr]) stream.on("data", chunk => {
    appendFileSync(process.env.GODOT_LAB_CAPPY_GAME_LOG, chunk);
    process.stdout.write(chunk);
  });
  child.once("error", error => { console.error(error.code || "GAME_LAUNCH_FAILED"); process.exitCode = 1; });
  child.once("close", code => { process.exitCode = code ?? 1; for (const socket of sockets) socket.destroy(); relay?.close(); });
  for (const signal of ["SIGTERM", "SIGINT"]) process.on(signal, () => child.kill(signal));
}

async function sourceProbe(original) {
  const provider = await inspectProvider();
  const port = await freePort();
  const token = randomBytes(32).toString("hex");
  const log = path.join(root, ".artifacts/cappy-prototype-source-probe-game.log");
  await writeFile(log, "");
  const env = { ...process.env, GODOT_LAB_API_PORT: String(port), GODOT_LAB_API_TOKEN: token, GODOT_LAB_CAPPY_GAME_LOG: log };
  delete env.CAPPY_ENDPOINT;
  delete env.CAPPY_SESSION_TOKEN;
  const child = spawn(process.execPath, [script, "--game", ...original], { cwd: root, env, stdio: ["ignore", "ignore", "ignore"], windowsHide: true });
  try {
    let health;
    for (let index = 0; index < 100; index++) {
      try { health = await live("http://127.0.0.1:" + port, token, "/health"); break; } catch (error) {
        if (!error.message.includes("fetch failed") && error.name !== "TimeoutError") throw error;
        await delay(100);
      }
    }
    assert.equal(health?.service, "godot-lab-live");
    const entered = await live("http://127.0.0.1:" + port, token, "/v1/operations", { operation: "host.enter", arguments: { id: "LAB-013" }, request_id: "source-probe" });
    assert.equal(entered.ok, true);
    await delay(700);
    const state = await live("http://127.0.0.1:" + port, token, "/v1/state");
    assert.equal(state.state.lab, "LAB-013");
    const obs = await connectObs();
    try {
      const screenshot = await obs.request("GetSourceScreenshot", { sourceName: "Godot Lab Game Window", imageFormat: "png", imageWidth: 1280, imageHeight: 720 });
      assert.ok(screenshot.imageData.startsWith("data:image/png;base64,"));
      const bytes = Buffer.from(screenshot.imageData.split(",")[1], "base64");
      assert.ok(bytes.length > 1000 && bytes.length < 4 * 1024 * 1024);
      const frame = path.join(root, ".artifacts/cappy-prototype-source-probe.png");
      await writeFile(frame, bytes);
      return { ...provider.report, runId: health.run_id, lab: state.state.lab, frame: path.relative(root, frame).replaceAll("\\", "/"), frameHash: sha(bytes) };
    } finally { obs.close(); }
  } finally {
    if (process.platform === "win32") await command("taskkill", ["/PID", String(child.pid), "/T", "/F"]);
    else child.kill();
  }
}

async function main(options) {
  await mkdir(path.join(root, ".artifacts"), { recursive: true });
  const report = { generatedAt: new Date().toISOString(), ok: false, providerVerified: false, captures: [], limits: ["Two selected prototypes only; no human/device acceptance", "Original input-v1 scope differs from named prototype capture"] };
  try {
    assert.ok(Number(process.versions.node.split(".")[0]) >= 24);
    report.package = await packageIdentity();
    report.source = await fingerprint();
    report.node = process.version;
    const configFile = "cappy.prototypes.local.json";
    const config = await setup({ automation: true, output: configFile });
    const original = config.game.command === process.execPath ? config.game.args.slice(1) : [config.game.command, ...config.game.args];
    config.game = { command: process.execPath, args: [script, "--game", ...original], cwd: "." };
    config.timeouts.readyMs = 30000;
    config.timeouts.processMs = 30000;
    config.defaultPreset = "master-only";
    await writeFile(path.join(root, configFile), JSON.stringify(config, null, 2) + "\n");
    report.engine = (await command(original[0], ["--version"])).toString().trim();
    if (options.mode === "probe") {
      report.sourceProbe = await sourceProbe(original);
      report.ok = true;
      report.providerReason = "Read-only source probe; no recording started";
      await writeFile(path.join(root, ".artifacts/cappy-prototype-source-probe.json"), JSON.stringify(report, null, 2) + "\n");
      console.log(JSON.stringify({ ok: true, sourceProbe: report.sourceProbe }));
      return;
    }
    const discovery = await official(["scenarios"], configFile, process.env, { observe: true });
    assert.ok(discovery.envelope.ok && discovery.exitCode === 0);
    assert.ok(["lab-013", "lab-007"].every(id => discovery.envelope.data.scenarios.some(scenario => scenario.id === id)));
    report.discovery = { scenarios: discovery.envelope.data.scenarios.length, adapter: discovery.envelope.data.adapter, coexistence: discovery.coexistence };
    const recording = await official(["record", "--duration", "4"], configFile, process.env, { observe: true, freeform: true });
    assert.ok(recording.envelope.ok && recording.exitCode === 0 && recording.envelope.data.replayable);
    assert.equal(recording.envelope.data.session.status, "completed");
    report.freeform = { sessionId: recording.envelope.data.session.id, coexistence: recording.coexistence, replayable: true };
    if (options.mode === "discovery") {
      report.ok = true;
      report.providerReason = "Capture not requested in discovery-only mode";
    } else {
      const disk = await statfs(root);
      assert.ok(disk.bavail * disk.bsize >= 512 * 1024 * 1024, "Insufficient output budget");
      let provider;
      try { provider = await inspectProvider(); } catch (error) { report.providerReason = error.message; }
      if (provider) {
        report.provider = provider.report;
        const env = { ...process.env, GODOT_LAB_OBS_PASSWORD: provider.password };
        const doctor = await official(["doctor"], configFile, env);
        report.doctor = doctor.envelope.data;
        assert.ok(doctor.envelope.ok && doctor.exitCode === 0, "Official preflight failed");
        for (const scenario of ["LAB-013", "LAB-007"]) {
          assert.equal((await fingerprint()).treeHash, report.source.treeHash, "Source changed before capture");
          const capture = await official(["run", scenario.toLowerCase()], configFile, env, { observe: true });
          assert.ok(capture.envelope.ok && capture.exitCode === 0, "Official named capture failed");
          assert.ok(capture.coexistence.labs.includes(scenario), "HTTP must observe the captured prototype in the same launch");
          const result = capture.envelope.data;
          const manifestBytes = await readFile(bundlePath(result.manifest));
          const validated = validateCapture(result, JSON.parse(manifestBytes), scenario);
          const pixels = await inspectPixels(validated.master, scenario);
          assert.equal((await fingerprint()).treeHash, report.source.treeHash, "Source changed during capture");
          report.captures.push({ scenario, captureId: result.captureId, sessionId: result.sessionId, state: result.state, manifest: result.manifest, manifestHash: sha(manifestBytes), master: validated.master, proof: validated.proof, coexistence: capture.coexistence, pixels });
        }
        report.providerVerified = true;
        report.ok = true;
      }
    }
  } catch (error) { report.error = error.message; }
  await writeFile(path.join(root, ".artifacts/cappy-prototypes.json"), JSON.stringify(report, null, 2) + "\n");
  console.log(JSON.stringify({ ok: report.ok, providerVerified: report.providerVerified, captures: report.captures.length, error: report.error, providerReason: report.providerReason }));
  process.exitCode = report.ok ? 0 : 1;
}

if (process.argv[1] && path.resolve(process.argv[1]) === script) {
  if (process.argv[2] === "--game") await gameWrapper();
  else {
    let options;
    try {
      options = parseOptions(process.argv.slice(2));
    } catch (error) {
      console.error(JSON.stringify({ ok: false, code: "INVALID_OPTIONS", error: error.message }));
      process.exitCode = 2;
    }
    if (options) {
      if (options.help) console.log(helpText()); else await main(options);
    }
  }
}
