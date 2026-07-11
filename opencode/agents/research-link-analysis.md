---
description: Map and analyze entity relationships to reveal hidden connections, network structure, and patterns invisible in linear review. ALWAYS searches for known relationship patterns and additional entities. Use for due diligence, fraud detection, crypto wallet clustering, corporate ownership mapping, and supply chain analysis.
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

Load and follow the `link-analysis` skill. Apply the framework to the user's request. Return structured findings with sources.
