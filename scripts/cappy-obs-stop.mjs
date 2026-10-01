import { execFile } from "node:child_process";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { promisify } from "node:util";
import { root } from "./cappy-setup.mjs";
import { connectObs } from "./cappy-obs-client.mjs";

if (process.platform !== "win32") throw new Error("The isolated portable OBS helper requires Windows");
const instance = JSON.parse(await readFile(path.join(root, ".artifacts/obs-instance.json"), "utf8"));
const expected = path.join(root, ".local/obs/bin/64bit/obs64.exe");
if (!Number.isSafeInteger(instance.pid) || instance.pid <= 0 || path.resolve(instance.binary) !== expected) throw new Error("Isolated OBS identity is invalid");
const obs = await connectObs();
try {
  const status = await obs.request("GetRecordStatus");
  if (status.outputActive) throw new Error("Finish the active lab capture before stopping isolated OBS");
} finally { obs.close(); }
const quotedBinary = expected.replaceAll("'", "''");
const command = `$labObs = Get-Process -Id ${instance.pid} -ErrorAction Stop; if ($labObs.Path -ne '${quotedBinary}') { throw 'OBS process identity changed; refusing to stop it' }; Stop-Process -Id $labObs.Id; 'Stopped only the isolated Godot Lab OBS instance'`;
const result = await promisify(execFile)("powershell.exe", ["-NoProfile", "-Command", command], { windowsHide: true });
console.log(result.stdout.trim());
