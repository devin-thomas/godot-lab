import { spawn } from "node:child_process";
import { randomBytes } from "node:crypto";
import { access, cp, mkdir, readFile, symlink, writeFile } from "node:fs/promises";
import path from "node:path";
import net from "node:net";
import { connectObs } from "./cappy-obs-client.mjs";
import { root, setup } from "./cappy-setup.mjs";

// An opt-in, separate portable instance. Never connects to the user's OBS port.
if (process.platform !== "win32") throw new Error("This isolated portable OBS helper currently requires Windows. Configure your own game-only OBS scene on other hosts.");
const source = process.argv[2] || process.env.GODOT_LAB_OBS_PORTABLE;
if (!source) throw new Error("Pass an existing OBS portable root, e.g. npm run capture:setup -- C:/tools/obs-portable");
await access(path.join(source, "bin/64bit/obs64.exe"));
const destination = path.join(root, ".local/obs");
async function portReady() {
  return new Promise(resolve => {
    const socket = net.connect({ host: "127.0.0.1", port: 4467 });
    socket.once("connect", () => { socket.destroy(); resolve(true); });
    socket.once("error", () => resolve(false));
  });
}
if (await portReady()) throw new Error("Port 4467 is already active. Stop the previously created isolated lab OBS before running setup again.");
await mkdir(destination, { recursive: true });
await cp(path.join(source, "bin"), path.join(destination, "bin"), { recursive: true, filter: file => !file.endsWith(".pdb") });
for (const directory of ["data", "obs-plugins"]) {
  const target = path.join(destination, directory);
  try { await access(target); } catch (error) {
    if (error.code !== "ENOENT") throw error;
    await symlink(path.resolve(source, directory), target, "junction");
  }
}
await writeFile(path.join(destination, "portable_mode.txt"), "");
const configRoot = path.join(destination, "config/obs-studio");
const authFile = path.join(configRoot, "plugin_config/obs-websocket/config.json");
await mkdir(path.dirname(authFile), { recursive: true });
let auth;
try { auth = JSON.parse(await readFile(authFile, "utf8")); } catch (error) {
  if (error.code !== "ENOENT") throw error;
  auth = { server_enabled: true, server_port: 4467, auth_required: true, server_password: randomBytes(32).toString("hex"), alerts_enabled: false };
  await writeFile(authFile, JSON.stringify(auth));
}
await mkdir(path.join(configRoot, "basic/profiles/GodotLab"), { recursive: true });
await mkdir(path.join(configRoot, "basic/scenes"), { recursive: true });
await mkdir(path.join(root, ".artifacts/obs-recordings"), { recursive: true });
await writeFile(path.join(configRoot, "global.ini"), "[General]\nFirstRun=true\nConfirmOnExit=false\n");
await writeFile(path.join(configRoot, "user.ini"), "[General]\nFirstRun=true\nConfirmOnExit=false\n[Basic]\nProfile=GodotLab\nProfileDir=GodotLab\nSceneCollection=GodotLab\nSceneCollectionFile=GodotLab\n[BasicWindow]\nSysTrayEnabled=true\n");
const recordings = path.join(root, ".artifacts/obs-recordings").replaceAll("\\", "/");
await writeFile(path.join(configRoot, "basic/profiles/GodotLab/basic.ini"), `[General]\nName=GodotLab\n[Video]\nBaseCX=1280\nBaseCY=720\nOutputCX=1280\nOutputCY=720\nFPSType=0\nFPSCommon=30\n[Output]\nMode=Simple\n[SimpleOutput]\nRecQuality=Small\nRecEncoder=x264\nRecFormat2=mkv\nFilePath=${recordings}\nRecRB=false\n[Audio]\nSampleRate=48000\nChannelSetup=Stereo\n`);
const binary = path.join(destination, "bin/64bit/obs64.exe");
const executable = spawn(binary, ["--portable", "--multi", "--disable-shutdown-check", "--disable-updater", "--minimize-to-tray"], { cwd: path.dirname(binary), detached: true, stdio: "ignore", windowsHide: true });
executable.unref();
let ready = false;
for (let attempt = 0; attempt < 45; attempt++) {
  if (await portReady()) { ready = true; break; }
  await new Promise(resolve => setTimeout(resolve, 1000));
}
if (!ready) throw new Error(`Isolated OBS did not open port 4467. Inspect logs under ${configRoot}/logs.`);
const obs = await connectObs();
const request = obs.request;
try {
  const scenes = await request("GetSceneList");
  if (!scenes.scenes.some(scene => scene.sceneName === "Godot Lab")) await request("CreateScene", { sceneName: "Godot Lab" });
  const inputs = await request("GetInputList");
  const title = "Godot Lab | Signal Observatory";
  // WGC window capture has no display fallback. Capture only the Godot client area.
  const settings = { window: `${title} (DEBUG):Engine:Godot_v4.7.2-stable_win64.exe`, method: 2, priority: 0, client_area: true, cursor: false };
  if (!inputs.inputs.some(input => input.inputName === "Godot Lab Game Window")) {
    await request("CreateInput", { sceneName: "Godot Lab", inputName: "Godot Lab Game Window", inputKind: "window_capture", inputSettings: settings, sceneItemEnabled: true });
  } else await request("SetInputSettings", { inputName: "Godot Lab Game Window", inputSettings: settings });
  if (!inputs.inputs.some(input => input.inputName === "Godot Lab Game Audio")) {
    await request("CreateInput", { sceneName: "Godot Lab", inputName: "Godot Lab Game Audio", inputKind: "wasapi_process_output_capture", inputSettings: { window: settings.window, priority: 0 }, sceneItemEnabled: true });
  }
  await request("SetCurrentProgramScene", { sceneName: "Godot Lab" });
  const version = await request("GetVersion");
  await setup({ automation: true, output: "cappy.capture.local.json" });
  await writeFile(path.join(root, ".artifacts/obs-instance.json"), `${JSON.stringify({ pid: executable.pid, binary, port: 4467, scene: "Godot Lab", sourceKind: "window_capture", obsVersion: version.obsVersion }, null, 2)}\n`);
  console.log(`Isolated OBS ${version.obsVersion} on port 4467, scene Godot Lab, game-window-only source. Capture config ready.`);
} finally { obs.close(); }
