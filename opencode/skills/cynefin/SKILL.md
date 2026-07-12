---
name: cynefin
description: Use when unsure what kind of problem you are dealing with, or when the same approach keeps failing. Classifies situations into Clear, Complicated, Complex, or Chaotic domains and applies domain-appropriate strategies.
---

# Cynefin Framework

Use this framework when you're unsure what kind of problem you're dealing with, or when the same approach keeps failing.

## Stages

### 1. CLASSIFY THE SITUATION
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to research the domain. Do NOT rely on training data or fabricate sources.**
Determine which Cynefin domain applies:

**CLEAR** — Cause and effect are known, predictable, and stable.
- Best practice applies. Sense → Categorize → Respond.
- Example: processing a known transaction type.

**COMPLICATED** — Cause and effect exist but require expertise to discover.
- Good practice applies. Sense → Analyze → Respond.
- Multiple right answers possible; expert judgment needed.
- Example: diagnosing a complex but understood system failure.

**COMPLEX** — Cause and effect are only clear in hindsight.
- Emergent practice. Probe → Sense → Respond.
- You must experiment to understand; don't assume you know.
- Example: building a product in a new market.

**CHAOTIC** — No discernible cause and effect; turbulence.
- Novel practice. Act → Sense → Respond.
- Stabilize first, then move to another domain.
- Example: production outage with unknown root cause.

Which domain best describes this situation? Why?
Are you sure? People tend to default to Complicated (comfort with expertise).
If you're unsure between Complex and Complicated, it's probably Complex.

### 2. APPLY THE DOMAIN-APPROPRIATE APPROACH

**If CLEAR:** Apply the known best practice. Follow the process. Don't innovate where it's not needed.

**If COMPLICATED:** Bring in expertise. Analyze before acting. There are multiple valid solutions — find the best fit. Use structured analysis methods.

**If COMPLEX:** Run safe-to-fail probes (small experiments). Don't apply a solution — discover one. Amplify what works, dampen what doesn't. Embrace emergence.

**If CHAOTIC:** Act first to stabilize. Establish any order. Then sense what's happening and respond. Move toward Complex as fast as possible.

Common mistakes:
- Treating Complex as Complicated (analysis paralysis)
- Treating Clear as Complex (overthinking)
- Applying best practices to Chaotic situations (they don't apply yet)
- Not moving out of Chaotic fast enough

### 3. EVALUATE AND MONITOR
- Is the domain classification still correct, or has the situation shifted?
- Did the approach produce the expected results?
- Are you seeing signs that the domain is changing?
  - Clear → Complicated: edge cases emerging, rules failing
  - Complicated → Complex: experts disagreeing, novel patterns
  - Complex → Chaotic: rapid destabilization, cascading failures
  - Chaotic → Complex: order emerging, patterns becoming visible
- Set triggers for re-classification
- Document what you learned about the boundary conditions

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through each stage sequentially. At CLASSIFY THE SITUATION, use `ai_venice_web_search` to research the domain and understand the context.

## Alternative: IO Uncertainty
Cynefin classifies by cause-effect clarity, which is subjective and gameable. The `io-uncertainty-quadrant` framework classifies by observable properties (input/output determinism) instead. Consider it when you need classification based on testable properties rather than subjective judgment.

## Agent Rules


1. You MUST call `ai_venice_web_search` at least once before writing any classification or recommendation. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
7. Web research fallback chain (use in this strict order):
   (a) `ai_venice_web_search` — primary.
   (b) `webfetch` — if Venice returns rate-limit errors, fetch known URLs directly.
   (c) Playwright browser tools — if both above fail AND router grants exclusive browser access in your Task prompt. Playwright is single-threaded (one browser instance shared across all agents), so only use it when explicitly granted.
   All three methods require sequential execution — never run parallel agents doing web research.
   Treat Playwright results same as search results — cite URLs, never fabricate.
   Playwright is for WEB BROWSING ONLY — do NOT use `playwright_browser_run_code` or `playwright_browser_evaluate` to write files, run shell commands, or execute code. If asked to write a file, return the full content in your response instead.
