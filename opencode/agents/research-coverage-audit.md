---
description: Audit framework collection coverage and evaluate candidate frameworks. Uses domain-referenced competency questions from ontology engineering to avoid self-referential bias. Two modes: full assessment (comprehensive audit) and candidate evaluation (should I add framework N+1?). ALWAYS searches for problem taxonomies from multiple fields.
mode: subagent
permission:
  edit: deny
  bash: deny
  read: allow
  webfetch: allow
  ai_venice_web_search: allow
  skill: allow
---

Load and follow the `coverage-audit` skill. Apply the framework to the user's request. Return structured findings with sources.
