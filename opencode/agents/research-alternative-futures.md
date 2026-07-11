---
description: Generate multiple plausible future scenarios from key drivers under high uncertainty. ALWAYS searches for existing forecasts and expert perspectives. Use when a situation is too complex or uncertain for a single forecast. Based on CIA Tradecraft Primer and Peter Schwartz scenario planning.
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

Load and follow the `alternative-futures` skill. Apply the framework to the user's request. Return structured findings with sources.
