---
name: red-team
description: Use when you need to actively attack, break, or exploit a system, plan, or assumption — not just imagine failure. Adversarial construction of attack paths, not reflective risk listing. Originated in US military/intelligence to overcome groupthink and confirmation bias. Applies to security review, architecture attack surface, decision stress-testing, and any system that needs to survive determined adversaries.
---

# Red Team Framework

Use this framework when you need to actively construct attack paths against a system, plan, or decision. Red Teaming adopts an adversarial stance — you ARE the attacker, not a reflective observer imagining what might go wrong.

Originated in the 1960s with the US military and RAND Corporation during the Cold War. Formalized after 9/11 to address "failures of imagination" — the intelligence community realized they needed analysts who deliberately think like the enemy, not just list risks. Now used across cybersecurity, military, intelligence, business strategy, and decision-making.

## Key Distinction from Other Frameworks

- **Premortem:** Assumes failure happened, works backward to causes. Output: risk list. Reflective.
- **Inversion:** Asks "how would I guarantee failure?" to avoid it. Output: avoidance list. Reflective.
- **Red Team:** You ARE the adversary. You construct the actual attack path, step by step. Output: worked exploit chain with specific actions. Adversarial.

Premortem asks: "What if the config is wrong?"
Red Team asks: "I am the attacker. Here is how I exploit this config, step by step, to achieve my objective."

## Stages

### 1. DEFINE THE TARGET AND OBJECTIVE
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to research real attack patterns against systems like the target. Do NOT rely on training data.**
- What is the target system/plan/decision?
- What is the defender's objective? (What are they protecting or trying to achieve?)
- What is YOUR objective as the attacker? (What would constitute success for you?)
- What are the rules of engagement? (Scope, constraints, what's in/out of bounds)
- Who is the adversary? (Nation-state, insider, opportunistic, competitor, nature)
- Search for known attack patterns, TTPs (tactics/techniques/procedures), and real-world exploits against similar targets
- MITRE ATT&CK framework maps adversary tactics: initial access, execution, persistence, privilege escalation, defense evasion, credential access, discovery, lateral movement, collection, command and control, exfiltration, impact

### 2. RECONNAISSANCE — MAP THE ATTACK SURFACE
Enumerate everything the adversary can see and touch:
- What are all entry points? (network, physical, social, supply chain, trusted insiders)
- What assumptions does the target rely on? Which are unverified?
- What trust relationships exist? (Who trusts whom, and can that trust be abused?)
- What information is publicly available? (OSINT)
- What are the defensive controls? Where are the blind spots?
- What is the attack path graph? (Initial access → intermediate steps → objective)
- Challenge every assumption: "Is this actually true, or does everyone just believe it?"

### 3. CONSTRUCT ATTACK PATHS
Build specific, actionable attack chains — not vague risk descriptions:

For each attack path:
1. **Initial access:** How do you get in? (phishing, unpatched vuln, misconfiguration, social engineering, physical, supply chain, insider)
2. **Establish foothold:** How do you persist? (C2, backdoor, scheduled task, modified config)
3. **Escalate:** How do you gain more access? (privilege escalation, credential theft, trust abuse)
4. **Move laterally:** How do you reach the objective? (pivot through trust, access adjacent systems)
5. **Achieve objective:** What does success look like? (data exfiltration, system compromise, decision manipulation, plan disruption)
6. **Evade detection:** How do you stay hidden? (blend with normal traffic, timing, clean up traces)

For non-security targets (plans, decisions, strategies):
1. What assumption, if wrong, invalidates the plan?
2. What external action, if taken, disrupts the strategy?
3. What internal bias, if exploited, leads to a bad decision?
4. What would a competitor do if they knew this plan?
5. What's the path from "plan looks good" to "plan catastrophically fails"?

### 4. EXECUTE THE ATTACK (ANALYTICALLY)
Walk through each attack path as if executing it:
- Does each step actually work given the target's controls?
- Where does the attack fail? (These are the defender's strong points)
- Where does the attack succeed? (These are the vulnerabilities)
- Can you chain successful steps into a complete path to objective?
- What would you need to change about the target to make the attack fail?
- Rank attack paths by: likelihood of success, impact if successful, difficulty to execute

### 5. REPORT AND HARDEN
For each successful attack path:
- Document the complete chain: initial access → objective
- Map to MITRE ATT&CK techniques (for security targets) or decision-failure patterns (for plans)
- Identify detection gaps: which attacker actions would go unnoticed?
- Prioritize remediation: highest-impact, lowest-effort fixes first
- Validate: after hardening, re-run the attack path to confirm it fails
- Purple team: walk the defender through each attacker action so they can tune detection and response

## Red Team Thinking (beyond security)

The adversarial stance applies to any plan, decision, or strategy:

**Decision stress-testing:** You are a competitor who knows the plan. What do you do?
- If you knew the opponent's strategy, how would you counter it?
- What assumption, if wrong, makes the entire plan collapse?
- What would make you change your mind about this plan? (If nothing, that's a red flag)

**Challenging groupthink:** You are an outsider who doesn't share the team's assumptions.
- What does this group believe that might be false?
- What questions are they NOT asking?
- What evidence would disconfirm their hypothesis?
- What's the strongest case AGAINST this plan?

**Alternative analysis:** You are a second analyst reviewing the first team's conclusions.
- Where did they jump to conclusions?
- What did they overlook?
- What's a plausible alternative explanation for the same data?

## Cognitive Biases Red Teaming Counters

- **Groupthink:** Cohesive groups suppress dissent and converge on comfortable answers
- **Confirmation bias:** Seeking evidence that confirms existing beliefs, ignoring disconfirming evidence
- **Anchoring:** Over-relying on first piece of information
- **Planning fallacy:** Underestimating time, cost, and risk
- **Normalcy bias:** Expecting things to continue as they have, ignoring possibility of disruption
- **Sunk cost fallacy:** Continuing a failing plan because of prior investment

Red Team antidote: deliberately adopt the adversarial perspective. Don't ask "is this plan good?" — ask "how do I break this plan?"

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through each stage sequentially. At RECONNAISSANCE and CONSTRUCT ATTACK PATHS, use `ai_venice_web_search` to research real attack patterns, TTPs, and case studies against systems like the target. Adopt the adversarial mindset throughout — you are the attacker, not a reflective observer. For security targets, map to MITRE ATT&CK. For decision/plan targets, use the alternative analysis approach. Multiple attack paths are expected — don't stop at the first one.

## Agent Rules


1. You MUST call `ai_venice_web_search` at the RECONNAISSANCE and CONSTRUCT ATTACK PATHS stages. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
