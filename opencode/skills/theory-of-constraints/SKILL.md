---
name: theory-of-constraints
description: Use when optimizing throughput of any system — find the single bottleneck limiting total output. Prevents local optimization that doesn't move total throughput. Applies to build pipelines, CI/CD, performance, development velocity, supply chains, and any system with sequential dependencies.
---

# Theory of Constraints (TOC) Framework

Use this framework when a system's output is limited and you need to find what's actually constraining it. TOC focuses improvement on THE bottleneck, not scattered local optimizations.

Developed by Dr. Eliyahu M. Goldratt, introduced in his 1984 book "The Goal." Core principle: any system with dependent events has exactly one constraint at a time, and that constraint governs total throughput. Goldratt summarized TOC in one word: FOCUS.

## Core Concept

A chain is no stronger than its weakest link. In any system of value creation, output is limited by one constraint. Optimizing non-constraints is waste — it creates inventory/WIP without increasing total output.

**The trap:** Most improvement efforts optimize non-constraints because they're easier to see. This creates local gains that don't improve total throughput — and often makes things worse by creating buildup in front of the constraint.

## Stages

### 1. IDENTIFY THE CONSTRAINT
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to find how constraints manifest in systems like yours. Do NOT rely on training data.**
- What is the goal of this system? (Define throughput — what are we maximizing?)
- Where does work pile up? Where is the queue longest?
- Which step, if made faster, would increase total output? (vs steps that wouldn't)
- Is the constraint physical (hardware, network, eval time) or policy (rules, habits, process)?
- Search for known bottleneck patterns in your system type
- Constraint types: physical resource, policy, market (external demand), behavioral
- Tip: If you identify the wrong constraint, TOC auto-corrects — subordination will reveal the real one quickly

### 2. EXPLOIT THE CONSTRAINT
Get maximum output from the constraint as it currently exists — before spending money:
- Is the constraint running 100% of available time? (Track utilization, OEE)
- What causes idle time at the constraint? Eliminate each cause
- Are breaks staggered so constraint never stops?
- Is quality checked BEFORE the constraint, so it never wastes time on bad input?
- Is preventative maintenance done so constraint never breaks down unexpectedly?
- Are the best operators assigned to the constraint?
- Remove anything that wastes constraint time: the constraint is the most valuable resource in the system
- **WARNING: Do NOT skip to Step 4 (Elevate). Steps 2-3 typically expose 30%+ hidden capacity at no cost.**

### 3. SUBORDINATE EVERYTHING ELSE
Align the entire system to the constraint's pace:
- Non-constraints must NOT produce faster than the constraint can consume — this creates WIP buildup, lead time inflation, firefighting
- Choke release of work to match constraint capacity (Drum-Buffer-Rope)
- Ensure constraint is NEVER starved for input — maintain buffer before it
- Ensure constraint is NEVER fed poor quality — quality gate immediately before
- Change policies, measurements, and habits that conflict with constraint performance
- This step is counterintuitive: it means deliberately running non-constraints below their capacity. This is correct. Running them at full capacity is waste.

### 4. ELEVATE THE CONSTRAINT
Only after Exploit (Step 2) and Subordinate (Step 3) are fully exhausted:
- Add resources: more machines, more people, more compute, more bandwidth
- Upgrade equipment
- Outsource constraint work
- Redesign the constraint step entirely
- **This step costs money. Steps 2-3 are free. Never elevate before exploiting and subordinating.**

### 5. PREVENT INERTIA — RETURN TO STEP 1
When the constraint is elevated, it may no longer be the constraint. A new constraint emerges elsewhere.
- Do NOT let inertia keep managing around the old constraint — it's no longer the bottleneck
- Return to Step 1: identify the NEW constraint
- This is the Process of On-Going Improvement (POOGI) — a continuous cycle
- Warning: "Frequently shifting constraints wreck havoc on policies, procedures and people" (TOC Institute). Stabilize before re-cycling.

## TOC Thinking Processes (for complex constraint analysis)

When the constraint is not obvious (policy constraints, organizational, multiple interdependencies):

**Current Reality Tree (CRT):** Map all Undesirable Effects (UDEs) to root causes via cause-and-effect. Identifies the core conflict behind symptoms.

**Evaporating Cloud (EC):** Articulate the core conflict. Two opposing wants, each driven by a need, both serving a common objective. Surface hidden assumptions — invalidate one to "evaporate" the conflict. Avoids compromise.

**Future Reality Tree (FRT):** Map proposed solution forward to verify it eliminates UDEs without creating new ones (Negative Branch Reservation).

**Prerequisite Tree (PRT):** Identify obstacles to implementation and sequence their resolution.

## Examples by Domain

**Nix build pipeline:** Constraint = nix evaluation time (not build execution). Exploit: cache eval results, minimize flake inputs. Subordinate: don't optimize build parallelism if eval is the bottleneck. Elevate: more cores for eval, or restructure flake to reduce eval scope.

**CI/CD:** Constraint = test suite runtime. Exploit: parallelize tests, cache dependencies, skip irrelevant tests. Subordinate: don't optimize build time if tests are the bottleneck — builds finishing faster just creates queue at tests. Elevate: more CI runners, split test suite.

**Development velocity:** Constraint = code review throughput. Exploit: batch reviews, timebox, reduce PR size. Subordinate: don't optimize CI speed if reviews are the bottleneck — faster CI just means PRs wait longer for review. Elevate: more reviewers, automated review tools.

**Crypto data pipeline:** Constraint = API rate limit. Exploit: batch requests, cache aggressively, optimize payload size. Subordinate: don't optimize data processing speed if API is the bottleneck — faster processing just means idle time waiting for API. Elevate: higher API tier, multiple API keys, alternative data sources.

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through the five focusing steps sequentially. At IDENTIFY, use `ai_venice_web_search` to research known bottleneck patterns in your system type. The loop is iterative — after ELEVATE, return to IDENTIFY for the new constraint. For complex/organizational constraints, use the Thinking Processes (CRT/EC/FRT) to map cause-and-effect before acting.

## Agent Rules


1. You MUST call `ai_venice_web_search` at the IDENTIFY stage. No exceptions.
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
