---
description: Classify problems using the IO Uncertainty matrix (deterministic/probabilistic input x deterministic/probabilistic output) across problem, process, and environment layers. Prescribes matching validation strategies per quadrant. ALWAYS searches for current practices. Use when choosing testing, validation, or decision-making approaches for a problem with unclear uncertainty structure.
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

Load and follow the `io-uncertainty-quadrant` skill. Apply the framework to the user's request. Return structured findings with sources.
