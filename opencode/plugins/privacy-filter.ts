import { Plugin } from "@opencode/plugin"

// Mask secrets and PII in outgoing model requests with the local
// privacy-filter service (github:atomic-235/privacy-filter-flake).
// Fails open: if the service is down, the request is sent unchanged.

const ENDPOINT = process.env.PRIVACY_FILTER_URL ?? "http://127.0.0.1:8787/redact"
const TIMEOUT_MS = 15_000
const MIN_LENGTH = 4
const MAX_STRING = 20_000
const BATCH = 500
const BINARY_KEYS = new Set(["data", "media", "base64", "image"])

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
      if (!BINARY_KEYS.has(key)) collect(item, out)
    }
  }
}

function replace(value: unknown, map: Map<string, string>): unknown {
  if (typeof value === "string") return map.get(value) ?? value
  if (Array.isArray(value)) return value.map((item) => replace(item, map))
  if (value && typeof value === "object") {
    for (const [key, item] of Object.entries(value)) {
      if (!BINARY_KEYS.has(key)) (value as Record<string, unknown>)[key] = replace(item, map)
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
  id: "local.privacy-filter",
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

      const unique = [...new Set(all)]
      const map = new Map<string, string>()
      for (let index = 0; index < unique.length; index += BATCH) {
        const part = await redact(unique.slice(index, index + BATCH))
        if (!part) return
        for (const [key, value] of part) map.set(key, value)
      }

      const body = JSON.stringify(replace(parsed, map))
      const headers = new Headers(event.request.headers)
      headers.delete("content-length")
      event.request = new Request(event.request, { headers, body })
    })
  },
})
