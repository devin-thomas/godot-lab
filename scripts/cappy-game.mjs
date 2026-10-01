import { spawn } from "node:child_process";

// Cappy 0.1.0 uses windowsHide for launched processes. Make the desired
// Godot window visibility explicit for Windows capture.
const [command, ...args] = process.argv.slice(2);
if (!command) throw new Error("Pass the Godot executable followed by its arguments");
const game = spawn(command, args, { stdio: "inherit", windowsHide: false });
game.once("error", error => { console.error(error.message); process.exitCode = 1; });
game.once("close", code => { process.exitCode = code ?? 1; });
for (const signal of ["SIGINT", "SIGTERM"]) process.on(signal, () => game.kill(signal));
