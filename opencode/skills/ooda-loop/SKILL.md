---
name: ooda-loop
description: Use in fast-moving, dynamic, or adversarial situations where speed of iteration matters more than perfect analysis. Implements Observe-Orient-Decide-Act cycles for rapid iterative decision-making.
---

# OODA Loop Framework

Use this framework in fast-moving, dynamic, or adversarial situations where speed of iteration matters more than perfect analysis.

## Stages

### 1. OBSERVE
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to gather current intelligence. Do NOT rely on training data or fabricate sources.**
Gather information about the current situation:
- What is happening right now? (facts, not interpretations)
- What data points are available?
- What changed recently? What's different from before?
- What are others (competitors, systems, users) doing?
- Search for current information, recent developments, and real-time data
- What information is still missing that you need?
- Speed matters: get enough info to act, don't wait for perfection

### 2. ORIENT
Make sense of observations in context:
- How do these observations fit with your mental models?
- What patterns do you recognize? What's novel?
- What biases might be distorting your interpretation?
- What are the implications? What could this mean?
- Update your mental model: what assumptions need revising?
- What's the tempo? How fast is the situation changing?

### 3. DECIDE
Choose a course of action:
- What hypothesis are you testing with this action?
- Is this the smallest action that generates useful information?
- What are the risks? Can you limit downside?
- Decide quickly — a good plan now beats a perfect plan later
- You can always re-orient and decide again
- Avoid decision paralysis: prefer reversible, incremental actions

### 4. ACT
Execute the decision and observe results:
- Execute decisively — hesitation wastes the OODA advantage
- What feedback should you watch for?
- How will you know if the action succeeded or failed?
- Feed results directly back into Observe
- Did your action change the situation? How?
- Faster OODA loops = more learning per unit time

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
The OODA loop is iterative. After Act, return to Observe. Multiple cycles are expected. At OBSERVE, use `ai_venice_web_search` to gather current intelligence and stay informed about rapid changes.
