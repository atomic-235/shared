---
name: ach
description: Use when evaluating multiple competing explanations for ambiguous or complex evidence. Matrix-based multi-hypothesis evaluation that scores each piece of evidence against ALL hypotheses simultaneously to defeat confirmation bias. Developed by Richards J. Heuer Jr. (CIA, 1970s). Use for controversial issues, deception detection, or when premature closure on a single explanation is likely.
---

# Analysis of Competing Hypotheses (ACH)

Use this framework when you need to evaluate multiple competing explanations for ambiguous, complex, or contradictory evidence. ACH forces simultaneous evaluation of ALL plausible hypotheses against ALL evidence, defeating confirmation bias and premature closure.

Developed by Richards J. Heuer, Jr., a 45-year veteran of the CIA, in the 1970s. First described in *Psychology of Intelligence Analysis* (Center for the Study of Intelligence, 1999). The core insight: analysts naturally evaluate hypotheses one at a time, seeking confirming evidence for each. ACH inverts this — array evidence against all hypotheses simultaneously to see which hypotheses survive attempted disproof.

## Core Principle

**Focus on disproving, not proving.** The goal is to identify which hypotheses are inconsistent with the evidence, not to find evidence that supports a preferred hypothesis. Evidence that supports ALL hypotheses is diagnostically worthless — it doesn't help distinguish between them. Evidence that contradicts only ONE hypothesis is the most valuable.

## Stages

### 1. IDENTIFY ALL REASONABLE HYPOTHESES
**IMPORTANT: You MUST use `ai_venice_web_search` to research alternative explanations for the evidence. Do NOT rely on training data.**

- Brainstorm with diverse perspectives to identify ALL plausible explanations, not just the obvious ones
- Include the "null hypothesis" (nothing unusual is happening) if applicable
- Include deception/denial hypotheses if the evidence could be manipulated
- Do NOT stop at the first satisfactory explanation — force generation of alternatives
- Search for how others have explained similar evidence patterns
- The number of hypotheses should typically be 3–7; fewer risks missing alternatives, more becomes unwieldy

### 2. LIST ALL SIGNIFICANT EVIDENCE AND ARGUMENTS

- Gather ALL evidence relevant to ANY of the hypotheses — not just evidence supporting one view
- Include evidence of all types: direct observations, indirect indicators, absence of expected evidence, logical arguments, historical analogies
- Note the source, reliability, and potential for deception of each piece of evidence
- Do NOT filter evidence based on whether it fits a preferred hypothesis

### 3. BUILD THE ACH MATRIX

Create a matrix with:
- **Columns:** All hypotheses (H1, H2, H3...)
- **Rows:** Each piece of evidence (E1, E2, E3...)
- **Cells:** Score each piece of evidence against each hypothesis

**Scoring:**
- **C (Consistent):** The evidence is consistent with this hypothesis
- **I (Inconsistent):** The evidence contradicts this hypothesis
- **N (Neutral/Not Applicable):** The evidence has no bearing on this hypothesis

**Critical rule:** Score each piece of evidence against ALL hypotheses before moving to the next piece. Do NOT evaluate one hypothesis at a time — this defeats the purpose.

### 4. ANALYZE DIAGNOSTICITY

Identify which evidence is most valuable for distinguishing between hypotheses:
- **High diagnosticity:** Evidence that is consistent with only ONE hypothesis and inconsistent with others. This is the most valuable evidence.
- **Low diagnosticity:** Evidence that is consistent with ALL or most hypotheses. This evidence does NOT help distinguish between explanations — it may be interesting but is analytically worthless for hypothesis selection.
- **Inconsistent evidence:** Evidence that contradicts a hypothesis weakens or eliminates it, even if other evidence supports it.

### 5. ASSESS SENSITIVITY AND DECEPTION

- Identify which hypotheses are most sensitive to a few critical pieces of evidence
- Ask: "If this key piece of evidence is wrong, misleading, or deceptive, how does that change the conclusion?"
- Consider whether deception or denial could explain the absence of expected evidence
- Ask: "What evidence would we expect to see if this hypothesis were true, but we are NOT seeing?"

### 6. REFINE AND REPEAT

- Add new hypotheses that emerge from the evidence review
- Remove hypotheses that are clearly inconsistent with multiple pieces of evidence
- Re-examine evidence that was previously dismissed — it may be more relevant than initially thought
- Update the matrix as new evidence arrives
- Re-evaluate scores as evidence quality changes

### 7. REPORT CONCLUSIONS WITH UNCERTAINTY

- Rank hypotheses by relative likelihood based on consistency with evidence
- Report the strongest hypothesis AND the next-most-likely alternatives
- Identify which pieces of evidence would change the ranking if they proved wrong
- Note which hypotheses should still be monitored as new information becomes available
- Be explicit about confidence levels and what would change them

## Common Mistakes ACH Prevents

1. **First impression bias:** Analysts latch onto the first explanation that seems to fit
2. **Premature closure:** Analysts stop generating hypotheses once they find one that works
3. **Confirmation bias:** Analysts seek evidence that supports their preferred hypothesis while ignoring contradictory evidence
4. **Single-hypothesis evaluation:** Analysts evaluate hypotheses one at a time, making each seem plausible in isolation
5. **Overweighting supporting evidence:** Evidence that supports a preferred hypothesis but is also consistent with alternatives is given too much weight

## Scope and Limitations

**ACH works on:** Intelligence analysis, diagnostic reasoning, root cause analysis when multiple explanations are plausible, deception detection, complex decision-making with ambiguous evidence.

**ACH does NOT work on:** Situations with only one plausible explanation, purely quantitative problems, value-based decisions (where the issue is preference, not evidence evaluation), creative/artistic judgments.

**Limitations:**
- Requires sufficient evidence to distinguish hypotheses — if evidence is too sparse, ACH may not produce clear results
- Scoring can be subjective — different analysts may score the same evidence differently
- Does not handle probabilistic reasoning well — the matrix is binary (consistent/inconsistent), not probabilistic
- Can be time-consuming for complex issues with many hypotheses and evidence items
- Does not generate hypotheses — it only evaluates existing ones

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through each stage sequentially. At IDENTIFY ALL REASONABLE HYPOTHESES, use `ai_venice_web_search` to find alternative explanations. The matrix is the core tool — do not skip it. Focus on disproving hypotheses, not proving them. Evidence that is consistent with all hypotheses is diagnostically worthless — flag it as such.

## Agent Rules


1. You MUST call `ai_venice_web_search` at the IDENTIFY HYPOTHESES stage. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
