import { createHash } from "node:crypto"
import { Plugin } from "@opencode/plugin"

// Mask PII in outgoing model requests with the local Kiji service
// (github:atomic-235/kiji-pii-flake). Only strings not seen before are sent;
// already-masked strings are cached. Fails open if the service is down.

const ENDPOINT = process.env.PII_FILTER_URL ?? "http://127.0.0.1:8788/redact"
const TIMEOUT_MS = 10_000
const MIN_LENGTH = 4
const MAX_STRING = 20_000
const MAX_BATCH_CHARS = 8_000
const MAX_NEW_CHARS = 24_000
const DISABLE_MS = 300_000
const BINARY_KEYS = new Set(["data", "media", "base64", "image"])
const STRUCTURAL_KEYS = new Set([
  "model",
  "modelID",
  "providerID",
  "provider",
  "variant",
  "agent",
  "id",
  "sessionID",
  "messageID",
  "callID",
  "tool",
  "toolName",
  "name",
  "role",
  "type",
  "mime",
  "filename",
  "filePath",
  "path",
  "directory",
  "worktree",
  "version",
  "baseURL",
])

const ENV_EXCLUDE = new Set([
  "PWD",
  "SECRETS_DIR",
  "SSH_AUTH_SOCK",
  "SSH_ASKPASS",
  "GPG_TTY",
  "GNUPGHOME",
  "XDG_RUNTIME_DIR",
  "HYPRLAND_INSTANCE_SIGNATURE",
  "DBUS_SESSION_BUS_ADDRESS",
  "STARSHIP_SESSION_KEY",
  "OPENCODE_SESSION_ID",
  "OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX",
  "MANAGERPID",
  "MANAGERPIDFDID",
])
const SECRET_NAME = /(TOKEN|KEY|SECRET|PASSWORD|PASSWD|PWD|API_KEY|APIKEY|AUTH|CREDENTIAL|DSN|WEBHOOK|PRIVATE)/i
const ENV_VALUES = Object.entries(process.env)
  .filter(
    ([name, value]) =>
      !!value && value.length >= 8 && SECRET_NAME.test(name) && !ENV_EXCLUDE.has(name),
  )
  .map(([, value]) => value)
  .sort((a, b) => b.length - a.length)

const cache = new Map<string, string>()
let disabledUntil = 0

const digest = (value: string) => createHash("sha1").update(value).digest("hex")

const RULES: [string, RegExp][] = [
  ["aws", /AKIA[0-9A-Z]{16}/g],
  ["github", /gh[pousr]_[A-Za-z0-9]{36,}/g],
  ["openai", /sk-(?:proj-)?[A-Za-z0-9_-]{20,}/g],
  ["anthropic", /sk-ant-[A-Za-z0-9_-]{20,}/g],
  ["slack", /xox[baprs]-[A-Za-z0-9-]{10,}/g],
  ["stripe", /sk_live_[A-Za-z0-9]{20,}/g],
  ["jwt", /eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/g],
  ["pem", /-----BEGIN [A-Z ]+PRIVATE KEY-----[\s\S]+?-----END [A-Z ]+PRIVATE KEY-----/g],
  ["npm", /npm_[A-Za-z0-9]{30,}/g],
  ["gitlab", /glpat-[A-Za-z0-9_-]{20,}/g],
  ["discord", /[MN][A-Za-z\d]{23,}\.[\w-]{6}\.[\w-]{27,}/g],
  ["telegram", /\d{8,10}:[A-Za-z0-9_-]{35}/g],
  ["urlcreds", /:\/\/[^:\s/]+:[^@\s/]+@/g],
  ["bearer", /bearer\s+[A-Za-z0-9._-]{16,}/gi],
]

function regexMask(value: string): string {
  let out = value
  for (const secret of ENV_VALUES) out = out.split(secret).join("[REDACTED:env]")
  for (const [label, rule] of RULES) out = out.replace(rule, `[REDACTED:${label}]`)
  out = out.replace(
    /((?:password|passwd|pwd|secret|token|api[_-]?key)\s*[:=]\s*["'])([^"']{6,})(["'])/gi,
    "$1[REDACTED:secret]$3",
  )
  return out
}

function collect(value: unknown, out: string[]): void {
  if (typeof value === "string") {
    if (value.length >= MIN_LENGTH && value.length <= MAX_STRING) out.push(value)
    return
  }
  if (Array.isArray(value)) {
    for (const item of value) collect(item, out)
    return
  }
  if (value && typeof value === "object") {
    for (const [key, item] of Object.entries(value)) {
      if (!BINARY_KEYS.has(key) && !STRUCTURAL_KEYS.has(key)) collect(item, out)
    }
  }
}

function replace(value: unknown, map: Map<string, string>): unknown {
  if (typeof value === "string") return map.get(value) ?? value
  if (Array.isArray(value)) return value.map((item) => replace(item, map))
  if (value && typeof value === "object") {
    for (const [key, item] of Object.entries(value)) {
      if (!BINARY_KEYS.has(key) && !STRUCTURAL_KEYS.has(key))
        (value as Record<string, unknown>)[key] = replace(item, map)
    }
    return value
  }
  return value
}

async function redact(strings: string[]): Promise<Map<string, string> | null> {
  try {
    const response = await fetch(ENDPOINT, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ texts: strings }),
      signal: AbortSignal.timeout(TIMEOUT_MS),
    })
    if (!response.ok) return null
    const data = (await response.json()) as { redacted?: unknown }
    if (!Array.isArray(data.redacted) || data.redacted.length !== strings.length) return null
    if (!data.redacted.every((item) => typeof item === "string")) return null
    return new Map(strings.map((item, index) => [item, data.redacted![index] as string]))
  } catch {
    return null
  }
}

export default Plugin.define({
  id: "local.pii-filter",
  async setup(ctx) {
    await ctx.session.hook("http.request", async (event) => {
      const contentType = event.request.headers.get("content-type") ?? ""
      if (!contentType.includes("json")) return

      let parsed: unknown
      try {
        parsed = JSON.parse(await event.request.clone().text())
      } catch {
        return
      }

      const all: string[] = []
      collect(parsed, all)
      if (all.length === 0) return

      const raw = [...new Set(all)]
      const pre = raw.map(regexMask)
      const unseen = [...new Set(pre)].filter((value) => !cache.has(digest(value)))
      if (unseen.length > 0 && Date.now() >= disabledUntil) {
        const selected: string[] = []
        let total = 0
        for (const value of unseen) {
          if (total + value.length > MAX_NEW_CHARS) break
          selected.push(value)
          total += value.length
        }

        for (let index = 0; index < selected.length; ) {
          const batch: string[] = []
          let size = 0
          while (index < selected.length) {
            const next = size + selected[index].length
            if (batch.length > 0 && next > MAX_BATCH_CHARS) break
            batch.push(selected[index])
            size = next
            index += 1
          }
          const part = await redact(batch)
          if (!part) {
            disabledUntil = Date.now() + DISABLE_MS
            break
          }
          for (const [key, value] of part) cache.set(digest(key), value)
        }
      }

      const map = new Map(
        raw.map((value, index) => [value, cache.get(digest(pre[index])) ?? pre[index]]),
      )
      const body = JSON.stringify(replace(parsed, map))
      const headers = new Headers(event.request.headers)
      headers.delete("content-length")
      event.request = new Request(event.request, { headers, body })
    })
  },
})
