---
name: wrap
description: Use when facing an important decision with a tendency toward narrow framing, confirmation bias, emotional reasoning, or overconfidence. Implements Widen options, Reality-test assumptions, Attain distance, Prepare to be wrong.
---

# WRAP Framework

Use this framework when facing an important decision with a tendency toward narrow framing, confirmation bias, emotional reasoning, or overconfidence.

## Stages

### 1. WIDEN YOUR OPTIONS
Avoid narrow framing (should I do X or not?). Instead:
- Is this a 'whether or not' decision? Reframe it as 'what are my options?'
- Use vanishing options: if your current choices disappeared, what else could you do?
- Look for bright spots: who has already solved this? What can you emulate?
- Consider opportunity cost: what are you giving up by choosing this?
- Try 'this AND that' instead of 'this OR that'
- Generate at least 3 options before deciding

### 2. REALITY-TEST YOUR ASSUMPTIONS
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to find disconfirming evidence. Do NOT rely on training data or fabricate sources.**
Fight confirmation bias — the tendency to seek information that supports your lean:
- What would you need to see to change your mind?
- What are the strongest arguments AGAINST your preferred option?
- Can you test your assumptions with a small experiment or prototype?
- Search for evidence that contradicts your preferred option
- Seek disconfirming evidence as actively as confirming evidence
- Ask: 'What if the opposite were true?'
- Talk to people who disagree with you and truly listen
- **Classify uncertainty**: Use the `io-uncertainty-quadrant` framework to determine what kind of test to run. Classify your input (deterministic or probabilistic?) and output (deterministic or probabilistic?) across problem, process, and environment layers to select the right validation strategy: assertion (det/det), reproducibility (det/prob), fuzzing (prob/det), or holdout validation (prob/prob).

### 3. ATTAIN DISTANCE BEFORE DECIDING
Overcome short-term emotion that distorts judgment:
- 10/10/10: How will you feel about this 10 minutes from now? 10 months? 10 years?
- What would you advise your best friend to do in this situation?
- What does your core identity or long-term values suggest here?
- Are you deciding based on fear, pride, or attachment?
- Sleep on it if possible — distance reduces emotional distortion

### 4. PREPARE TO BE WRONG
Plan for the range of possible outcomes, not just the expected one:
- Bookend the future: what's the best case? What's the worst case?
- Set tripwires: what early warning signs would trigger a re-evaluation?
- Pre-commit to a re-evaluation date or condition
- What's your Plan B if this doesn't work?
- Use a safety factor: can you partially commit and scale up?
- Trust the process even if the outcome is uncertain

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through each stage sequentially. At REALITY-TEST YOUR ASSUMPTIONS, use `ai_venice_web_search` to find disconfirming evidence and challenge your assumptions.

## Agent Rules


1. You MUST call `ai_venice_web_search` during REALITY-TEST YOUR ASSUMPTIONS. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
