---
name: scientific-method
description: Use when investigating unknowns, debugging complex issues, testing causal claims, or validating assumptions. Structures thinking through Observe, Question, Hypothesize, Research, Experiment, Analyze, and Conclude stages with mandatory web search for evidence.
---

# Scientific Method Framework

Use this framework when investigating unknowns, debugging complex issues, testing causal claims, or validating assumptions.

## Stages

### 1. OBSERVE
Gather raw facts without interpretation:
- What do you directly observe? (not assume, not infer)
- What data is available? What's missing?
- Can you reproduce the phenomenon reliably?
- Separate observations from conclusions
- Note anomalies and edge cases

### 2. QUESTION
Formulate a specific, testable question:
- What exactly are you trying to determine?
- Is this question specific enough to test?
- Are there multiple questions hidden in one?
- What would a definitive answer look like?
- Frame the question so evidence could disprove it

### 3. HYPOTHESIZE
Propose a falsifiable explanation:
- State the hypothesis clearly and specifically
- What prediction does this hypothesis make?
- What evidence would disprove it?
- Consider alternative hypotheses that explain the same observations
- Rank hypotheses by parsimony (Occam's Razor)

### 4. RESEARCH
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to find real evidence. Do NOT rely on training data or fabricate sources.**
- Search for peer-reviewed studies, meta-analyses, and systematic reviews
- Look for evidence that SUPPORTS the hypothesis
- Look for evidence that CONTRADICTS the hypothesis
- Assess source credibility (sample size, methodology, replication)
- Identify consensus vs. contradictions in the literature
- Cite specific sources with URLs

### 5. EXPERIMENT
Design and run a test that can falsify the hypothesis:
- What's the smallest experiment that could disprove the hypothesis?
- Control variables: what are you changing vs. holding constant?
- Can you isolate the variable you're testing?
- Document the procedure so it's reproducible
- Define success/failure criteria before running the experiment

### 6. ANALYZE
Interpret the experimental results:
- Do the results support or contradict the hypothesis?
- Are there confounding factors you didn't control for?
- Is the effect large enough to be meaningful, or just statistical noise?
- What assumptions did you make that need re-examining?
- Are there patterns in the data you didn't expect?

### 7. CONCLUDE
Draw conclusions and determine next steps:
- Summarize what was learned
- Confidence level: high / medium / low — and why?
- What new questions does this raise?
- Should you iterate (new hypothesis) or act on these findings?
- Document the conclusion so it can be built upon later

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.
- Cite only URLs that appear in `ai_venice_web_search` result snippets — never invent or guess URLs.

## Usage
Work through each stage sequentially. At the RESEARCH stage, you MUST use `ai_venice_web_search` to find real sources. Do not fabricate citations or rely on training data alone.

## Agent Rules


1. You MUST call `ai_venice_web_search` during the RESEARCH stage. No exceptions. Zero tolerance.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. NEVER cite studies, papers, or data unless they appear in `ai_venice_web_search` result snippets.
6. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
