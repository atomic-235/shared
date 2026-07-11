---
name: io-uncertainty-quadrant
description: Use when you need to determine what kind of problem you're facing based on input/output determinism. Classifies problems on a 2D matrix (deterministic/probabilistic input x deterministic/probabilistic output) and prescribes matching validation strategies. Separates problem from process. Replaces subjective classifications like Cynefin with observable axes. Use before choosing testing, validation, or decision-making approaches.
---

# IO Uncertainty Quadrant Framework

Use this framework to classify problems based on the determinism of their input and output. Unlike Cynefin (which classifies by subjective cause-effect relationships), this framework classifies by **observable properties**: is your input deterministic or probabilistic? Is your output?

## Core Principle

Classification should be based on **observable properties of the system**, not subjective judgments about cause-effect clarity. "Is my input deterministic?" is answerable by looking at the system. "Is this Complex or Complicated?" is answerable only by opinion — and gameable by motivated reasoning.

---

## Quick Path: Classify and Validate

If your problem is straightforward, classify on two axes and pick a validation strategy. Done in 30 seconds.

**Input axis**: "Do I know the exact input, and is it the same every time?"
**Output axis**: "Do I know the exact output, and is it the same every time for the same input?"

| | **Output deterministic** | **Output probabilistic** |
|---|---|---|
| **Input deterministic** | **det/det** — Assert correctness. Unit tests, proofs. | **det/prob** — Check reproducibility. Multiple runs, variance analysis. |
| **Input probabilistic** | **prob/det** — Test robustness. Fuzzing, property-based testing. | **prob/prob** — Validate on holdout. Cross-validation, OOD testing. |

Quick examples: `add(2,3)` → det/det. API endpoint → prob/det. ML training → prob/prob. Monte Carlo → det/prob.

**If the quick path gives you a clear answer, stop here.** The sections below are for when the classification is ambiguous, the problem spans multiple contexts, or you want to analyze whether you can move to a cheaper quadrant.

---

## What "Probabilistic" Means

"Probabilistic" does NOT only mean "random." It means **we cannot pin the value to a single known exact value.** There are two sources:

**Aleatory uncertainty** — inherent randomness. The value actually varies across runs.
- User behavior, sensor noise, network latency, quantum effects
- Validation: run multiple times, measure the distribution

**Epistemic uncertainty** — lack of knowledge. The value is fixed but we don't know it exactly.
- Estimated parameters (demand forecast, cost approximation, measured coefficients)
- Imprecise measurements (sensor reading ± tolerance)
- Unknown but fixed quantities (true market demand next month — it's one number, we just don't know which)
- Validation: sensitivity analysis, robust optimization, confidence intervals on the estimate

Both map to "probabilistic" on the axis because in both cases you cannot assert `f(exact_input) == exact_output` — you don't have the exact input. But the validation strategy differs:

| Source | Question | Validation |
|---|---|---|
| Aleatory | "Does it vary across runs?" | Reproducibility checks, distributional testing, multiple runs |
| Epistemic | "Do we know it exactly?" | Sensitivity analysis, robust optimization, confidence intervals, worst-case bounds |

When classifying, identify WHICH source of uncertainty is present. A quadrant can have both sources simultaneously (e.g., MILP with estimated parameters that also have measurement noise).

---

## Three Layers: Problem, Process, Environment

A single activity has three layers that can each have different uncertainty profiles. **Classify each layer separately** when the quick path gives an ambiguous or suspicious result.

### Layer 1: PROBLEM — the abstract task

What are you trying to compute or determine? This is the mathematical/logical essence, stripped of implementation details.

- Input: What information do you start with?
- Output: What result are you trying to produce?
- Ask: "In principle, if I had this exact input and a perfect solver, would the output be determined?"

### Layer 2: PROCESS — the algorithm/solver/implementation you use

What method are you using to solve the problem? The process may introduce uncertainty that the problem doesn't have.

- Input: What does the process actually receive (including parameters, seeds, configurations)?
- Output: What does the process actually return?
- Ask: "Does my specific method/algorithm/solver produce the same output for the same input every time?"

### Layer 3: ENVIRONMENT — the real-world context the input comes from

Where do your inputs actually come from? The environment may make your inputs uncertain even when the problem assumes they're known.

- Input: Are the real-world input parameters known exactly or estimated/approximated?
- Output: What do you actually need from the output (exact value? approximate? specific solution vector? just feasibility?)
- Ask: "Are the values I'm feeding into the process known exactly, or are they estimates with uncertainty?"

### Why the separation matters

The same problem can be in different quadrants at different layers:

**MILP example:**
- Problem: det/det (given exact A, b, c — the optimal value is mathematically determined)
- Process: det/det with single-thread deterministic mode, but det/prob with parallel threads, time limits, or MIP gap tolerances (solver returns different solution vectors across runs)
- Environment: prob/det when demand/cost/price parameters are estimated from data (stochastic programming exists for exactly this reason)

### Determining the effective quadrant: decompose or pessimistic?

When layers disagree, you have two options:

**Decompose** — use when component boundaries exist and uncertainty doesn't cross them. Each component gets its own quadrant and validation strategy.
- Can you draw a boundary where one component's output is a well-defined input to the next?
- Is the uncertainty within each component self-contained?
- Example: ML system = preprocessing (prob/det) + training (det/prob) + serving (prob/det) + monitoring (prob/prob). Each gets its own validation.

**Most pessimistic** — use when uncertainty is entangled across layers and can't be cleanly separated.
- If any layer has probabilistic input → input is probabilistic
- If any layer has probabilistic output → output is probabilistic
- Example: MILP where solver non-determinism (process: prob output) depends on which parameters were estimated (environment: prob input). The uncertainty flows across layers — can't decompose. Effective quadrant: prob/prob.

**Decision rule**: Try to decompose first. If component boundaries exist and uncertainty is contained within each, decompose. If uncertainty flows across layers (process behavior depends on environment estimates, environment outputs depend on process configurations), use most pessimistic.

---

## The Four Quadrants — Detailed

### Quadrant 1: det/det — Assertion

**You know what you have. You know what you want.**

- **Input**: Known exactly, stable, reproducible (no aleatory or epistemic uncertainty)
- **Output**: Known exactly, required, deterministic (no aleatory or epistemic uncertainty)
- **Validation**: Unit tests, assertions, formal proofs. One run, pass or fail.
- **Key question**: Does `f(known_input) == expected_output`?
- **When you misclassify here**: Assertion test fails — output varies (aleatory) or input isn't as known as you thought (epistemic). Re-classify.

**Examples:**

| Activity | Input | Output | Why det/det |
|---|---|---|---|
| Pure function (e.g., `add(2, 3)`) | Fixed arguments | Exact return value | No randomness, no external state |
| Compiler (same source, same flags) | Source code + config | Compiled binary | Deterministic transformation |
| Type checker | Source code | Type errors list | Deterministic analysis |
| Payment calculation (fixed terms) | Loan amount, rate, term | Exact payment schedule | Mathematical formula, no randomness |
| Declarative programming (SQL query on fixed data) | Schema + query + data | Result set | Deterministic query evaluation |
| MILP (mathematical abstraction) | Exact A, b, c matrices | Optimal objective value | Mathematically determined |
| Sorting algorithm | Fixed array | Sorted array | Deterministic comparison-based sort |
| Build system (same inputs, same deps) | Source + config + toolchain | Build artifacts | Reproducible builds |

### Quadrant 2: det/prob — Reproducibility

**You know what you have. You don't know exactly what you'll get.**

- **Input**: Known exactly, fixed, reproducible (no epistemic uncertainty about input)
- **Output**: Not pinned to a single value — either varies across runs (aleatory) or you don't know it exactly (epistemic)
- **Validation**:
  - Aleatory output: Run same input multiple times, measure output distribution. Variance analysis. Fixed-seed reproducibility tests.
  - Epistemic output: Sensitivity analysis on what you don't know about the output. Confidence intervals. Worst-case bounds.
- **Key question**: Does the output distribution (aleatory) or output range (epistemic) hold across runs with the same input?
- **When you misclassify here**: Output is more variable than expected, or results don't reproduce. May need to re-classify to prob/prob if input also varies.

**Examples:**

| Activity | Input | Output | Uncertainty Source | Why det/prob |
|---|---|---|---|---|
| Data science: EDA on fixed dataset | Known dataset | Insights/patterns | Epistemic (output) | Same data, but what you notice is path-dependent — you don't know in advance what you'll find |
| Monte Carlo simulation (fixed seed) | Fixed parameters + seed | Estimated statistics | Aleatory (output) | Random sampling introduces variance |
| ML inference with dropout | Fixed input tensor | Probability distribution | Aleatory (output) | Dropout randomly zeroes activations |
| Randomized algorithm (e.g., randomized quicksort) | Fixed array + random seed | Sorted array (correct) but varying runtime/paths | Aleatory (output) | Random pivot selection changes execution path |
| A/B test analysis (fixed experiment data) | Collected experiment data | Effect size estimate | Epistemic (output) | True effect is fixed but unknown — you're estimating it |
| MILP with parallel threads + time limit | Exact A, b, c + solver config | Solution vector within MIP gap | Aleatory (output) | Solver search path varies across runs (CPLEX opportunistic, Gurobi ConcurrentMIP) |
| MILP (mathematical abstraction, multiple optima) | Exact A, b, c | Which optimal solution vector is returned | Epistemic (output) | Multiple optima exist — which one is "the" answer depends on solver path, not randomness |
| Genetic algorithm (fixed seed) | Fixed initial population + fitness function | Best solution found | Aleatory (output) | Stochastic search explores differently each run |
| Survey analysis (fixed responses) | Collected survey data | Summary statistics | Epistemic (output) | True population parameter is fixed but unknown — sample gives estimate |

### Quadrant 3: prob/det — Robustness

**You don't know what you'll get as input. But you know what the output must be.**

- **Input**: Not pinned to a single known value — either varies across runs (aleatory) or you don't know it exactly (epistemic)
- **Output**: Must satisfy an invariant regardless of input (deterministic requirement)
- **Validation**:
  - Aleatory input: Fuzzing, property-based testing with random generators, stress testing, chaos engineering. Generate inputs from the distribution.
  - Epistemic input: Sensitivity analysis on uncertain parameters, robust optimization, worst-case analysis. Vary parameters within their uncertainty bounds.
  - Both: Edge case enumeration, metamorphic testing.
- **Key question**: Does `f(input_within_uncertainty_bounds)` always satisfy the invariant?
- **When you misclassify here**: Certain inputs break the invariant. The set of failing inputs reveals the uncertainty you didn't model.

**Examples:**

| Activity | Input | Output | Uncertainty Source | Why prob/det |
|---|---|---|---|---|
| API endpoint | User-provided requests (varying payloads, headers, timing) | Correct response or graceful error | Aleatory (input) | Invariant: never crash, always return valid response |
| Parser (JSON, XML, etc.) | Untrusted input (malformed, adversarial, huge) | Parsed structure or error | Aleatory (input) | Invariant: never crash on invalid input |
| Distributed system under network partitions | Network conditions (latency, packet loss, partitions) | Consistent state | Aleatory (input) | Invariant: consistency guarantees hold |
| Security-critical function (auth check) | Attacker-controlled input | Allow/deny decision | Aleatory (input) | Invariant: no unauthorized access |
| Compiler handling untrusted code | Arbitrary source code (potentially malformed) | Valid binary or compile error | Aleatory (input) | Invariant: never crash, always produce valid output or clean error |
| Database query with user input | User-generated queries and parameters | Correct result set | Aleatory (input) | Invariant: no injection, no crash, correct data |
| Load balancer | Traffic patterns (varying rates, spikes) | Requests distributed fairly | Aleatory (input) | Invariant: no dropped requests, fair distribution |
| MILP with estimated parameters (robust optimization) | Demand/cost/price parameters — fixed but not known exactly | Feasible solution satisfying constraints under all scenarios | Epistemic (input) | Invariant: solution must be robust to parameter uncertainty within bounds |
| Engineering design with toleranced parts | Dimensions known within ± tolerance | Structure meets specification | Epistemic (input) | Invariant: design must work for any part within tolerance |

### Quadrant 4: prob/prob — Holdout Validation

**You don't know what you'll get as input. You don't know exactly what the output will be.**

- **Input**: Not pinned to a single known value — varies across runs (aleatory) or unknown exactly (epistemic), or both
- **Output**: Not pinned to a single value — varies (aleatory) or unknown exactly (epistemic), or both
- **Validation**:
  - Aleatory/aleatory: Cross-validation, holdout sets, OOD testing. Measure performance on unseen data.
  - Epistemic/epistemic: Uncertainty quantification, Bayesian methods, confidence intervals on both input estimates and output predictions.
  - Mixed: Calibration checks (are predicted confidence intervals accurate?), sensitivity analysis on input estimates propagated through to output predictions.
- **Key question**: Does measured performance hold across the uncertainty in both input and output? Are confidence intervals calibrated?
- **This is the most expensive quadrant**: You only land here when both axes are genuinely uncertain. Don't default here — verify that simpler quadrants genuinely don't apply.

**Examples:**

| Activity | Input | Output | Uncertainty Source | Why prob/prob |
|---|---|---|---|---|
| ML model training + deployment | Training data (sampled from population) | Model predictions on new data | Aleatory (both) | Data is a sample, predictions are probabilistic |
| Demand forecasting | Historical sales + market signals | Future demand estimates | Epistemic (both) | True demand is fixed but unknown, forecast is an estimate of it |
| Recommendation system | User interaction history | Ranked recommendations | Aleatory (both) | User behavior varies, recommendations are ranked by predicted preference |
| LLM text generation | User prompt | Generated text | Aleatory (both) | Input varies, output is sampled from probability distribution |
| Quantitative trading strategy | Market data (price signals, noise) | Trading decisions + returns | Aleatory (both) | Market data is noisy, returns are probabilistic |
| MILP with estimated parameters + approximate solving | Demand/cost/price — fixed but not known exactly + solver with time limit | Solution vector within MIP gap | Epistemic (input) + Aleatory (output) | Input estimated from data, solver returns path-dependent approximate solution |
| Weather prediction model | Sensor data (noisy, incomplete) | Weather forecasts | Aleatory (input) + Epistemic (output) | Input has measurement noise, forecast is uncertain estimate |
| A/B test in production | Live user traffic (varies day to day) | Conversion rate estimate | Aleatory (input) + Epistemic (output) | Input is real-time traffic, output is estimate of fixed-but-unknown true rate |
| Drug efficacy study | Patient population (variable biology) | Treatment outcome distribution | Aleatory (both) | Patients differ, outcomes are probabilistic |

---

## Quadrant Transitions: Can You Move to a Better Quadrant?

After classifying, ask: **can I move this problem (or a subproblem) to a cheaper quadrant?** Cheaper = less uncertainty = simpler validation. Sometimes you can, sometimes you can't, and sometimes you shouldn't.

### Transition Map

```
prob/prob ────────────────────── prob/det
    │                                │
    │ reduce output uncertainty      │ reduce input uncertainty
    │                                │
    ▼                                ▼
  det/prob ────────────────────── det/det
```

Goal: move toward det/det (cheapest validation). Each transition removes uncertainty from one axis.

### When It Makes Sense to Move

**prob/prob → prob/det (reduce output uncertainty)**
- You have uncertain input AND uncertain output. Can you pin down the output?
- Example: ML model in production (prob/prob). Instead of predicting exact demand (probabilistic output), predict a range with confidence intervals and commit to fulfilling the range. Output becomes "satisfy demand within [lo, hi]" — a deterministic invariant. You've moved to prob/det (robust optimization).
- Benefit: validation shifts from holdout testing to robustness testing — you test whether the invariant holds across input distributions, not whether predictions match reality.

**prob/prob → det/prob (reduce input uncertainty)**
- You have uncertain input AND uncertain output. Can you pin down the input?
- Example: Demand forecasting with market survey data (prob/prob). Conduct a definitive survey that pins down the demand distribution. Input is now known (det), output is still probabilistic (you're still estimating). You've moved to det/prob.
- Benefit: validation shifts from holdout testing to reproducibility checking — simpler, cheaper.
- Caveat: pinning down input often costs money/time (surveys, experiments, data collection). Weigh cost vs validation savings.

**prob/det → det/det (reduce input uncertainty)**
- You have uncertain input but know what the output must be. Can you eliminate input uncertainty?
- Example: API endpoint with user input (prob/det). Add input validation/sanitization that transforms arbitrary input into a constrained, known-valid format. Downstream processing now gets deterministic input. You've moved the downstream subproblem to det/det.
- Benefit: downstream can use simple assertions instead of fuzzing.
- Caveat: the validation/sanitization layer itself is still prob/det — you've moved the problem, not eliminated it. But you've localized it to one component.

**det/prob → det/det (reduce output uncertainty)**
- You have known input but uncertain output. Can you pin down the output?
- Example: MILP with multiple optimal solutions (det/prob, epistemic). Add a secondary objective (tie-breaker) that makes the optimum unique. Output is now deterministic. You've moved to det/det.
- Example: Randomized algorithm (det/prob, aleatory). Replace with a deterministic algorithm (even if slower). Output is now deterministic. You've moved to det/det.
- Benefit: assertion testing replaces reproducibility checking. Cheapest validation.
- Caveat: deterministic algorithms may be slower or more complex. Uniqueness constraints may over-constrain the problem.

### When It's Not Possible to Move

**Cannot reduce aleatory uncertainty on input:**
- User behavior, sensor noise, network conditions — these are inherently random. You cannot make users predictable. You can only add robustness (stay in prob/det) or collect more data to characterize the distribution (still prob, but better understood).

**Cannot reduce epistemic uncertainty on output when the answer is genuinely unknown:**
- Exploratory data analysis — you don't know what patterns you'll find. You can't "pin down" the insight in advance. The output is epistemically uncertain by definition.
- Scientific research — the finding is what it is, you discover it through experimentation.

**Cannot move if the uncertainty is the point:**
- ML model generalization (prob/prob) — the whole purpose is to handle unseen data. Making input deterministic (training on all possible data) is impossible. Making output deterministic (memorization) defeats the purpose.
- A/B testing — the uncertainty about which variant is better IS the question. Removing it means you've already answered it.

### When You Shouldn't Move Even If You Can

**Don't move prob/det → det/det by over-constraining input:**
- Adding strict input validation that rejects anything outside known patterns makes input deterministic but may hide real-world conditions the system needs to handle. You've moved to det/det for the happy path but created blind spots for the real-world distribution.

**Don't move det/prob → det/det by adding fake precision:**
- Adding a tie-breaker to MILP makes the solution unique (det/det), but the tie-breaker may be arbitrary. You now have deterministic output that's no more correct than the probabilistic output was — you've just hidden the uncertainty, not removed it.

**Don't move prob/prob → prob/det by pretending output is deterministic:**
- Defining "the output is whatever the model predicts" makes output "deterministic" but it's not — you've just refused to measure the uncertainty. The validation (robustness testing) will pass trivially because you've defined away the failure condition. This is the Cynefin gaming problem in a new form.

### Subproblem Decomposition

Sometimes you can't move the whole problem, but you can decompose it into subproblems in different quadrants:

**Example: ML system in production (prob/prob)**
- Data collection and preprocessing → prob/det (input is real-world data, output must be clean formatted data — invariant: no nulls, correct schema)
- Model training → det/prob (input is fixed training set, output is model weights — stochastic)
- Model serving → prob/det (input is user request, output must be valid response — invariant: never crash, always return something)
- Model monitoring → prob/prob (input is live traffic distribution, output is drift metrics — both uncertain)

Each subproblem gets its own validation strategy. The overall system is prob/prob, but you don't need holdout validation for every component — the serving layer needs fuzzing, the training layer needs reproducibility checks, the preprocessing layer needs robustness testing.

---

## Validation Summary

| Effective Quadrant | Primary Validation | Epistemic Additional | Secondary (if needed) |
|---|---|---|---|
| det/det | Assertion (unit tests, proofs) | — | None needed — if assertion passes, you're done |
| det/prob | Reproducibility (multiple runs, distribution check) | Sensitivity analysis, confidence intervals | Variance analysis, worst-case bounds |
| prob/det | Robustness (fuzzing, property-based testing) | Robust optimization, worst-case analysis, tolerance stack-up | Stress testing, chaos engineering |
| prob/prob | Holdout validation (cross-validation, OOD testing) | Uncertainty quantification, Bayesian methods, calibration checks | A/B testing, sensitivity propagation |

Run the prescribed test. If it fails in ways that suggest a different quadrant, re-classify:
- Assertion fails because output varies → move to det/prob or prob/prob
- Assertion fails because certain inputs break it → move to prob/det
- Reproducibility fails because input also varies → move to prob/prob
- Holdout validation passes trivially → consider downgrading to a simpler quadrant

The classification is **testable and falsifiable** — unlike Cynefin's subjective domains, you can empirically check whether your classification is correct by running the prescribed validation.

---

## Why This Is Less Gameable Than Cynefin

Cynefin's axes (cause-effect clarity: known → unknowable) are subjective. A person who wants to avoid hard problems can classify them as "Clear" (cause-effect known, just apply best practice) when they're actually Complex. The classification is an opinion, and opinions can be rationalized.

This framework's axes (input determinism, output determinism) are observable. "Does my input vary across runs?" is a factual question with a testable answer. You can't comfortably classify a user-facing API as det/det when fuzzing breaks it — the failure is empirical, not opinion-based.

---

## Relationship to Other Frameworks

### vs. Cynefin
Cynefin classifies by cause-effect clarity (subjective). This framework classifies by IO determinism (observable). Cynefin's prescriptions (best practice, expert analysis, experimentation, act-first) are a subset of what this framework prescribes — but mapped to observable properties rather than subjective judgments.

### vs. WRAP
This framework plugs into WRAP's "Reality-Test Your Assumptions" step. After classifying your problem with this framework, the prescribed validation strategy IS your reality-test methodology. WRAP says "test your assumptions" — this framework tells you what kind of test to run.

### vs. Sarasvathy's Effectuation/Causation — this framework generalizes it

Sarasvathy's (2001) distinction is a **1D slice** of this 2D framework — specifically, the **output axis only**:

- **Causation**: You know the desired output (goal), find means to achieve it. Output is deterministic — you specified it in advance. This maps to **output deterministic**.
- **Effectuation**: You start with available means, discover what you can create. Output is probabilistic — it emerges through action. This maps to **output probabilistic**.

Sarasvathy doesn't separate the input axis. The io-uncertainty-quadrant generalizes by adding it, producing four modes instead of two:

| Sarasvathy | IO Quadrant | Meaning |
|---|---|---|
| Causation (with known resources) | **det/det** | You know what you have, you know what you want. Traditional planning. |
| Effectuation (with known means) | **det/prob** | You know what you have, you don't know what you'll get. Sarasvathy's core case — "open the fridge, improvise." Output uncertainty is epistemic (you haven't discovered the goal yet) not aleatory. |
| Causation (with uncertain resources) | **prob/det** | You know what you want, but inputs vary or aren't known exactly. Robust optimization, contingency planning. Input uncertainty may be aleatory (market conditions) or epistemic (estimated costs). |
| Effectuation (with uncertain means) | **prob/prob** | You don't know what you'll get as input or output. Most real-world complex situations. Both axes uncertain, both sources possible. |

Sarasvathy's five effectuation principles map to specific quadrant strategies:

| Principle | Maps to | How |
|---|---|---|
| **Bird in Hand** (start with who you are, what you know, whom you know) | det/prob | Assumes input is deterministic (you know your means) — effectuation with known resources |
| **Affordable Loss** (risk only what you can afford to lose) | det/prob | Risk management for known-means/unknown-outcome — bound the downside of probabilistic output |
| **Crazy Quilt** (form partnerships, co-create) | prob/prob | Adding external partners makes input probabilistic — their contributions are uncertain |
| **Lemonade** (leverage surprises as opportunities) | prob/det or prob/prob | Handling probabilistic input — treat unexpected inputs as opportunities, not threats |
| **Pilot in the Plane** (shape the future, don't predict it) | prob/prob | Philosophy for when both axes are uncertain — control over prediction, action over analysis |

The io-uncertainty-quadrant subsumes effectuation/causation by:
1. Recognizing that Sarasvathy's distinction is the output axis
2. Adding the input axis she doesn't address
3. Prescribing validation strategies for each quadrant (Sarasvathy prescribes principles for effectuation only, not for causation with uncertain inputs)

### vs. Testing Pyramid
The testing pyramid escalates test scope (unit -> integration -> E2E). This framework selects test type based on uncertainty dimensions. They're complementary: the pyramid tells you how broadly to test, this framework tells you what kind of test to run.

---

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

---

## Usage
**Quick path**: Classify on two axes (is input deterministic? is output deterministic?), pick validation from the 2x2 matrix. If clear, done.

**Full path**: Separate problem, process, and environment layers. Classify each layer on input/output determinism (identifying aleatory vs epistemic uncertainty). Try to decompose into subproblems with different quadrants — if uncertainty is entangled across layers, use most pessimistic quadrant. Select the matching validation strategy. Analyze whether quadrant transitions are possible and beneficial — can you reduce uncertainty on either axis, or is the uncertainty irreducible? Run validation. If the test fails in ways that suggest a different quadrant, re-classify and re-test.

## Agent Rules


1. You MUST call `ai_venice_web_search` during the CLASSIFY stage. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
6. If `ai_venice_web_search` is rate-limited or returns errors, use Playwright browser tools as a SEQUENTIAL fallback: `playwright_browser_navigate` to visit a search engine (e.g. https://duckduckgo.com/?q=QUERY), `playwright_browser_snapshot` to read results, `playwright_browser_click` to follow links, `playwright_browser_evaluate` to extract text. Playwright is shared across all agents — do NOT use it if another agent may be using the browser simultaneously. Treat Playwright results the same as search results — cite URLs, never fabricate.
