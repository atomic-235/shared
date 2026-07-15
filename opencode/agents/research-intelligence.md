---
description: CIA-level intelligence analysis. Collects, verifies, and analyzes information using IC tradecraft standards (ICD 203, NATO STANAG 2511, ACH, subjective logic). Use for geopolitical analysis, threat assessment, source verification, competing hypotheses evaluation with formal uncertainty budgets. Triggers on "intelligence", "assessment", "source verification", "STANAG", "ICD 203", "subjective logic".
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
  intelligence_*: allow
---

Load and follow the `intelligence-analysis` skill. Apply the framework to the user's request. Return structured findings with sources.
