import { createHash } from "node:crypto"
import { Plugin } from "@opencode/plugin"

// Mask secrets and PII in outgoing model requests with the local
// privacy-filter service (github:atomic-235/privacy-filter-flake).
// Only strings not seen before are sent; already-masked strings are cached.
// Fails open if the service is down or too slow.

const ENDPOINT = process.env.PRIVACY_FILTER_URL ?? "http://127.0.0.1:8787/redact"
const TIMEOUT_MS = 20_000
const MIN_LENGTH = 4
const MAX_STRING = 20_000
const MAX_BATCH_CHARS = 16_000
const MAX_NEW_CHARS = 64_000
const DISABLE_MS = 300_000
const BINARY_KEYS = new Set(["data", "media", "base64", "image"])

const cache = new Map<string, string>()
let disabledUntil = 0

const digest = (value: string) => createHash("sha1").update(value).digest("hex")

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
      const unseen = unique.filter((value) => !cache.has(digest(value)))
      let total = 0
      if (unseen.length > 0 && Date.now() >= disabledUntil) {
        const selected: string[] = []
        for (const value of unseen) {
          if (total + value.length > MAX_NEW_CHARS) break
          selected.push(value)
          total += value.length
        }

        for (let index = 0; index < selected.length; ) {
          const batch: string[] = []
          let size = 0
          while (index < selected.length) {
            const sizeWithNext = size + selected[index].length
            if (batch.length > 0 && sizeWithNext > MAX_BATCH_CHARS) break
            batch.push(selected[index])
            size = sizeWithNext
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

      const map = new Map(unique.map((value) => [value, cache.get(digest(value)) ?? value]))
      const body = JSON.stringify(replace(parsed, map))
      const headers = new Headers(event.request.headers)
      headers.delete("content-length")
      event.request = new Request(event.request, { headers, body })
    })
  },
})
