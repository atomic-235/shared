---
name: premortem
description: Use before committing to a plan, at project kick-off, or when groupthink is suppressing risk awareness. Assumes failure has already happened and works backwards to identify causes and set tripwires.
---

# Pre-mortem Framework

Use this framework before committing to a plan, at project kick-off, or when groupthink is suppressing risk awareness.

## Stages

### 1. ASSUME FAILURE
It is 12 months from now. This project/decision has FAILED.
- What happened? Be specific. Write the failure story.
- How bad was it? What were the consequences?
- Was it a total failure or partial? What worked despite overall failure?
- Who noticed first? Who was surprised?
- Don't be optimistic here. Be vividly, specifically pessimistic.

### 2. IDENTIFY CAUSES
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to find real failure patterns. Do NOT rely on training data or fabricate sources.**
Working backwards from the failure:
- What was the single biggest cause of failure?
- What were contributing factors?
- Which causes were internal (controllable) vs. external?
- Were there early warning signs that were ignored?
- What assumptions turned out to be wrong?
- Search for post-mortems, case studies, and failure analyses of similar projects
- Were there resource constraints, skill gaps, or communication failures?

### 3. STRENGTHEN DEFENSES
For each identified cause, design a countermeasure:
- What specific action would prevent or mitigate this cause?
- Which countermeasures are cheap to implement now?
- Which require more investment? Are they worth it?
- Are there dependencies between causes that create cascade risks?
- Where does adding redundancy or backup plans help most?
- Prioritize: which failure mode is most likely AND most damaging?

### 4. SET TRIPWIRES
Establish early-warning systems:
- What measurable indicators would signal each failure mode is developing?
- Who is responsible for monitoring each indicator?
- What's the threshold that triggers action (not just concern)?
- What action is pre-committed when a tripwire fires?
- Set a calendar review: when will you re-evaluate the overall plan?
- Make tripwires visible — they're useless if forgotten

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through each stage sequentially. At IDENTIFY CAUSES, use `ai_venice_web_search` to find real failure patterns and post-mortems from similar projects.

## Agent Rules


1. You MUST call `ai_venice_web_search` during IDENTIFY CAUSES. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
6. If `ai_venice_web_search` is rate-limited or returns errors, use Playwright browser tools as a SEQUENTIAL fallback: `playwright_browser_navigate` to visit a search engine (e.g. https://duckduckgo.com/?q=QUERY), `playwright_browser_snapshot` to read results, `playwright_browser_click` to follow links, `playwright_browser_evaluate` to extract text. Playwright is shared across all agents — do NOT use it if another agent may be using the browser simultaneously. Treat Playwright results the same as search results — cite URLs, never fabricate.
