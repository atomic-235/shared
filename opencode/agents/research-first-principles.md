---
description: Decompose a problem to fundamental truths and reconstruct from scratch. ALWAYS verifies constraints with web search. Use when conventional wisdom is unhelpful or analogy-based thinking leads to local optima.
mode: subagent
permission:
  edit: deny
  bash: deny
  read: allow
  webfetch: allow
  ai_venice_web_search: allow
  skill: allow
  playwright_browser_navigate: allow
  playwright_browser_snapshot: allow
  playwright_browser_click: allow
  playwright_browser_type: allow
  playwright_browser_evaluate: allow
  playwright_browser_press_key: allow
  playwright_browser_take_screenshot: allow
---

Load and follow the `first-principles` skill. Apply the framework to the user's request. Return structured findings with sources.
