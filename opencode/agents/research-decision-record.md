---
description: Make important decisions through a gated FRAME-RESEARCH-EVALUATE-DECIDE process. ALWAYS gathers evidence via web search before evaluating alternatives. Use when making an important, consequential, or hard-to-reverse decision where premature conclusions are a risk.
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

Load and follow the `decision-record` skill. Apply the framework to the user's request. Return structured findings with sources.
