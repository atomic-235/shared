---
name: research-ppdac
description: Use when answering questions with data — statistical inquiry, data analysis, or empirical investigation. Structures thinking through Problem, Plan, Data, Analysis, and Conclusion as a cyclical process. Use when you need to know something, not when you need to fix something.
---

# PPDAC Framework

Use this framework when answering questions with data — statistical inquiry, data analysis, or empirical investigation.

Based on Wild & Pfannkuch's (1999) PPDAC model, popularized by David Spiegelhalter in *The Art of Statistics*. The standard framework for statistical literacy and data-driven inquiry.

## When to Use This vs. Other Skills

- **PPDAC** → Data-driven inquiry: "What does the data tell me?"
- **Pólya** → Pure reasoning: "How do I derive this from what's given?"
- **Scientific Method** → Causal investigation: "Does X cause Y?"
- **DMAIC** → Process improvement: "How do I fix this broken process?"

PPDAC addresses a *need to know* — it's epistemic. It starts with a question, not a defect.

## Stages (Cyclical)

### 1. PROBLEM
Define the question that data can answer:
- What exactly do you want to know? Be specific.
- Is this a question data can answer, or does it require a different approach?
- Who is the audience for the answer? What do they need to understand?
- What's the population of interest? What's the scope?
- Is this a descriptive question ("how much?"), a comparative question ("is A different from B?"), or a relational question ("is X associated with Y?")?
- Separate the substantive question from the statistical question
- Can you refine a vague question into a precise, answerable one?
- What would a complete answer look like?

### 2. PLAN
Design how to get the data and what to do with it:
- What variables do you need to measure? How will you define them operationally?
- What's the study design? Observational? Experimental? Survey? Administrative data?
- How will you sample? Random? Stratified? Convenience? What biases does this introduce?
- What's the sample size needed? (Power analysis if testing hypotheses)
- What are potential confounders? How will you control for them?
- What measurement instruments or tools will you use? Are they validated?
- What analysis methods are appropriate for this data and question?
- Ethical considerations: consent, privacy, anonymity
- Iterate: the plan may need revision as you think through later stages

### 3. DATA
Collect, clean, and organize the data:
- Collect the data according to the plan (or acquire existing datasets)
- **Data cleaning** — the unglamorous 80% of the work:
  - Handle missing values: drop, impute, or flag?
  - Detect and handle outliers: legitimate or errors?
  - Check data types: are dates dates? Are numbers numbers?
  - Verify ranges: are values physically possible?
  - Check consistency: do related variables agree?
  - Document every cleaning decision
- **Exploratory data analysis (EDA)**:
  - Summary statistics: mean, median, sd, quartiles
  - Distributions: histograms, density plots, Q-Q plots
  - Relationships: scatter plots, cross-tabulations, correlation matrices
  - Time trends if applicable
  - Look for patterns AND for the absence of expected patterns
- If the data doesn't match the plan, return to Plan stage

### 4. ANALYSIS
Extract meaning from the data — this is where the statistical machinery operates:
- Apply the methods planned in Stage 2
- **Descriptive analysis**: Summarize what you observe
  - Central tendency, dispersion, shape of distributions
  - Cross-tabulations and group comparisons
  - Effect sizes — not just p-values
- **Inferential analysis**: Generalize beyond the data
  - Confidence intervals (preferred over bare p-values)
  - Hypothesis tests — state null and alternative explicitly
  - Regression models: which variables matter and how much?
  - Check model assumptions: normality, homoscedasticity, independence
- **Sensitivity analysis**: How robust are the conclusions?
  - Do results change with different assumptions?
  - What if you exclude outliers? Use different models?
  - Multiple comparisons correction if testing many hypotheses
- **Visualization**: Communicate analysis clearly
  - Choose chart types that match the question
  - Avoid misleading scales, truncated axes, dual y-axes
  - Show uncertainty (confidence bands, error bars)
- If the analysis reveals data quality issues, return to Data stage
- If the analysis shows the question was wrong, return to Problem stage

### 5. CONCLUSION
Answer the original question and communicate findings:
- Answer the question from Stage 1 — directly and clearly
- Quantify uncertainty: "We estimate X with 95% CI [a, b]" not just "X is significant"
- Distinguish statistical significance from practical significance
- What are the limitations of this analysis?
  - Selection bias? Confounding? Measurement error?
  - Observational data can show association, not causation
  - Small sample → wide uncertainty
- What assumptions were necessary? Which are most fragile?
- What new questions does this analysis raise? (Feed back to Problem → next cycle)
- Communicate appropriately for the audience:
  - Technical audience: methods, assumptions, diagnostics
  - General audience: key finding, practical implication, confidence level
  - Always: what the data says AND what it doesn't say

## The Cyclical Nature

PPDAC is NOT a linear pipeline — it's a cycle with feedback loops:
- **Problem → Plan**: The question constrains the design. A poorly defined question produces useless data.
- **Plan → Data**: Reality rarely matches the plan. Adapt, but document deviations.
- **Data → Analysis**: Dirty data produces garbage conclusions. Clean first, analyze second.
- **Analysis → Conclusion**: Analysis may reveal the original question was wrong or too vague.
- **Conclusion → Problem**: Every good answer raises new questions. The next cycle begins.

A single PPDAC iteration often generates as many new questions as it answers — this is a feature, not a bug.

## Common Pitfalls

- **Fishing expedition**: Collecting data first, then looking for "interesting" results → multiple testing problem, spurious findings
- **Confounding vs. Causation**: Observational data shows association. Only randomization demonstrates causation.
- **Ecological fallacy**: Group-level patterns don't apply to individuals
- **Survivorship bias**: Only analyzing data from "survivors" (completed programs, successful companies) while ignoring those that dropped out
- **P-hacking**: Re-running analyses until p < 0.05. Pre-register hypotheses when possible.
- **Overfitting**: Complex models that fit noise in the training data but fail on new data. Validate with held-out data.

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through each stage sequentially, but expect to iterate. The cycle is essential — conclusions that don't answer the original problem mean you need another iteration. Start with Problem, and ensure every subsequent stage traces back to that original question.
