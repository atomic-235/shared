---
name: decision-record
description: Use when making an important, consequential, or hard-to-reverse decision. Enforces that decisions cannot be made without first framing the question, researching the context, and evaluating alternatives. Produces a structured decision record capturing context, alternatives, rationale, and consequences.
---

# Decision Record Framework

Use this framework when making an important, consequential, or hard-to-reverse decision. It enforces that you cannot decide without first completing prerequisite work: framing the question, researching the context, and evaluating alternatives.

## Stages

### 1. FRAME
Define the decision before you can make it:
- What exactly is being decided? Write it as a clear question
- Why does this decision need to be made now? What's driving it?
- What's in scope and out of scope?
- Who is affected? Who are the stakeholders?
- What are the decision drivers (constraints, quality attributes, deadlines)?
- How reversible is this decision? What's the cost of being wrong?
- What information must you have BEFORE you can make this decision? List the prerequisites
- What criteria will you use to evaluate alternatives?

**You cannot proceed to RESEARCH until you can clearly state what you're deciding and why.**

### 2. RESEARCH
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to gather evidence. Do NOT rely on training data or fabricate sources.**
Gather the prerequisite information identified in FRAME:
- What constraints exist (technical, organizational, regulatory, budgetary)?
- What do you actually know vs. what do you assume? Verify assumptions
- What have others done in similar situations? Search for precedents, case studies, and existing solutions
- What does the documentation say? Check specs, APIs, benchmarks, compatibility matrices
- What are the dependencies? What must be true for each option to work?
- What don't you know yet? Identify gaps and search for answers
- What would an expert or stakeholder tell you? Seek perspectives you're missing

**You cannot proceed to EVALUATE until the prerequisite information from FRAME is gathered. If critical information is unavailable, document that as a risk.**

### 3. EVALUATE
Consider alternatives with evidence-based trade-off analysis:
- Identify at least 3 options (including "do nothing" / status quo if applicable)
- For each option: what are the pros and cons? What evidence supports each?
- Compare options against the decision criteria from FRAME
- What are the consequences (positive and negative) of each option?
- Which options are eliminated by hard constraints? Which survive?
- What are the trade-offs between the surviving options?
- What would you LOSE by choosing each option? What do you give up?
- Search for disconfirming evidence: what's wrong with your preferred option?
- What early warning signs would indicate a wrong choice?

**You cannot proceed to DECIDE until you have at least 2 viable alternatives analyzed with trade-offs documented. If you have only one option, the decision is already made — reconsider whether you've actually explored alternatives.**

### 4. DECIDE
Make the decision and produce a structured decision record:
- State the decision clearly: "We will [chosen option]"
- Why this option? Summarize the rationale
- What alternatives were considered and why were they not chosen?
- What are the accepted consequences (positive and negative)?
- What conditions would trigger revisiting this decision? Set tripwires
- What is the confidence level (high / medium / low) and why?
- What risks remain? What mitigation is planned?

**Decision Record Format:**

```
# [Title]

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Context
[Why this decision is needed. What's the situation, drivers, and constraints.]

## Decision
[What was decided. Be specific.]

## Alternatives Considered
[Each alternative with brief pros/cons and why it was not chosen.]

## Consequences
### Positive
[Benefits of this decision.]

### Negative
[Trade-offs, risks, and downsides accepted.]

### Risks & Tripwires
[What could go wrong. What would trigger re-evaluation.]
```

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through each stage sequentially. You MUST NOT skip stages or jump to DECIDE without completing FRAME, RESEARCH, and EVALUATE. At RESEARCH, use `ai_venice_web_search` to gather evidence. At EVALUATE, search for disconfirming evidence. The output of this process is a structured decision record that can be stored alongside code or in a decision log.
