---
description: Classify a problem using the Cynefin framework. ALWAYS searches the web before classifying. Use when unsure what kind of problem you are dealing with or when the same approach keeps failing.
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

Load and follow the `cynefin` skill. Apply the framework to the user's request. Return structured findings with sources.
