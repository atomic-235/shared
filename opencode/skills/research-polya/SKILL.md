---
name: research-polya
description: Use when solving analytical, mathematical, or logical problems where you need to find an unknown from given information. Structures thinking through Understanding, Planning, Executing, and Reflecting — with a repertoire of heuristic moves (analogy, working backward, decomposition, generalization, etc.).
---

# Pólya's Problem-Solving Framework

Use this framework when solving analytical, mathematical, or logical problems where you need to find an unknown from given information — and there's no obvious path from givens to goal.

Based on George Pólya's *How to Solve It* (1945), continuously in print for 80 years. The foundational framework for mathematical and analytical problem-solving.

## When to Use This vs. Other Skills

- **Pólya** → Pure reasoning problems: "How do I get from these givens to that unknown?"
- **Scientific Method** → Empirical problems: "What does the evidence tell me about the world?"
- **PPDAC** → Data-driven problems: "What does this dataset reveal?"
- **Inversion** → Risk problems: "How do I avoid failure?"

## Stages

### 1. UNDERSTAND THE PROBLEM
You cannot solve what you do not understand. This step is often skipped — and that skipping is the #1 cause of wrong answers:
- What is the unknown? State it precisely.
- What are the given quantities/conditions? List them all.
- What are the constraints? Which are hard vs. soft?
- Is there enough information? Too much? Contradictory?
- Restate the problem in your own words.
- Draw a diagram, make a table, or write the notation — externalize the structure.
- Can you separate what is *given* from what you *assume*?

### 2. DEVISE A PLAN
Find the connection between the data and the unknown. If you can't find a direct connection, consider auxiliary elements or intermediate unknowns. Select from the heuristic repertoire below:

#### The Heuristic Repertoire

**Analogy**
- Have you seen a similar problem before?
- Do you know a related problem with the same unknown or similar conditions?
- Can you use the result, or the method, of a problem you've already solved?

**Working Backward**
- Start from the desired conclusion. What would you need to know to reach it?
- What would you need to know to know *that*? Keep going until you reach something you already know.
- This is especially powerful for proofs: assume the conclusion, derive necessary conditions.

**Decomposition**
- Break the problem into subproblems that are easier to solve.
- Solve each subproblem independently, then combine.
- What are the natural "joints" of the problem?

**Generalization**
- Can you solve a more general problem? Sometimes the general case is easier than the specific.
- Strip away specifics to find the abstract structure.
- Example: proving something for all integers is sometimes easier than for even integers alone.

**Specialization**
- Try specific cases: n=1, n=2, n=3. What pattern emerges?
- Pick simple numbers. What breaks? What holds?
- The pattern in special cases often reveals the general proof.

**Auxiliary Elements**
- Introduce a new variable, line, function, or construction that isn't in the original problem.
- This is the "missing link" technique — add something that creates a bridge.
- Example: draw an auxiliary line in geometry, introduce a substitution in algebra.

**Simplification**
- Remove constraints temporarily. Can you solve the simpler version?
- Add constraints to force structure. What if the domain is finite/discrete?
- Approximate first, then refine.

**Contradiction**
- Assume the opposite. Derive a contradiction.
- Reductio ad absurdum: the most powerful proof technique when direct proof fails.
- If the negation leads to absurdity, the original must hold.

**Induction**
- Prove the base case. Prove that if it holds for n, it holds for n+1.
- Check: is the inductive step valid for ALL n, or does it break somewhere?

### 3. CARRY OUT THE PLAN
Execute the plan step by step:
- Check each step. Can you see clearly that it's correct?
- Don't skip steps — a chain is only as strong as its weakest link.
- If the plan fails, don't force it. Discard and return to Stage 2.
- "Don't be misled; this is how mathematics is done, even by professionals." — Pólya
- Persist with patience. If you've chosen a good heuristic, the solution is reachable.

### 4. LOOK BACK
The most neglected step — and the one that turns a solution into understanding:
- Can you verify the result? Check it another way?
- Can you derive the result differently? (Multiple proofs = deeper understanding)
- Can you use the result, or the method, for another problem?
- What made this problem hard? What made the solution work?
- Can you state the solution more clearly or more simply?
- What assumptions were essential? Which were incidental?
- Document the key insight so you can recognize similar problems in the future.

## Decision Logic: Choosing a Heuristic

When stuck on Stage 2, cycle through these questions:
1. "Do I know a similar problem?" → **Analogy**
2. "What would I need to know to reach the answer?" → **Working Backward**
3. "Can I break this into smaller pieces?" → **Decomposition**
4. "What if I try simple cases first?" → **Specialization**
5. "Is there a more general version that's easier?" → **Generalization**
6. "What's missing that would connect the givens to the unknown?" → **Auxiliary Elements**
7. "Can I strip away complexity?" → **Simplification**
8. "What if the opposite were true?" → **Contradiction**
9. "Does this have a recursive structure?" → **Induction**

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.

## Usage
Work through each stage sequentially. At Stage 2, select heuristics from the repertoire based on the decision logic. If a plan fails, return to Stage 2 with a different heuristic — do not force a failing approach.

## Agent Rules


1. You MUST call `ai_venice_web_search` at least once during the DEVISE A PLAN stage to find related problems and techniques. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
7. Web research fallback chain (use in this strict order):
   (a) `ai_venice_web_search` — primary.
   (b) `webfetch` — if Venice returns rate-limit errors, fetch known URLs directly.
   (c) Playwright browser tools — if both above fail AND router grants exclusive browser access in your Task prompt. Playwright is single-threaded (one browser instance shared across all agents), so only use it when explicitly granted.
   All three methods require sequential execution — never run parallel agents doing web research.
   Treat Playwright results same as search results — cite URLs, never fabricate.
   Playwright is for WEB BROWSING ONLY — do NOT use `playwright_browser_run_code` or `playwright_browser_evaluate` to write files, run shell commands, or execute code. If asked to write a file, return the full content in your response instead.
