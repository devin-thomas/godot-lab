import { spawn } from "node:child_process";
import path from "node:path";
import { root } from "./cappy-setup.mjs";

export async function cappy(args, config = "cappy.config.json") {
  const launcher = path.join(root, "node_modules/@uppercut-labs/cappy/dist/cappy.js");
  const output = await new Promise((resolve, reject) => {
    const child = spawn(process.execPath, [launcher, ...args, "--config", path.join(root, config), "--json"], { cwd: root, stdio: ["ignore", "pipe", "pipe"], windowsHide: true });
    let stdout = "";
    let stderr = "";
    child.stdout.setEncoding("utf8").on("data", chunk => { stdout += chunk; });
    child.stderr.setEncoding("utf8").on("data", chunk => { stderr += chunk; });
    child.once("error", reject);
    child.once("close", code => resolve({ code, stdout, stderr }));
  });
  let envelope;
  try { envelope = JSON.parse(output.stdout); } catch { throw new Error(`Cappy did not return JSON: ${output.stdout}\n${output.stderr}`); }
  if (output.code !== 0 || !envelope.ok) throw new Error(`Cappy ${args[0]} failed (${output.code}): ${JSON.stringify(envelope.error)}\n${output.stderr}`);
  return envelope.data;
}
