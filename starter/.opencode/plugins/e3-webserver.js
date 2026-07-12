/**
 * E3 Hackathon webserver plugin.
 *
 * Serves the team's project folder as a website from inside the opencode
 * process, so participants never manage server processes or ports. Exposed
 * as custom tools (webserver_start / webserver_stop / webserver_restart)
 * that the /start, /stop and /refresh slash commands invoke. Every response
 * includes the exact links to paste into a browser — one for this computer,
 * one for a phone on the same wifi.
 *
 * Files are served with Cache-Control: no-store, so reloading the browser
 * always shows the latest edit.
 */

import { tool } from "@opencode-ai/plugin"
import { createServer } from "node:http"
import { networkInterfaces } from "node:os"
import { extname, join, resolve, sep } from "node:path"
import { existsSync, readFileSync, statSync } from "node:fs"

const FIRST_PORT = 3000
const LAST_PORT = 3019

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".webp": "image/webp",
  ".mp4": "video/mp4",
  ".mp3": "audio/mpeg",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
  ".txt": "text/plain; charset=utf-8",
  ".pdf": "application/pdf",
}

function lanAddress() {
  for (const infos of Object.values(networkInterfaces())) {
    for (const info of infos ?? []) {
      if (info.family === "IPv4" && !info.internal) return info.address
    }
  }
  return null
}

export const E3Webserver = async ({ directory }) => {
  const root = resolve(directory ?? process.cwd())
  let server = null
  let port = null

  const links = () => {
    const lan = lanAddress()
    const lines = [`Paste this link into the browser on this computer:  http://localhost:${port}`]
    if (lan) lines.push(`On a phone (must be on the same wifi):  http://${lan}:${port}`)
    return lines.join("\n")
  }

  const handleRequest = (req, res) => {
    try {
      const pathname = decodeURIComponent(new URL(req.url, "http://localhost").pathname)
      let filePath = resolve(join(root, pathname))
      if (filePath !== root && !filePath.startsWith(root + sep)) {
        res.writeHead(403, { "Content-Type": "text/plain" })
        res.end("Forbidden")
        return
      }
      if (existsSync(filePath) && statSync(filePath).isDirectory()) {
        filePath = join(filePath, "index.html")
      }
      if (!existsSync(filePath)) {
        res.writeHead(404, { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" })
        res.end("<h1>No page here yet</h1><p>Ask the agent to create your first page (index.html), then reload.</p>")
        return
      }
      res.writeHead(200, {
        "Content-Type": MIME[extname(filePath).toLowerCase()] ?? "application/octet-stream",
        "Cache-Control": "no-store",
      })
      res.end(readFileSync(filePath))
    } catch {
      res.writeHead(500, { "Content-Type": "text/plain" })
      res.end("Server error")
    }
  }

  const listenOn = (p) =>
    new Promise((resolvePromise, rejectPromise) => {
      const s = createServer(handleRequest)
      s.once("error", rejectPromise)
      s.listen(p, "0.0.0.0", () => resolvePromise(s))
    })

  const start = async () => {
    if (server) return `The website is already running.\n${links()}`
    for (let p = FIRST_PORT; p <= LAST_PORT; p++) {
      try {
        server = await listenOn(p)
        port = p
        break
      } catch (err) {
        if (err?.code !== "EADDRINUSE" && err?.code !== "EACCES") throw err
      }
    }
    if (!server) {
      return `Could not start: every port from ${FIRST_PORT} to ${LAST_PORT} is busy. Ask an instructor for help.`
    }
    return `The website is now running.\n${links()}`
  }

  const stop = async () => {
    if (!server) return "The website was not running. Use /start to turn it on."
    server.closeAllConnections?.()
    await new Promise((resolveClose) => server.close(resolveClose))
    server = null
    port = null
    return "The website has been stopped. Use /start to turn it back on."
  }

  return {
    tool: {
      webserver_start: tool({
        description:
          "Start the local webserver that shows this project as a website. Returns the links to paste into a browser (computer + phone on same wifi). Use this instead of npx serve, python http.server, or any other server.",
        args: {},
        async execute() {
          return start()
        },
      }),
      webserver_stop: tool({
        description: "Stop the local webserver for this project.",
        args: {},
        async execute() {
          return stop()
        },
      }),
      webserver_restart: tool({
        description:
          "Restart the local webserver for this project (fixes a stuck server). Returns the fresh links to paste into a browser.",
        args: {},
        async execute() {
          if (server) await stop()
          return start()
        },
      }),
    },
  }
}
