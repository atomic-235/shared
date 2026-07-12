---
name: first-principles
description: Use when conventional wisdom is unhelpful, when redesigning from scratch, or when analogy-based thinking leads to local optima. Decomposes problems to fundamental truths and reconstructs solutions from the ground up.
---

# First Principles Framework

Use this framework when conventional wisdom is unhelpful, when redesigning from scratch, or when analogy-based thinking leads to local optima.

## Stages

### 1. DECOMPOSE THE PROBLEM
Break the problem into its smallest components:
- What are the pieces? What are the assumptions baked into each?
- Which parts are constraints, and which are just conventions?
- What 'everyone knows' about this that might not be true?
- Strip away analogy-based reasoning — what remains?
- List every assumption, then mark each as 'proven' or 'inherited'

### 2. IDENTIFY FUNDAMENTAL TRUTHS
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to verify constraints. Do NOT rely on training data or fabricate sources.**
Find the irreducible facts you can build on:
- Which of your assumptions are actually fundamental truths?
- What is physically, logically, or mathematically inevitable here?
- What constraints are real (laws of physics, hard deadlines) vs. artificial?
- What do you know for certain vs. what do you assume?
- Test each fundamental: 'Why is this true?' If you can't answer, it's not fundamental
- Search for documentation, specifications, and authoritative sources to verify constraints

### 3. RECONSTRUCT FROM FIRST PRINCIPLES
Build a solution from the fundamentals up:
- Given only the fundamental truths, what's possible?
- If you started from scratch with no legacy constraints, how would you do this?
- What novel combinations of fundamentals emerge?
- Are there approaches that the fundamentals enable but convention overlooks?
- Build the simplest solution that satisfies all real constraints

### 4. VALIDATE THE SOLUTION
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to verify feasibility. Do NOT rely on training data or fabricate sources.**
Test your first-principles solution against reality:
- Does the solution violate any fundamentals? (If yes, it's wrong.)
- Does it achieve the real constraints while ignoring the artificial ones?
- Where does it conflict with conventional approaches, and why is that OK?
- What's the weakest point in the reconstruction?
- Can you prototype or test the core insight cheaply?
- Search for similar solutions, case studies, or implementations to validate feasibility

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through each stage sequentially. At IDENTIFY FUNDAMENTAL TRUTHS and VALIDATE THE SOLUTION, use `ai_venice_web_search` to verify constraints and feasibility.

## Agent Rules


1. You MUST call `ai_venice_web_search` during IDENTIFY FUNDAMENTAL TRUTHS and VALIDATE THE SOLUTION. No exceptions.
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
