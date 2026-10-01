import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

export async function setup({ headless = false, automation = false, output = "cappy.config.json" } = {}) {
  const config = JSON.parse(await readFile(path.join(root, "cappy.config.example.json"), "utf8"));
  config.game.command = process.env.GODOT_BIN || (process.platform === "win32" ? (headless ? "godot_console.exe" : "godot.exe") : "godot");
  config.game.args = [...(headless ? ["--headless"] : []), "--path", path.join(root, "game")];
  if (!headless) config.game.args.push("--position", "120,120", "--always-on-top");
  if (automation) config.game.args.push("--", "--automation");
  if (!headless && process.platform === "win32") {
    config.game.args = [path.join(root, "scripts/cappy-game.mjs"), config.game.command, ...config.game.args];
    config.game.command = process.execPath;
  }
  await writeFile(path.join(root, output), `${JSON.stringify(config, null, 2)}\n`);
  return config;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  await setup({ headless: process.argv.includes("--headless"), automation: process.argv.includes("--automation") });
  console.log("Wrote ignored local cappy.config.json. Run npm run cappy -- scenarios --json.");
}
