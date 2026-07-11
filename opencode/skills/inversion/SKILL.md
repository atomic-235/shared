---
name: inversion
description: Use when direct problem-solving is stuck, when risks are unclear, or when you need to avoid stupidity rather than seek brilliance. Inverts problems to identify and avoid failure paths instead of chasing success paths.
---

# Inversion Framework

Use this framework when direct problem-solving is stuck, when risks are unclear, or when you need to avoid stupidity rather than seek brilliance.

## Stages

### 1. INVERT THE PROBLEM
Instead of asking 'how do I succeed?', ask 'how would I guarantee failure?':
- What would make this project fail spectacularly?
- What behavior would guarantee a bad outcome?
- What's the worst possible approach, and what makes it the worst?
- If you wanted to destroy this system/relationship/product, how would you do it?
- What are all the ways this could go wrong?
- Be creative in your pessimism — enumerate failure modes, not success paths
- Charlie Munger: 'All I want to know is where I'm going to die, so I'll never go there.'

### 2. ANALYZE THE FAILURE PATHS
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to find real failure patterns. Do NOT rely on training data or fabricate sources.**
Understand what drives the failures you identified:
- Which failure modes are most likely? Rank them.
- Which failures would be most damaging? Rank them.
- Where do the high-likelihood AND high-damage failures overlap?
- Are any failure modes interdependent (one causes another)?
- What patterns do the failures share? (overconfidence, lack of feedback, rigidity)
- Search for case studies and post-mortems of similar failures
- Which failures are within your control vs. external?
- What early warning signs precede each failure?

### 3. AVOID THE FAILURE PATHS
Design your approach to steer clear of identified failures:
- For each high-priority failure mode, what specific action prevents it?
- What should you NOT do? Sometimes the best strategy is inaction.
- What habits, processes, or guardrails would make failure harder to achieve?
- Remove the enablers: what makes failure possible or easy? Eliminate those.
- Are there existing checklists, code reviews, or automated checks that catch these?
- Set up negative goals: 'I will not do X' is sometimes more powerful than 'I will do Y'
- Focus on avoiding stupidity rather than seeking brilliance

### 4. REINFORCE WITH POSITIVE STEPS
Now that you've eliminated failure modes, add positive direction:
- With the major failure paths blocked, what does success look like now?
- What positive actions complement the avoidance strategies?
- Where does inversion thinking leave gaps that direct thinking fills?
- Use both approaches: avoid failure AND pursue success.
- Document what you learned from inversion that you wouldn't see directly.
- Set up ongoing checks: how will you detect if you're drifting toward a failure mode?
- Review periodically: are new failure modes emerging as the situation evolves?

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through each stage sequentially. At ANALYZE THE FAILURE PATHS, use `ai_venice_web_search` to find real failure patterns and case studies.

## Agent Rules


1. You MUST call `ai_venice_web_search` during ANALYZE THE FAILURE PATHS. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
6. If `ai_venice_web_search` is rate-limited or returns errors, use Playwright browser tools as a fallback: `playwright_browser_navigate` to visit a search engine (e.g. https://duckduckgo.com/?q=QUERY), `playwright_browser_snapshot` to read results, `playwright_browser_click` to follow links, `playwright_browser_evaluate` to extract text. Treat Playwright results the same as search results — cite URLs, never fabricate.
