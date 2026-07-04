---
name: software-design
description: Use when designing or reviewing code structure, modules, interfaces, or APIs. Covers SOLID, DRY, KISS, YAGNI, coupling/cohesion, design patterns, API contracts, and evolutionary design. Applies at the code, module, and component level — not distributed-system architecture.
---

# Software Design Framework

Use this framework when designing or reviewing code structure, modules, interfaces, or APIs at the code, module, and component level.

## Stages

### 1. IDENTIFY THE DESIGN CONTEXT
Understand what level you're designing at and what forces shape it:
- What level is this? (function, class, module, package, API boundary)
- What are the current and anticipated change axes? What changes together vs. independently?
- What constraints exist? (language, framework, team conventions, performance)
- Is this greenfield or modifying existing code? Evolutionary design applies to both.
- What's the current iteration's requirement? Design for now, not speculative futures (YAGNI)

### 2. APPLY CORE PRINCIPLES
Map each principle to the specific design decision at hand:
- SRP: Does this module/class have one reason to change? (Fowler: "keep things that change at the same time in the same module")
- OCP: Can behavior extend without modifying existing code?
- LSP: Are substitutions safe? Are contracts honored?
- ISP: Are consumers forced to depend on things they don't use?
- DIP: Do high-level modules depend on abstractions, not concretions?
- DRY: Is domain knowledge duplicated? (Not just code — logic, rules, data transformations)
- KISS: Is this the simplest design that satisfies current requirements?
- YAGNI: Are you building for speculative future needs? Remove it.

### 3. EVALUATE COUPLING & COHESION
Use the "pattern of change" as the lens for these evaluations:
- Coupling: Map dependencies between modules. Afferent (who depends on me) and efferent (who do I depend on).
  - Can any dependency be inverted or removed?
  - Are modules coupled through stable abstractions or volatile concretions?
  - Would a change in one module force changes in others? That coupling should be intentional, not accidental.
- Cohesion: Does each module's functionality share the same "what" (business intent)?
  - Group things that change together. Separate things that change at different rates.
  - Would splitting or merging improve single-responsibility?

### 4. SELECT DESIGN PATTERNS (if needed)
Patterns are vocabulary, not prescriptions. Use them to communicate, not to conform:
- Identify the recurring problem type (creation, structure, behavior)
- Match to a pattern — but only if the problem genuinely calls for it
- Avoid pattern obsession: a simple solution is always preferred (KISS)
- Consider language-specific idioms before generic patterns
- Fowler: "Many of the fundamentals of software design don't change very rapidly, even though our technologies do." Prefer stable patterns over trendy ones.

### 5. DESIGN API CONTRACTS
Interfaces are commitments. Design them carefully:
- Define clear interfaces with explicit inputs/outputs
- Versioning strategy from the start
- Error handling: consistent, explicit, not hidden
- Prefer composition over inheritance for extensibility
- Minimize what consumers must know (ISP applies to APIs too)
- Consider the consumer's perspective: would using this API surprise you?

### 6. REVIEW FOR TRADE-OFFS & EVOLUTION
Every design choice involves trade-offs. Name them and plan for evolution:
- Every design choice has a cost: flexibility vs. simplicity, generality vs. specificity, performance vs. clarity
- Document non-obvious decisions and their rationale (ADRs for significant ones)
- Ask: "What would make me regret this design in 6 months?"
- Evolutionary design: architecture isn't done first-time. Plan for refactoring as you learn more.
- "All design is centered around the current iteration with no design done for anticipated future needs." (Fowler/XP) — when future needs arrive, refactor then.

## Usage
Work through each stage sequentially. This is a principles-based skill applied to existing or new code, not a research task. No web search is required — the principles are stable and well-established. Focus on mapping principles to the specific design decision, not reciting them abstractly.
