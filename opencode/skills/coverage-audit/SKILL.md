---
name: coverage-audit
description: Use when assessing whether a collection of frameworks provides complete coverage of a problem domain, finding gaps and overlaps, or evaluating whether a candidate framework justifies addition. Uses domain-referenced competency questions from ontology engineering to avoid self-referential bias. Two modes: full assessment (comprehensive audit) and candidate evaluation (should I add framework N+1?).
---

# Coverage Audit Framework

Use this framework when you need to assess whether a collection of problem-solving frameworks provides complete coverage of a problem domain. Identifies gaps (problem types with no framework), overlaps (redundant coverage), and evaluates whether candidate frameworks justify addition.

Synthesizes methods from ontology engineering (Competency Questions), requirements engineering (traceability matrix), and research methodology (gap taxonomy). The key insight from ontology engineering: derive test scenarios from the **problem domain**, not from existing frameworks, to avoid self-referential bias.

## Core Principle

**Don't derive your problem taxonomy from your existing frameworks — you'll never find gaps outside that space.** Instead, derive concrete test scenarios (Competency Questions) from the problem domain itself. Test each framework against those scenarios. Failures = real gaps.

Without CQs: "What do my frameworks cover?" → matrix → empty cells = gaps. But the taxonomy was shaped by the frameworks, so empty cells are only visible from inside the framework perspective.

With CQs: "What should my frameworks cover?" → domain-referenced test scenarios → test each framework → failures = gaps visible from outside the framework perspective.

## Two Modes

**Full Assessment Mode:** Comprehensive audit of entire framework collection. Use for initial setup, periodic review, or when problem domain has shifted.

**Candidate Evaluation Mode:** Lightweight evaluation of whether a proposed framework justifies addition. Use when considering adding framework N+1.

---

## Full Assessment Mode

### Stage 1: DOMAIN MAPPING
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to research problem taxonomies from multiple fields. Do NOT rely on training data.**
Goal: Decompose the problem-solving domain into fundamental problem types.

1. Identify dimensions along which problems vary. Search across multiple fields (not just software engineering) for problem taxonomies. Candidate dimensions:
   - **Complexity**: simple → complicated → complex → chaotic
   - **Certainty**: known → uncertain → deeply uncertain
   - **Scope**: individual → team → organizational → systemic
   - **Time horizon**: immediate → tactical → strategic → generational
   - **Stakeholder alignment**: single decision-maker → conflicting stakeholders → adversarial
   - **Problem phase**: identification → analysis → decision → implementation → learning
   - **Problem nature**: diagnostic → generative → optimization → adversarial → exploratory

2. Build a problem-type taxonomy by crossing these dimensions. Not every combination is meaningful — identify the problem types that actually occur in the target domain.

3. Search for problem taxonomies from fields outside your own (medicine, military strategy, urban planning, crisis management, product management, scientific research) to surface problem types you might not have considered.

4. Use `ai_venice_web_search` to find real-world problem scenarios that test the taxonomy's completeness.

Output: A taxonomy of problem types, each with a name, description, and distinguishing characteristics.

### Stage 2: COMPETENCY QUESTION DERIVATION
Goal: Derive concrete test scenarios from the domain — NOT from existing frameworks.

**Critical rule**: Competency questions must be derived from the problem domain, not from what existing frameworks can handle. If you derive them from existing frameworks, you'll never find gaps outside that space.

For each problem type, derive 2-3 competency questions using five types (adapted from ontology engineering CQ types):

- **Scoping questions (SCQ):** "Can the collection handle [problem type] at all?"
- **Validating questions (VCQ):** "Given [concrete scenario], which framework(s) apply and what do they produce?"
- **Foundational questions (FCQ):** "Does the collection assume [precondition] that may not always hold?"
- **Relationship questions (RCQ):** "When [framework A] and [framework B] both apply, how do they interact?"
- **Boundary questions (BCQ):** "What happens when a problem falls between [framework A]'s and [framework B]'s scope?"

Include at least one **adversarial competency question**: "Can the collection handle a problem where the assumptions of its primary frameworks are violated?"

Use `ai_venice_web_search` to find real-world problem scenarios in the target domain to ensure questions are grounded, not theoretical.

Output: A set of competency questions, each tagged with the problem type it tests.

### Stage 3: COVERAGE MAPPING
Goal: Map each framework against each problem type and competency question.

1. For each framework × problem type cell, assign:
   - **PRIMARY**: Framework was designed for this problem type
   - **SECONDARY**: Framework can be adapted to this problem type
   - **NO**: Framework does not address this problem type

2. For each competency question, identify which framework(s) would be invoked and what they would produce.

3. Identify **overlaps**: problem types where 3+ frameworks are PRIMARY (potential redundancy).

4. Identify **empty cells**: problem types where all frameworks are NO (coverage gap).

5. Identify **boundary problems**: competency questions where the answer is "framework A handles part, framework B handles part, but no framework handles the transition."

Output: A coverage matrix (problem types × frameworks) and a competency question test results table.

### Stage 4: GAP IDENTIFICATION AND CLASSIFICATION
Goal: Classify each identified gap by type (adapted from Miles' research gap taxonomy).

Gap types:
- **Coverage gap**: No framework addresses this problem type at all
- **Depth gap**: A framework is marked SECONDARY but only superficially addresses it — insufficient for real use
- **Redundancy gap**: Multiple frameworks cover the same space excessively (3+ PRIMARY)
- **Currency gap**: Framework exists but is outdated for current problem variants
- **Boundary gap**: Problem type falls between existing frameworks' scopes — no framework handles the transition
- **Assumption gap**: Frameworks exist but all share a common assumption that doesn't always hold (e.g., all assume rational actors)

Output: A classified gap list with severity indicators.

### Stage 5: GAP TRIAGE
Goal: Decide whether each gap justifies adding a new framework.

For each gap, evaluate:

1. **SEVERITY**: How often does this problem type occur? How impactful when it does?
   - High: Frequent + high impact → strong case for action
   - Medium: Occasional or moderate impact → case for monitoring
   - Low: Rare or low impact → can likely ignore

2. **COMBINABILITY**: Can existing frameworks in combination cover this?
   - YES: Two or more frameworks, used in sequence or parallel, can address the gap. Document the combination. No new framework needed.
   - PARTIAL: Combination covers most of the gap but leaves a residual. Assess whether the residual is severe enough to justify a new framework.
   - NO: No combination of existing frameworks addresses this. Strong case for a new framework.

3. **NOVELTY**: Would a new framework provide a genuinely different approach?
   - YES: Fundamentally different method (e.g., creative/divergent vs. analytical/convergent)
   - NO: Would rebrand or slightly modify what existing frameworks already do

4. **COST**: How complex is the new framework? Does it add cognitive load?
   - LOW: Simple, composable, integrates with existing frameworks
   - HIGH: Complex, requires extensive context, may conflict with existing frameworks

5. **DECISION**:
   - **ADD**: Gap is severe, not combinable, novel approach, acceptable cost
   - **COMBINE**: Gap is addressable by combining existing frameworks — document the combination
   - **MONITOR**: Gap exists but isn't severe enough to act now — revisit in next assessment
   - **IGNORE**: Not a real gap, out of scope, or already covered

Output: A triage decision for each gap, with justification.

### Stage 6: OUTPUT
Produce a structured coverage report:

1. **Coverage matrix**: Problem types × frameworks, with PRIMARY/SECONDARY/NO markers
2. **Competency question results**: Each CQ with the framework(s) that answer it and their output
3. **Gap report**: Classified gaps with severity
4. **Triage decisions**: ADD/COMBINE/MONITOR/IGNORE for each gap, with justification
5. **Overlap report**: Redundant coverage areas with recommendations for consolidation

---

## Candidate Evaluation Mode (Lightweight)

When someone proposes adding framework N+1:

1. **Classify**: What problem type(s) does the candidate address?
2. **Map**: Where does it fall in the existing coverage matrix?
3. **Test**: Can it answer competency questions that existing frameworks can't?
4. **Triage**: Apply gap triage criteria — does it fill a real gap, or is it redundant?
5. **Decide**: ADD / REJECT / DEFER

---

## How This Differs From Other Skills

- **vs. first-principles:** First-principles decomposes a specific problem to fundamentals. Coverage-audit uses first-principles for Stage 1 (domain decomposition) but adds CQ derivation, coverage mapping, gap classification, and triage that first-principles doesn't provide.
- **vs. systems-thinking:** Systems-thinking maps feedback loops and system dynamics. Coverage-audit maps framework coverage against problem types. Different domain, different output.
- **vs. ACH:** ACH evaluates competing hypotheses against evidence. Coverage-audit evaluates framework coverage against domain requirements. Different analytical structure.
- **vs. decision-record:** Decision-record documents a specific decision. Coverage-audit produces a coverage assessment and triage decisions. Complementary — use decision-record to document triage outcomes.

## Examples by Domain

### Framework Collection Audit (software + general problem-solving)
- Problem types: classification, decision, investigation, design, decomposition, optimization, adversarial, foresight, systems, entity-mapping
- CQ: "Can the collection handle a post-crisis learning phase where lessons must be captured and fed back into organizational preparedness?"
- Test: OODA handles the loop, but nothing handles institutional memory FROM past cycles
- Gap type: Coverage gap
- Triage: MONITOR — occurs after every crisis but not time-critical

### Medical Diagnosis Framework Coverage
- Problem type: Diagnostic reasoning under contradictory symptoms
- CQ: "A patient presents symptoms consistent with both disease A and disease B, which are mutually exclusive. Which framework helps resolve this?"
- Coverage: ACH handles competing hypotheses, but does anything handle the case where diagnostic frameworks themselves conflict?
- Gap type: Boundary gap

### Military Strategy Framework Coverage
- Problem type: Competitive resource allocation under adversarial pressure
- CQ: "Two opposing forces must allocate limited resources across multiple fronts simultaneously. Which framework handles game-theoretic resource allocation?"
- Coverage: TOC handles optimization, red-team handles adversarial, but neither handles the COMBINATION
- Gap type: Combinable — TOC + red-team in sequence may cover this

### Urban Planning Framework Coverage
- Problem type: Multi-stakeholder value conflict with long time horizons
- CQ: "A city must decide between economic development (short-term jobs) and environmental protection (long-term sustainability). Stakeholders have fundamentally conflicting values. Which framework handles value-conflict resolution?"
- Coverage: Systems-thinking handles interconnections, alternative-futures handles long-term, but neither resolves value conflicts between stakeholders
- Gap type: Coverage gap — or combinable if a negotiation/consensus framework exists outside the collection

## Scope and Limitations

**Works on:** Assessing framework collection coverage, evaluating candidate frameworks, periodic re-assessment of coverage as problem domains evolve, identifying redundant frameworks.

**Does NOT work on:**
- **Framework selection/routing** — this tells you what's COVERED, not what to USE for a specific problem. Framework routing is a separate concern.
- **Evaluating individual framework quality** — this assesses coverage, not quality. A framework can cover a problem type poorly.
- **Discovering completely unknown problem types** — CQs mitigate but cannot eliminate unknown unknowns (Rumsfeld's problem).

**Limitations:**
- **Bounded rationality**: The analyst doing the gap analysis is themselves bounded — they might not know what problem types exist. Web search mitigates but doesn't eliminate this.
- **Unknown unknowns**: By definition, you can't find what you don't know you don't know. CQs help surface these by forcing concrete scenario thinking, but cannot guarantee completeness.
- **Self-referential risk**: Even with CQs, the analyst's biases shape which questions they ask. Using multiple independent passes (different domain perspectives) mitigates this.
- **Taxonomy instability**: Problem types aren't cleanly defined. The taxonomy will have fuzzy boundaries. Some problems span multiple types.
- **Combinability is subjective**: Whether two frameworks "in combination" cover a gap is a judgment call.
- **Currency decay**: The coverage matrix is a snapshot. As problem domains evolve, gaps appear that didn't exist before. Periodic re-assessment is necessary.

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
**Full assessment:** Work through Stages 1-6 sequentially. At Stage 1, use `ai_venice_web_search` to research problem taxonomies from multiple fields. At Stage 2, search for real-world problem scenarios to ground competency questions. The CQ derivation (Stage 2) is the critical step — do not skip it. Without CQs, the analysis is circular.

**Candidate evaluation:** Use the 5-step lightweight mode. The key test: can the candidate answer competency questions that existing frameworks can't?

Pair with first-principles (Stage 1 decomposition), systems-thinking (Stage 1 interconnections), and decision-record (Stage 5 triage documentation).

## Agent Rules


1. You MUST call `ai_venice_web_search` at the DOMAIN MAPPING and COMPETENCY QUESTION DERIVATION stages. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
6. If `ai_venice_web_search` is rate-limited or returns errors, use Playwright browser tools as a SEQUENTIAL fallback: `playwright_browser_navigate` to visit a search engine (e.g. https://duckduckgo.com/?q=QUERY), `playwright_browser_snapshot` to read results, `playwright_browser_click` to follow links, `playwright_browser_evaluate` to extract text. Playwright is shared across all agents — do NOT use it if another agent may be using the browser simultaneously. Treat Playwright results the same as search results — cite URLs, never fabricate.
