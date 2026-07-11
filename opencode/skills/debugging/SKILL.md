# Systematic Debugging Framework

Use this framework when fixing bugs, troubleshooting production issues, or diagnosing unexpected behavior.

## Stages

### 1. REPRODUCE
Reproduce the bug reliably:
- What are the exact steps to trigger the issue?
- Is it 100% reproducible or intermittent?
- Does it reproduce in a minimal example?
- What's the environment? (OS, version, config, data)
- Capture logs, stack traces, error messages
- Write down expected vs. actual behavior

### 2. ISOLATE
**IMPORTANT: Use web_search to find known issues**
Narrow down where the bug lives:
- Divide and conquer: split the execution path in half
- Binary search debugging: bisect commits, code paths, data
- What changed recently? Check git log
- Does the bug appear with different inputs?
- Search for similar issues in dependencies, libraries, frameworks
- Check GitHub issues, Stack Overflow, documentation

### 3. HYPOTHESIZE
**IMPORTANT: Use web_search to verify library behavior**
Form a specific, testable hypothesis:
- Based on isolation, where do you think the bug is?
- What specific line of code, condition, or state do you suspect?
- State the hypothesis as a testable claim
- Consider multiple hypotheses ranked by likelihood:
  1. Off-by-one error or boundary condition
  2. Null/undefined/empty value not handled
  3. Race condition or timing dependency
  4. Wrong type or implicit coercion
  5. Stale cache, old build, or environment difference
  6. Misunderstanding of library/API behavior
- What would disprove each hypothesis?

### 4. TEST
Verify or falsify your hypothesis before making changes:
- Add a targeted test: can you confirm the root cause?
- Use a debugger, print statements, or logging
- Can you write a unit test that reproduces the exact failure?
- Test at the boundary: what happens with edge-case inputs?
- If the hypothesis is wrong, go back to isolate
- Rubber duck debugging: explain the bug out loud

### 5. FIX
Implement the fix:
- Fix the root cause, not the symptoms
- Is this a one-off fix, or does it indicate a systemic issue?
- Does the fix introduce new risks or edge cases?
- Keep the change minimal — don't refactor while fixing
- Write a regression test that would catch this bug if it reappears
- Consider: does the same bug exist elsewhere in the codebase?

### 6. VERIFY
Confirm the fix works and nothing else broke:
- Does the original reproduction case now pass?
- Do all existing tests still pass? Run the full suite
- Does the fix work with edge cases, not just the happy path?
- Can you reproduce the bug if you revert the fix?
- Check for similar bugs: search the codebase for the same pattern
- Post-mortem: what would have prevented this bug?

## Usage
Work through each stage sequentially. At ISOLATE and HYPOTHESIZE stages, use web_search to find known issues and verify library behavior.

## Agent Rules


1. You MUST reproduce the bug before forming any hypothesis. No reproduction, no hypothesis.
2. NEVER apply a fix before identifying the root cause. Symptom patching is prohibited.
3. ALWAYS write a regression test that would have failed before your fix.
4. Change ONE variable at a time. Never make multiple changes simultaneously during isolation.
5. If a hypothesis is disproven, discard it completely. Do not rationalize or salvage it.
6. Your ONLY tools are `read`, `glob`, `grep`, `bash`, and `edit`. Use them to investigate, reproduce, test, and fix.
7. NEVER conclude "fixed" without running the reproduction case AND the test suite.
