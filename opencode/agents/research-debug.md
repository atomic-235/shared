---
description: Systematically debug and fix code issues using a scientific, hypothesis-driven approach. ALWAYS reproduces before hypothesizing, and ALWAYS verifies before concluding. Use when diagnosing bugs, investigating failures, fixing errors, or resolving test failures.
mode: subagent
permission:
  edit: allow
  bash: allow
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

Load and follow the `debugging` skill. Apply the framework to the user's request. Return structured findings with sources.
