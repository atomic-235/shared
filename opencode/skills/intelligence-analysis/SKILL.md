---
name: intelligence-analysis
description: Use when conducting intelligence analysis using the MCP intelligence tools — adding sources, claims, verified facts, hypotheses, assessments, ACH matrices, or checking duplicates. Covers the full CIA tradecraft workflow: source registration with NATO STANAG ratings, claim extraction, gate verification, subjective logic fusion, ACH scoring, ICD 203 output, decay monitoring, and calibration tracking. Triggers on keywords like "intelligence", "analysis", "source", "hypothesis", "assessment", "ACH", "verify", "calibration", "decay".
---

# Intelligence Analysis Skill

This skill guides the use of the intelligence MCP server for CIA-level
structured intelligence analysis. The system implements ICD 203 analytic
standards, NATO STANAG 2511 source evaluation, subjective logic
probabilistic reasoning, and Heuer's ACH methodology.

## Workflow: Full Intelligence Assessment

### 1. Register Sources

```
add_source(
  id="S-001",
  title="US State Dept Travel Advisory",
  url="https://travel.state.gov/...",
  tier=1,
  reliability="A",
  credibility="1",
  attestation_type="institutional_attestation",
  exact_quote="Reconsider travel to the UAE"
)
```

**Automatic:**
- URL verified (HTTP 200 + exact_quote found in page content)
- STANAG opinion auto-assigned from reliability/credibility (A-1 → b=0.90, u=0.05)
- Embedding stored for duplicate detection (Venice AI bge-m3)
- SHACL validates: no duplicate IDs, valid URL, valid enum values

**NATO ratings:** A=Completely reliable ... F=Cannot judge. 1=Confirmed ... 6=Cannot judge. F-6 = vacuous opinion (u=1.0) for AI content.

### 2. Extract Claims

```
add_claim(id="C-001", source_id="S-001", statement="UAE at Level 3 travel advisory")
add_opinion(entity_id="C-001", field_name="opinion", belief=0.9, disbelief=0.05, uncertainty=0.05)
```

**Rules:** b+d+u must equal 1.0. Source must exist. Duplicate claims detected via embeddings.

### 3. Promote to Verified Facts

```
add_verified_fact(id="VF-001", claim_id="C-001", statement="UAE Level 3 active",
  decay_days=30, promoted_by_gate="GATE_3")
```

**Decay windows:** GATE 3 = 30 days (7 if active conflict). GATE 2 = 90 days. Expired facts = UNVERIFIED.

### 4. Create Hypotheses

```
add_hypothesis(id="H-001", statement="Ceasefire re-stabilizes within 60 days",
  supporting_evidence=["VF-008"], refuting_evidence=["VF-004"],
  competing_hypotheses=["H-002", "H-003"])
add_hypothesis(id="H-002", statement="Conflict re-escalates to full war",
  supporting_evidence=["VF-004", "VF-006"])
```

**Always create competing hypotheses.** ACH requires multiple. SHACL verifies all VF and hypothesis IDs resolve.

### 5. Fuse Opinions

```
fuse_opinions(opinions=[
  {belief=0.9, disbelief=0.05, uncertainty=0.05},   # A-1 gov source
  {belief=0.7, disbelief=0.15, uncertainty=0.15},   # B-2 news
], operator="cbf")
```

**Operators:**
- `cbf` — independent sources (reduces uncertainty)
- `abf` — correlated/circular sources (conservative, prevents false confidence)
- `wbf` — weighted by source trust (requires weights array)

Output includes ICD 203 mapping: "87%, u=0.08. Confidence: high. Likelihood: very_likely."

### 6. Create ACH Matrix

```
add_ach_matrix(id="ACH-001", assessment_id="A-001",
  hypothesis_ids=["H-001", "H-002", "H-003"],
  evidence_ids=["VF-001", "VF-004", "VF-006"],
  auto_scored=true)
```

**Automatic:** Cells scored C/I/N/A from subjective logic opinions. Returns `least_inconsistent` — the hypothesis that survives elimination (ACH's key output: least inconsistent, not most consistent).

### 7. Publish Assessment

```
add_assessment(id="A-001", title="UAE Security Assessment",
  confidence_level="moderate", likelihood="roughly_even_chance",
  hypotheses=["H-001", "H-002", "H-003"],
  verified_facts=["VF-001", "VF-004"],
  sensitivity_analysis="Optimistic: 24%. Base: 62%. Pessimistic: 49%.",
  alternative_explanations="China mediation could force re-stabilization",
  status="draft")
```

**ICD 203 enforcement (SHACL):**
- `status=reviewed` → must have sensitivity_analysis + alternative_explanations
- `status=active` → must have approved_by (human review)
- `confidence=low` → must have alternative_explanations + hypotheses
- Confidence and likelihood MUST be in separate sentences in output

### 8. Monitor and Maintain

```
check_decay()              # Find expired facts/sources
query_gaps()               # Find missing evidence, orphan refs
check_duplicates(text="...", entity_type="source")  # Semantic dedup
get_assessment(assessment_id="A-001")  # Retrieve full assessment
```

### 9. Calibration (Progressive Autonomy)

```
add_agent(id="AGT-001", name="collector-1", role="collector", autonomy_level="l1_copilot")
add_decision_record(id="DR-001", decided_by="AGT-001", verdict="approve")
get_calibration(agent_id="AGT-001")
```

**Beta-Binomial:** α=1+n_approve, β=1+n_reject. Posterior mean shrinks toward 0.5 with few decisions, converges to true rate as decisions accumulate. L2 requires rate≥0.85 + 100 decisions. L3 requires rate≥0.90 + 200 decisions.

### 10. Cascade Invalidation

```
invalidate_fact(vf_id="VF-001")
```

Sets VF status → invalidated. ACTIVE assessments referencing it → SUPERSEDED. All affected assessments get invalidation flag.

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

- Every factual claim needs a source with URL
- b+d+u=1.0 always (enforced at pydantic + SHACL level)
- No compound assumptions — each link verified independently
- Negative search mandatory — search for evidence against
- Training data never valid for time-sensitive facts
- Every assessment is DRAFT until human review
- L3 is permanent ceiling in polluted information environment
