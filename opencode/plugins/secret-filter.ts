import { Plugin } from "@opencode/plugin"

// Mask secrets and basic PII in outgoing model requests.
// Pure local regex + exact env-value matching; no model, no service.

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
  ["email", /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/gi],
]

function mask(value: string): string {
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
    if (value.length >= 4 && value.length <= 20_000) out.push(value)
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

export default Plugin.define({
  id: "local.secret-filter",
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

      const strings: string[] = []
      collect(parsed, strings)
      if (strings.length === 0) return

      const map = new Map<string, string>()
      for (const value of strings) {
        if (!map.has(value)) map.set(value, mask(value))
      }

      const body = JSON.stringify(replace(parsed, map))
      const headers = new Headers(event.request.headers)
      headers.delete("content-length")
      event.request = new Request(event.request, { headers, body })
    })
  },
})
