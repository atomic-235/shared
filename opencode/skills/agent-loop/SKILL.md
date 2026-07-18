---
name: epistemic-ledger
description: Use when conducting reasoning through the epistemic ledger MCP — adding sources, claims, proposals, critiques, obligations, verified facts, subjective logic opinions, checking for repetition/contradiction/obligation violations, decay monitoring, or running gated orchestrator phases. Covers computational checks the LLM cannot fake: cosine similarity vs rejected proposals, open critique findings blocking advance, polarity-reversal contradiction detection. Triggers on keywords like "ledger", "epistemic", "repetition", "contradiction", "obligation", "gated", "phase advance", "retract claim", "violation", "source verification", "decay", "subjective logic". Reuses outputs from research-red-team, research-premortem, research-investigation, research-ach as ledger content.
---

# Epistemic Ledger Skill

This skill guides the use of the agent_loop MCP server for computational
reasoning accountability. The system holds the LLM to its prior claims
and proposals through checks it cannot fake — they run over external
state the LLM cannot rewrite.

## Core Principle

Every check is a **computation**, never a prompt. Violations are **proven**,
not suggested. The LLM cannot fake compliance because checks run over a
SQLite + RDF ledger it does not control.

## Workflow: Gated Reasoning Session

### 1. Initialize the Ledger

```
set_persist_path(path="session_topic.ttl")
```

MUST be called before any add_* operations. The TTL file is saved to the
current working directory and reloaded on restart. Embeddings (sqlite-vec)
are stored alongside in a `.db` file.

### 2. Record Claims

```
add_claim(
  id="CL-001",
  text="Atoms are the real arbitrage in this market",
  polarity="positive",
  confidence=0.8,
  evidence_refs=["CL-002", "CL-003"]
)
```

**Polarity** drives the contradiction check:
- `positive` — asserts something is true/good
- `negative` — asserts something is false/bad
- `neutral` — observational, cannot contradict

**Confidence** drives the calibration check (Phase 2): if confidence is
high but `evidence_refs` is empty, flag overconfidence.

### 3. Submit Proposals

```
add_proposal(
  id="PR-001",
  text="Build ontology → ASP → OR-Tools pipeline",
  status="proposed",
  evidence_refs=["CL-001"]
)
```

If rejected later:
```
add_proposal(id="PR-001", text="...", status="rejected",
  rejection_reason="No evidence for atom arbitrage claim.")
```

**Rejected proposals feed the repetition check.** The embedding is retained
so any future proposal with high cosine similarity triggers a violation.

### 4. Run Critiques (Obligation-Generating Phases)

```
add_critique(
  id="CRT-001",
  critique_type="red_team",
  findings=[
    "F-001|Base case has no supporting evidence",
    "F-002|Scope expanding without validation"
  ],
  target_id="PR-001"
)
```

Each finding becomes an obligation:
```
add_obligation(
  id="OBL-001",
  critique_id="CRT-001",
  finding_text="Base case has no supporting evidence",
  status="open"
)
```

**Open obligations block phase advance.** This is the check that catches
"summarized red team findings without responding to them."

### 5. Run Computational Checks

#### Repetition Check

```
check_repetition(proposal_text="Atoms represent the true arbitrage", threshold=0.85)
```

Returns PASS/FAIL. If FAIL, the proposal is too similar (cosine similarity)
to a rejected proposal. The LLM must explain what is different, not repackage.

#### Obligation Check

```
check_obligations(phase_id="")
```

Returns PASS/FAIL. If FAIL, open obligations exist and block phase advance.
The LLM must disposition each one before proceeding.

#### Contradiction Check

```
check_contradiction(
  claim_text="Atoms are just a speculation layer",
  claim_polarity="negative",
  threshold=0.85
)
```

Returns PASS/FAIL. If FAIL, the new claim is similar to an active claim with
opposite polarity. The LLM must **retract the old claim first**:

```
retract_claim(claim_id="CL-001", reason="Position reversed after new evidence.")
```

#### Run All Checks at Once

```
check_all(
  proposal_text="...",
  claim_text="...",
  claim_polarity="negative",
  phase_id="PH-001"
)
```

### 6. Disposition Obligations

Before phase advance, every open obligation must be closed:

```
update_obligation(
  obligation_id="OBL-001",
  status="accepted",
  disposition="Added evidence from SEC filing CL-005 to support base case."
)
```

Or rebut:
```
update_obligation(
  obligation_id="OBL-002",
  status="rebutted",
  disposition="Scope expansion is justified because each framework addresses a distinct failure mode."
)
```

### 7. Record Violations

```
record_violations(
  proposal_text="...",
  claim_text="...",
  claim_polarity="negative"
)
```

Creates Violation entities in the ledger with PROVEN evidence (similarity
scores, obligation IDs, polarity comparison). The LLM must resolve each
violation before the orchestrator advances.

### 8. Resolve Violations

```
resolve_violation(
  violation_id="VIO-001",
  resolution="Retracted CL-001 and provided new evidence supporting the revised position."
)
```

### 9. Query Ledger State

```
get_open_obligations()       # What's blocking advance
get_active_claims()          # Current positions
get_rejected_proposals()     # What's been tried and failed
get_phase_state(phase_state_id="PS-001")  # Orchestrator state
```

### 10. SPARQL Queries

```
sparql_query(query="SELECT ?id ?text WHERE { ?c a ex:Claim ; ex:id ?id ; ex:text ?text ; ex:status \"active\" . }")
```

Prefix: `ex: <https://agent-loop.local/>`

### 11. Register Sources

Sources are the provenance backbone for Claims. Each source has NATO
STANAG 2511 reliability/credibility ratings and URL verification.

```
add_source(
  id="S-001",
  title="SEC 10-K Filing",
  url="https://www.sec.gov/filing/123",
  tier=1,
  reliability="A",
  credibility="1",
  attestation_type="regulatory_filing",
  exact_quote="The company reported revenue of $10B",
  date_accessed="2026-07-18"
)
```

**Automatic:**
- STANAG trust opinion auto-generated from reliability/credibility (A-1 → b=0.90, u=0.05)
- Embedding stored for duplicate detection
- SHACL validates: valid URL, valid enum values, no duplicate IDs

**NATO ratings:** A=Completely reliable ... F=Cannot judge. 1=Confirmed ... 6=Cannot judge. F-6 = vacuous opinion (u=1.0) for AI content.

### 12. Verify Source URL

URL verification uses the opencode `webfetch` tool (not raw httpx) so it
goes through the same proxy/auth stack as user-driven research.

**Step 1:** Fetch the URL using `webfetch`:
```
webfetch(url="https://www.sec.gov/filing/123", format="text")
```

**Step 2:** Pass the fetched content to the ledger:
```
verify_source_content(
  source_id="S-001",
  fetched_content="<content from webfetch>",
  http_status=200,
  final_url="https://www.sec.gov/filing/123"
)
```

**Checks:** HTTP 200 + exact_quote found in content. Result stored in graph.

### 13. Promote to Verified Fact

```
add_verified_fact(
  id="VF-001",
  claim_id="CL-001",
  statement="Company revenue is $10B (verified via SEC filing)",
  promoted_by_gate="GATE_2",
  decay_days=90
)
```

**Decay windows by gate:**

| Gate | Default decay | Use case |
|------|--------------|----------|
| GATE -1 | 90 days | Source authentication |
| GATE 0 | 30 days | Discovery |
| GATE 1 | 90 days | Access verification |
| GATE 2 | 90 days (30 if market event) | Return/outcome validation |
| GATE 3 | 30 days (7 if active conflict) | Geopolitical stability |
| GATE 4 | 180 days | Tax & regulatory |
| GATE 5 | 180 days | Currency & liquidity |

After `expires_at`, the fact becomes STALE. Use `check_decay()` to find
expired facts and `invalidate_fact()` to cascade-invalidate dependents.

### 14. Subjective Logic Opinions

```
add_opinion(
  id="OPN-001",
  entity_id="CL-001",
  field_name="opinion",
  belief=0.8,
  disbelief=0.1,
  uncertainty=0.1
)
```

**Rules:** b+d+u must equal 1.0 (SHACL enforced).

Fuse multiple opinions:
```
fuse_opinions(
  opinion_ids=["OPN-001", "OPN-002"],
  operator="cbf"
)
```

**Operators:**
- `cbf` — independent sources (reduces uncertainty)
- `abf` — correlated/circular sources (conservative)
- `wbf` — weighted by source trust (requires weights array)
- `consensus` — group opinion formation

Output includes ICD 203 mapping: "92%, u=0.05. Confidence: high. Likelihood: very_likely."

### 15. Decay Monitoring

```
check_decay()           # Find expired facts, mark as stale
get_expired_facts()     # Get all stale/invalidated facts
invalidate_fact(vf_id="VF-001", reason="Source retracted")
```

Invalidation cascades: ACTIVE assessments referencing the invalidated
fact become SUPERSEDED. This prevents stale evidence from silently
underpinning live conclusions.

### 16. Phase Transitions — `advance_phase`

You **cannot** move between phases by creating a new `add_phase_state`.
That bypasses the gates. Use `advance_phase` which runs all gate checks:

```
advance_phase(to_phase="PH-002")
```

Runs:
1. **Dependency check** — `to_phase.depends_on` must include current phase
2. **`from_phase.exit_checks`** — runs every check in `Phase.exit_checks`
3. **Required artifacts** — every type in `from_phase.required_artifact_types`
   must have an Artifact with `phase_id=from_phase`
4. **`to_phase.entry_checks`** — runs every check in `Phase.entry_checks`

If any check fails, `advance_phase` returns BLOCKED with a list of
violations and **does not** update `PS-001.current_phase`. Fix the
violations and try again.

This is the missing "system drives" piece from the orchestrator loop.
The LLM cannot bypass gates by creating new PhaseState entries — the
checks block the transition.

For non-transition updates (e.g., marking artifacts completed, setting
`base_case_proven=true`), use `update_phase_state` directly:

```
update_phase_state(append_completed_artifact="ART-001", base_case_proven=true)
```

## Mandatory Delegation By Phase Type

The orchestrator has phase types. Each type **MUST** delegate to a specific
subagent via `task`. The LLM cannot do the work itself — it must call the
appropriate agent, parse the structured output, and map it to ledger entities.

| Phase type | MUST delegate to | What comes back |
|-----------|-----|-----------------|
| `research` (evidence gathering, framing) | `research-investigation-fast` or `research-investigation` | Sources + verified facts |
| `ach` (competing hypotheses) | `research-ach-fast` or `research-ach` | Hypothesis matrix |
| `red_team` (attack proposal) | `research-red-team-fast` or `research-red-team` | Attack paths + findings |
| `premortem` (failure modes) | `research-premortem-fast` or `research-premortem` | Failure modes + findings |
| `verify` (cross-check sources) | `research-investigation-fast` or `research-investigation` | Source corroboration |

The phase does the work itself ONLY for: framing (no evidence yet),
synthesize (combine verified findings into output), output (present
final assessment).

## Per-Phase Workflow (Mandatory Sequence)

### Research phase (any phase with `phase_type="research"`)

1. Delegate via `task`:
   ```
   task(subagent="research-investigation-fast",
        prompt="Investigate: <specific question>. Return URL, quote, "
               "claim text, source type.")
   ```
2. For each finding from agent output, run:
   ```
   webfetch(url="...")  → verify_source_content(source_id="S-N", fetched_content=...)
   add_source(id="S-N", url="...", exact_quote=...)
   add_claim(id="CL-N", text=finding, polarity="positive", confidence=0.8,
             evidence_refs=["S-N"])
   ```
3. Produce required artifact:
   ```
   add_artifact(id="ART-N", artifact_type="research_notes", phase_id="PH-N",
                content=<proof of work>)
   ```
4. Run `check_obligations(phase_id="PH-N")` — must pass to advance
5. Call `advance_phase(to_phase="PH-NEXT")`

### ACH phase (competing hypotheses)

1. Delegate:
   ```
   task(subagent="research-ach-fast",
        prompt="Evaluate these hypotheses for: <question>. H1=..., H2=..., H3=...")
   ```
2. Map agent's hypothesis matrix to ledger:
   - Each surviving hypothesis → `add_proposal(id="PR-N", text=hypothesis,
     evidence_refs=["CL-N"])`
   - Each refuted hypothesis → `add_proposal(..., status="rejected",
     rejection_reason="Refuted by <evidence>")`
3. Produce `hypothesis_matrix` artifact
4. `advance_phase`

### Red team / premortem phases

1. Delegate:
   ```
   task(subagent="research-red-team-fast",
        prompt="Attack the proposal: <PR-N>. Find assumptions, weak links.")
   ```
2. Map findings to obligations:
   ```
   add_critique(id="CRT-N", critique_type="red_team",
                findings=["F-1|text", ...], target_id="PR-N")
   For each finding:
   add_obligation(id="OBL-N", critique_id="CRT-N",
                  finding_text=text, status="open", phase_id="PH-N")
   ```
3. `advance_phase` will BLOCK on these open obligations — that's the gate.
4. Disposition each (accept or rebut) before retry:
   ```
   update_obligation(obligation_id="OBL-N", status="accepted",
                     disposition="Addressed by adding evidence from ...")
   ```
5. Re-call `advance_phase`

### Failure modes the system catches

- **You did the work without delegating:** Tool calls are visible in the
  transcript. Planning without delegation = nothing in the ledger.
- **You created PS-N to "advance":** Bypasses gates. `add_phase_state` with
  a non-PS-001 id does UPSERT-replace, but gates STILL run when you try to
  use the artifacts. Better: always use `advance_phase`.
- **Empty gates:** If `exit_checks=[]`, the obligation check still runs by
  default. If `required_artifact_types=[]`, anything goes. So define them.
- **You added claims without sources:** calibration check (Phase 2) flags
  `confidence>0.7` with empty `evidence_refs`. Always link to verified Source.
- **You summarized critique findings:** obligation check BLOCKS advance
  until each finding is dispositioned (accept or rebut).

## Check Reference

| Check | Computation | Catches |
|-------|-------------|---------|
| repetition | cosine sim vs rejected proposals | repackaged re-proposals |
| obligation | count open obligations | ignored red team findings |
| contradiction | sim + opposite polarity | silent position reversals |
| gate | required artifacts exist | building before validating |
| calibration | confidence vs evidence count | overconfident conclusions |
| scope | component count vs base case | framework expansion |
| diagnosticity | solver vs new approach | unnecessary ACH |
| decay | expires_at < now | stale evidence used as current |
| source_verification | HTTP 200 + exact_quote match | unverified URLs cited as evidence |

## Gate Reference

| Gate | Trigger | Decay |
|------|---------|-------|
| GATE -1 | Source authentication | 90 days |
| GATE 0 | Discovery | 30 days |
| GATE 1 | Access verification | 90 days |
| GATE 2 | Return/outcome validation | 90 days (30 if market event) |
| GATE 3 | Geopolitical stability | 30 days (7 if active conflict) |
| GATE 4 | Tax & regulatory | 180 days |
| GATE 5 | Currency & liquidity | 180 days |

## Key Rules

- `set_persist_path` MUST be called first
- **Use `advance_phase` to transition — do NOT create new `add_phase_state`**
- **Delegate via `task` for research/ach/red_team/premortem phases**
- Retract contradicted claims before asserting new ones
- Open obligations block phase advance — no exceptions
- Repetition threshold default 0.85 — tunable per check
- Violations are PROVEN (computations), not suggested (prompts)
- The ledger is external state the LLM cannot rewrite
- Every factual claim should have a source with URL
- b+d+u=1.0 always (enforced at pydantic + SHACL level)
- No compound assumptions — each link verified independently
- Negative search mandatory — search for evidence against
- Training data never valid for time-sensitive facts
- Stale facts (expired decay window) must be re-verified before use
- URL verification uses webfetch (not raw httpx) — same proxy stack as user

## Embeddings

Repetition and contradiction checks use Venice AI `bge-m3` embeddings (1024
dims) stored in sqlite-vec. Requires `VENICE_API_KEY`. If the key is missing,
similarity checks return empty results — entity creation still works but
checks cannot detect similarity.
