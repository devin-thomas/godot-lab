import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { existsSync, statSync } from "node:fs";
import test from "node:test";
import { fileURLToPath } from "node:url";
import { bundlePath, ownedScene, parseOptions, validateCapture } from "../scripts/cappy_prototypes.mjs";

function sourceFixture() {
  const window = { inputKind: "window_capture", inputSettings: { method: 2, priority: 0, client_area: true, window: "Godot Lab | Signal Observatory:Engine:Godot.exe" } };
  const audio = { inputKind: "wasapi_process_output_capture", inputSettings: { window: window.inputSettings.window } };
  const items = [{ sourceName: "Godot Lab Game Window", sceneItemEnabled: true }, { sourceName: "Godot Lab Game Audio", sceneItemEnabled: true }];
  return { window, audio, items };
}

function captureFixture() {
  const result = { captureId: "capture", state: "succeeded", events: [{ type: "LAB_PROOF", payload: { lab: "LAB-013", passed: true } }] };
  const master = { role: "master", path: "captures/capture/master.mkv", bytes: 1000, sha256: "a".repeat(64), durationMs: 3000, width: 1280, height: 720, source: { tool: "obs" } };
  const manifest = { status: "succeeded", identity: { captureId: "capture", source: { scenarioId: "lab-013" } }, build: { cappyVersion: "0.1.0" }, artifacts: [master] };
  return { result, master, manifest };
}

test("CLI modes are explicit and malformed options cannot default to capture", () => {
  assert.deepEqual(parseOptions([]), { mode: "capture", help: false });
  assert.deepEqual(parseOptions(["--discovery-only"]), { mode: "discovery", help: false });
  assert.deepEqual(parseOptions(["--probe-only"]), { mode: "probe", help: false });
  assert.equal(parseOptions(["-h"]).help, true);
  for (const args of [["--unknown"], ["lab-013"], ["--probe-only", "--discovery-only"], ["--discovery-only", "--discovery-only"]]) {
    assert.throws(() => parseOptions(args));
  }
});

test("help exits without game launch or changing capture evidence", () => {
  const evidence = fileURLToPath(new URL("../.artifacts/cappy-prototypes.json", import.meta.url));
  const before = existsSync(evidence) ? statSync(evidence).mtimeMs : null;
  const script = fileURLToPath(new URL("../scripts/cappy_prototypes.mjs", import.meta.url));
  const result = spawnSync(process.execPath, [script, "--help"], { encoding: "utf8", timeout: 3000 });
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Usage:/);
  assert.match(result.stdout, /--discovery-only/);
  assert.match(result.stdout, /--probe-only/);
  assert.match(result.stdout, /no OBS recording/);
  assert.doesNotMatch(result.stdout, /LIVE_API|owned_game_started/);
  assert.equal(existsSync(evidence) ? statSync(evidence).mtimeMs : null, before);
});

test("owned game-only scene passes without any OBS mutation", () => {
  const fixture = sourceFixture();
  assert.equal(ownedScene("Godot Lab", fixture.items, fixture).windowOnly, true);
});

test("foreign scene, extra source and display fallback are refused", () => {
  const fixture = sourceFixture();
  assert.throws(() => ownedScene("User scene", fixture.items, fixture));
  assert.throws(() => ownedScene("Godot Lab", [...fixture.items, { sourceName: "Private Desktop", sceneItemEnabled: true }], fixture));
  fixture.window.inputSettings.method = 0;
  assert.throws(() => ownedScene("Godot Lab", fixture.items, fixture));
});

test("media path never escapes official managed bundle", () => {
  assert.ok(bundlePath("captures/example/master.mkv").endsWith("master.mkv"));
  for (const value of ["../outside.mkv", "/absolute.mkv", "C:/private.mkv", "captures\\escape.mkv", "captures/./master.mkv", "captures//master.mkv"]) {
    assert.throws(() => bundlePath(value));
  }
});

test("verified provider master and real scenario proof required together", () => {
  const fixture = captureFixture();
  assert.equal(validateCapture(fixture.result, fixture.manifest, "LAB-013").proof.passed, true);
  fixture.result.events[0].payload.passed = false;
  assert.throws(() => validateCapture(fixture.result, fixture.manifest, "LAB-013"));
});

test("wrong scenario, non-provider master and recording budget fail", () => {
  const fixture = captureFixture();
  assert.throws(() => validateCapture(fixture.result, fixture.manifest, "LAB-007"));
  fixture.master.source.tool = "ffmpeg";
  assert.throws(() => validateCapture(fixture.result, fixture.manifest, "LAB-013"));
  fixture.master.source.tool = "obs";
  fixture.master.durationMs = 60000;
  assert.throws(() => validateCapture(fixture.result, fixture.manifest, "LAB-013"));
  fixture.master.durationMs = 3000;
  fixture.master.bytes = 500 * 1024 * 1024;
  assert.throws(() => validateCapture(fixture.result, fixture.manifest, "LAB-013"));
});
