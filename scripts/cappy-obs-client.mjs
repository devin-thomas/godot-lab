import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import path from "node:path";
import WebSocket from "ws";
import { root } from "./cappy-setup.mjs";

export async function connectObs() {
  const auth = JSON.parse(await readFile(path.join(root, ".local/obs/config/obs-studio/plugin_config/obs-websocket/config.json"), "utf8"));
  const socket = new WebSocket("ws://127.0.0.1:4467");
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => { socket.close(); reject(new Error("Isolated lab OBS connection timed out")); }, 10000);
    socket.once("error", error => { clearTimeout(timer); reject(error); });
    const listener = raw => {
      const message = JSON.parse(String(raw));
      if (message.op === 0) {
        const secret = createHash("sha256").update(auth.server_password + message.d.authentication.salt).digest("base64");
        const authentication = createHash("sha256").update(secret + message.d.authentication.challenge).digest("base64");
        socket.send(JSON.stringify({ op: 1, d: { rpcVersion: 1, authentication, eventSubscriptions: 0 } }));
      }
      if (message.op === 2) { clearTimeout(timer); socket.off("message", listener); resolve(); }
    };
    socket.on("message", listener);
  });
  let sequence = 0;
  return {
    close: () => socket.close(),
    async request(requestType, requestData = {}) {
      const requestId = String(++sequence);
      const result = new Promise((resolve, reject) => {
        const timer = setTimeout(() => { socket.off("message", listener); reject(new Error(`OBS timed out: ${requestType}`)); }, 10000);
        const listener = raw => {
          const message = JSON.parse(String(raw));
          if (message.op !== 7 || message.d.requestId !== requestId) return;
          clearTimeout(timer);
          socket.off("message", listener);
          if (!message.d.requestStatus.result) reject(new Error(`OBS ${requestType}: ${message.d.requestStatus.comment}`));
          else resolve(message.d.responseData);
        };
        socket.on("message", listener);
      });
      socket.send(JSON.stringify({ op: 6, d: { requestType, requestId, requestData } }));
      return result;
    }
  };
}
