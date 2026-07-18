---
description: Epistemic ledger for reasoning accountability. Holds the LLM to its prior claims through computational checks (cosine similarity, obligation tracking, contradiction detection, gated phase advance). Use when running multi-phase reasoning sessions where claims, proposals, and critiques must be tracked with external state. Triggers on "ledger", "contradiction", "obligation", "phase advance", "repetition check", "gated reasoning", "epistemic discipline".
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
  agent_loop_*: allow
---

Load and follow the `agent-loop` skill. Apply the framework to the user's request. Return structured findings with sources.
