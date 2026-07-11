---
name: alternative-futures
description: Use when facing high complexity and uncertainty about how a situation will develop, when you need to explore multiple plausible futures rather than betting on one outcome. Systematically generates a range of scenarios from key drivers, ranks them by likelihood and impact, and develops indicators to detect which future is emerging. A structured scenario planning technique from CIA tradecraft (Peter Schwartz, Royal Dutch Shell).
---

# Alternative Futures Analysis

Use this framework when a situation is too complex or outcomes too uncertain to trust a single forecast. Generates multiple plausible futures rather than predicting one outcome.

From *A Tradecraft Primer: Structured Analytic Techniques for Intelligence Analysis* (CIA, 2009). Methodology draws on Peter Schwartz's *The Art of the Long View* — the "scenaric" approach pioneered at Royal Dutch Shell for making strategic decisions sound across "all plausible futures."

## Core Principle

**The future is plural.** Don't predict one outcome — explore a range of plausible futures, identify indicators for each, and design strategies that work across multiple scenarios. This is divergent thinking, not convergent. The goal is not to pick the most likely future but to prepare for all of them.

Contrast with contrarian techniques (Red Team, Devil's Advocacy) which challenge high confidence. Alternative Futures is used when confidence is low and uncertainty is high.

## Stages

### 1. DEFINE THE FOCAL ISSUE
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to research the domain and key forces. Do NOT rely on training data.**
- What is the specific question or decision this analysis will inform?
- What timeframe? (Near-term: 1-2 years. Mid-term: 3-5 years. Long-term: 5-20+ years)
- What geographic, organizational, or systemic scope?
- Who are the stakeholders / decision-makers?
- Search for existing scenario analyses, forecasts, and expert perspectives on this issue
- The focal issue should be specific enough to drive action, broad enough to capture key uncertainties

### 2. IDENTIFY KEY DRIVERS AND FORCES
Brainstorm all forces and factors that could affect the focal issue:
- **Political/regulatory:** elections, policy changes, regulations, geopolitical shifts
- **Economic:** growth rates, inflation, trade patterns, market disruptions
- **Technological:** breakthroughs, adoption curves, infrastructure changes, cost curves
- **Social:** demographics, cultural shifts, consumer behavior, public opinion
- **Environmental:** climate, resource availability, natural disasters
- **Organizational:** leadership changes, mergers, restructuring, capability shifts

For each driver, assess:
- **Impact:** How strongly does this driver affect the focal issue? (High / Medium / Low)
- **Uncertainty:** How predictable is this driver? (High uncertainty / Low uncertainty)

Separate:
- **Certainties** (high impact, low uncertainty) — these go into ALL scenarios as assumptions
- **Critical uncertainties** (high impact, high uncertainty) — these become scenario axes
- **Secondary drivers** (low impact) — mention but don't build scenarios around

### 3. SELECT THE TWO MOST CRITICAL UNCERTAINTIES
- Choose the two drivers with the HIGHEST impact AND HIGHEST uncertainty
- These become the X and Y axes of a 2×2 scenario matrix
- Define endpoints for each axis:
  - Endpoints should be plausible extremes, not impossible extremes
  - Example: "fast economic growth" vs "stagnation" (not "utopia" vs "collapse")
  - Example: "strict regulation" vs "deregulation"
  - Example: "rapid AI adoption" vs "AI winter"
- If more than two critical uncertainties exist, choose the two most impactful. Document the others as secondary forces that vary within scenarios.

### 4. BUILD THE 2×2 SCENARIO MATRIX
Cross the two axes to create four quadrants. Each quadrant is a distinct plausible future:

```
                    Axis 2: Endpoint A
                         |
              Scenario 1 | Scenario 2
                         |
    -------- Axis 1 -----+----- Axis 1
              Endpoint A  |  Endpoint B
                         |
              Scenario 3 | Scenario 4
                         |
                    Axis 2: Endpoint B
```

### 5. DEVELOP SCENARIO NARRATIVES
For each quadrant, write a detailed narrative:
- **What happened?** How did we get to this future? (Work backward from the endpoint)
- **What does this world look like?** Key actors, relationships, power dynamics
- **How does this affect the focal issue?** Direct impacts, second-order effects
- **Who wins? Who loses?** Stakeholder analysis for this scenario
- **What surprised us?** What happened that conventional wisdom didn't predict?

Rules:
- Scenarios must be PLAUSIBLE — not preferable, not dystopian, not utopian
- Each scenario should be internally consistent
- Name each scenario memorably (e.g., "Silicon Spring," "Fragmented Freeze," "Regulatory Hammer," "Quiet Revolution")
- Include "wild cards" — discontinuous events that could occur in any scenario

### 6. RANK SCENARIOS BY LIKELIHOOD AND IMPACT
- Estimate relative likelihood (not absolute probability — these are uncertain by definition)
- Assess impact on your objectives for each scenario
- Identify which scenarios require preparation regardless of likelihood (high impact)
- No scenario should be dismissed — even low-likelihood scenarios matter if impact is high

### 7. DEVELOP INDICATORS FOR EACH SCENARIO
For each scenario, identify observable indicators that would signal this future is emerging:
- **Early indicators:** Signs the preconditions are developing (1-3 years ahead)
- **Mid-stage indicators:** Signs the scenario is becoming more likely (6-18 months ahead)
- **Late indicators:** Signs the scenario is imminent (0-6 months ahead)
- Distinguish between indicators unique to one scenario vs. indicators common to multiple scenarios
- Unique indicators are most valuable — they tell you WHICH future is emerging
- Use `ai_venice_web_search` to find existing indicators or metrics being tracked in this domain

### 8. TEST CURRENT STRATEGIES AGAINST ALL SCENARIOS
- How does your current plan/strategy perform in each of the four futures?
- Which scenarios does your plan handle well? Which expose vulnerabilities?
- **Robust strategies:** Actions that improve your position across MULTIPLE scenarios. Prioritize these.
- **Betting strategies:** Actions that are only valuable in one specific scenario. Use sparingly.
- **Hedging strategies:** Actions that limit downside in worst-case scenarios. Insurance.
- What early actions would improve your position regardless of which future emerges?

### 9. MONITOR AND UPDATE
- Periodically review the indicators list (monthly, quarterly, or as events warrant)
- Which indicators are appearing? Which scenario is becoming more likely?
- Update scenarios as new information arrives
- Add new drivers that emerge; remove drivers that resolve
- Re-rank scenarios as conditions change
- Scenarios go stale — refresh annually or when major events occur

## How This Differs From Other Skills

| Skill | Difference |
|---|---|
| **high-impact-low-probability** | HILP explores ONE unlikely catastrophic outcome. Alternative Futures explores a RANGE of plausible futures (likely AND unlikely, positive AND negative). |
| **premortem** | Premortem assumes ONE failure scenario, works backward to causes. Alternative Futures generates multiple scenarios including success. |
| **systems-thinking** | Systems Thinking maps CURRENT system structure (feedback loops, stocks, flows). Alternative Futures generates FUTURE scenarios. |
| **wrap** | WRAP bookends with best/worst case (2 endpoints). Alternative Futures generates 4+ structured scenarios with narratives and indicators. |
| **ooda-loop** | OODA is fast iterative decisions for dynamic situations. Alternative Futures is deliberate long-term planning under uncertainty. |
| **red-team** | Red Team attacks a specific plan from adversarial perspective. Alternative Futures explores what the world might look like. |
| **ach** | ACH evaluates hypotheses against current evidence. Alternative Futures generates scenarios about future states. |

## Examples by Domain

**Technology strategy (AI landscape in 3 years):**
- Focal issue: How should we position our product for the AI market in 2029?
- Key drivers: regulatory action (high impact, high uncertainty), capability breakthroughs (high impact, high uncertainty), adoption rate (high impact, low uncertainty — growing), compute cost (medium impact, low uncertainty — declining)
- Two critical uncertainties: regulatory strictness × capability frontier
- Four scenarios: "Silicon Spring" (light regulation, rapid breakthroughs), "Regulatory Hammer" (strict regulation, rapid breakthroughs), "Quiet Consolidation" (light regulation, plateaued capabilities), "AI Winter Returns" (strict regulation, plateaued capabilities)
- Indicators: regulatory bill drafts, model capability benchmarks, venture funding trends, enterprise adoption surveys

**Career planning (industry in 10 years):**
- Focal issue: Should I specialize in this field or diversify?
- Key drivers: automation displacement, industry consolidation, skill demand shifts, geographic shifts
- Scenarios: "Automated Away" (high automation, high consolidation), "Augmented Excellence" (high automation, fragmented), "Human Premium" (low automation, fragmented), "Slow Squeeze" (low automation, high consolidation)
- Test: does specialization survive in all four? Diversification? Which strategy is robust?

**Investment decisions (energy sector):**
- Focal issue: Where to allocate energy investments over 5 years?
- Key drivers: policy changes, technology cost curves, demand shifts, geopolitical events
- Scenarios: "Green Acceleration" (pro-renewable policy, cost parity achieved), "Fossil Resurgence" (anti-renewable policy, cost parity delayed), "Fragmented Transition" (mixed policy, uneven progress), "Black Swan Energy" (major disruption — war, breakthrough, or disaster)
- Robust strategy: diversified portfolio with both renewable and traditional assets. Betting strategy: all-in on renewables.

## Scope and Limitations

**Works on:** Strategic planning under high uncertainty, technology forecasting, market analysis, career planning, investment strategy, policy planning, geopolitical analysis, any situation with multiple plausible futures and high complexity.

**Does NOT work on:**
- **Situations with one clearly likely outcome** — if you can forecast confidently, just do that. Don't overcomplicate.
- **Short-term tactical decisions** — too slow for operational choices. Use OODA instead.
- **Problems with clear cause-effect** — use scientific-method or research-debug.
- **Values-based decisions** — "Should I take this job?" Use WRAP or decision-record.
- **Crisis response** — use OODA or premortem instead.

**Limitations:**
- Scenarios are speculative — plausible, not predictive. Do not treat any scenario as a forecast.
- The 2×2 matrix is a simplification. Real futures may not fit neatly into four quadrants.
- Analysts may anchor on the most dramatic scenario rather than the most likely.
- Requires periodic review — one-time analysis is insufficient. Scenarios go stale.
- Can produce "analysis paralysis" if too many scenarios are generated. Stick to 4-6.
- Identifying the "right" key drivers is the hardest step — garbage in, garbage out.
- Does not prescribe action — it prepares you for multiple futures but doesn't tell you which to bet on.

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through stages sequentially. At DEFINE THE FOCAL ISSUE, use `ai_venice_web_search` to research existing forecasts and expert perspectives. At DEVELOP INDICATORS, search for existing metrics tracked in this domain. The 2×2 matrix is the core tool — do not skip it. Multiple scenarios are the output, not a single forecast. Test your current strategy against ALL scenarios, not just the most likely one.

## Agent Rules


1. You MUST call `ai_venice_web_search` at the DEFINE FOCAL ISSUE and DEVELOP INDICATORS stages. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
6. If `ai_venice_web_search` is rate-limited or returns errors, use Playwright browser tools as fallback: `playwright_browser_navigate` to visit a search engine (e.g. https://duckduckgo.com/?q=QUERY), `playwright_browser_snapshot` to read results, `playwright_browser_click` to follow links, `playwright_browser_evaluate` to extract text. The router grants you exclusive browser access — if your Task prompt says "You have exclusive browser access", use Playwright freely. If it says "Do NOT use Playwright", stick to web_search/webfetch only. Treat Playwright results the same as search results — cite URLs, never fabricate.
