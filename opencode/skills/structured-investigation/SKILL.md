---
name: structured-investigation
description: Use when planning and conducting a structured investigation from start to finish — defining what information is needed, gathering it from public sources, verifying through source reliability tiering and cross-referencing, assigning confidence levels, and producing defensible documented findings. Tool-agnostic. Applies to due diligence, security analysis, crypto/web3 research, journalism, and any systematic information gathering requiring verification.
---

# Structured Investigation Framework

Use this framework when you need to investigate a person, organization, event, or claim systematically — from planning what information you need, through gathering and verifying it, to producing defensible documented findings.

A tool-agnostic 8-phase process from [inet-investigation.com](https://www.inet-investigation.com/osint-workflow-the-8-phase-investigation-framework/). Core principle: "Tools change. The process does not." The framework is independent of any specific tool or database — it defines the investigation process itself.

## Core Principle

**Defensible findings require documented sources, explicit confidence levels, and negative results.** A claim is only as good as its evidence, and evidence must be tied to sources and timestamps. What you didn't find is as important as what you did find.

## Stages

### 1. DEFINE THE OBJECTIVE
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to research the domain and available sources. Do NOT rely on training data.**
- Write a specific, answerable question before starting
- Not "research this company" but "confirm LLC registration, owner has no judgments, address is real, no undisclosed related parties"
- The objective determines:
  - Which sources to search
  - What a confirming result looks like
  - What a disconfirming result looks like
  - When the investigation is complete
- Search for what public records, databases, and sources are available for this type of investigation
- Define success criteria: what would constitute a verified finding vs. an unverified lead

### 2. COLLECT SEED IDENTIFIERS
Gather every known data point before searching:
- Names, aliases, nicknames, maiden names
- Dates (birth, incorporation, registration)
- Addresses (physical, email, IP)
- Phone numbers
- Usernames, handles, account IDs
- Employer names, business entities
- Social media profiles
- Public keys, wallet addresses, transaction hashes
- Each identifier is a potential entry point into a different record system
- Seed quality determines investigation quality — missing identifiers mean missed entry points
- Use `ai_venice_web_search` to find additional identifiers from public sources

### 3. RUN THE INITIAL SEARCH
Systematic multi-pass approach:
- **Search engine pass** — general queries with different combinations of identifiers
- **People/aggregator search** — commercial databases, people-finder sites
- **Government records** — courts, property deeds, business registrations, SEC filings, licensing boards (these are Tier 1 authoritative anchors)
- **Social media sweep** — all major platforms using known usernames/emails
- **Document everything found AND not found**
- Government records are the authoritative anchor — start and end with them

### 4. PIVOT FROM EVERY DISCOVERY
This is the core technique that distinguishes investigation from simple search:
- Every new identifier discovered becomes a new search entry point
- Email → domain → other accounts on that domain
- Address → property records → business registrations at that address
- Phone number → reverse lookup → associated names → new searches
- Photo → reverse image search → other profiles using same image
- Username → search across platforms → cross-reference identities
- Wallet address → blockchain explorer → transaction partners → cluster identification
- Business name → registered agent → other businesses with same agent → related parties
- **Most significant findings emerge from the 2nd or 3rd pivot — not the initial search**
- Follow every identifier until it confirms, contradicts, or dead-ends
- This phase loops back to itself — pivots generate new identifiers which generate new pivots
- Use `ai_venice_web_search` at each pivot to find new information

### 5. APPLY SOURCE HIERARCHY
Weight every source by reliability tier:
- **Tier 1: Government records** — authoritative. Court filings, property deeds, business registrations, SEC filings, licensing boards. Highest weight.
- **Tier 2: Regulatory/professional records** — highly reliable. Regulatory filings, professional licensing records, accredited registry data.
- **Tier 3: Commercial aggregators** — useful leads, must verify independently. People-finder databases, commercial data brokers, paid lookup services.
- **Tier 4: Self-reported digital sources** — leads only. LinkedIn, social media, company websites, personal blogs. Subject to fabrication and self-presentation bias.
- **Tier 5: Anonymous/unverifiable** — context only. Forums, anonymous reviews, unattributed posts, rumor sites. Lowest weight.
- **Rule: Every Tier 3-5 finding must be cross-referenced against a Tier 1 source before becoming a verified finding**
- When Tier 1 sources are unavailable for a jurisdiction or topic, document the gap explicitly

### 6. CROSS-REFERENCE FINDINGS
Explicit verification protocol:
- **1 source reporting a fact = a lead** — unverified, not actionable, needs corroboration
- **Same fact in 2 independent sources = corroboration** — working conclusion, keep verifying
- **Same fact confirmed by Tier 1 source = verified finding** — actionable, high confidence
- **Conflicts between sources are findings to investigate, not problems to dismiss**
  - Why do sources disagree? Is one outdated? Is one Tier 4 self-reporting vs. Tier 1 government record?
  - Investigate the conflict — it often reveals the most important information
- Independence requirement: two articles citing the same press release = 1 source, not 2
- Use `ai_venice_web_search` to find additional sources for cross-referencing

### 7. ASSIGN CONFIDENCE LEVELS
Every finding gets an explicit confidence rating:
- **Low**: single source, unverified — lead only, not actionable. "Found on one social media profile, not confirmed elsewhere."
- **Medium**: corroborated by multiple independent sources — working conclusion, keep verifying. "Two independent news articles report this, no government record found yet."
- **High**: verified against Tier 1 authoritative source, consistent with other findings — actionable. "Confirmed in court filing, consistent with property records and SEC filings."
- Confidence is per-finding, not per-investigation — different findings will have different confidence levels
- Document what would raise or lower confidence for each finding

### 8. PRODUCE STRUCTURED OUTPUT
Document the investigation completely:
- **What was found** — each finding with source, tier, confidence level, retrieval date
- **What was searched** — every system checked, every tool used, every jurisdiction covered, every query run
- **What wasn't found** — negative results are critical. "No criminal records found in TX, OK, LA courts or PACER" is a finding, not an absence
- **Source documentation** — URL, retrieval date, filing identifier, screenshot reference for every record
- **Findings vs. conclusions** — a court filing IS a finding; what it implies requires judgment. Keep them separate.
- **Confidence summary** — overall assessment with explicit gaps and limitations
- **Reproducibility** — another investigator should be able to follow your steps and reach the same conclusions

## How This Differs From Other Skills

- **vs. scientific-method:** Scientific method tests hypotheses through controlled experiments. This gathers information from external uncontrolled sources requiring verification. Different domain, different methodology, different verification approach.
- **vs. ACH:** ACH is an analysis technique used *within* an investigation (evaluating evidence against competing hypotheses). This is the investigation process itself — how you get the evidence, verify it, and document it.
- **vs. PPDAC:** PPDAC is for statistical inquiry with quantitative data. This is for qualitative information gathering with source reliability assessment.
- **vs. research-debug:** Diagnoses bugs through hypothesis testing. This investigates entities/events through information gathering and source verification.
- **vs. link-analysis:** Link analysis maps entity relationships. This is the process for gathering and verifying the information that link analysis uses. Complementary — use this first, then link-analysis to map relationships.

## Examples by Domain

**Crypto/web3 research:**
- Objective: Verify a project team's identities and check for undisclosed related parties before investing
- Seeds: Team names from website, LinkedIn URLs, wallet addresses from token contract
- Pivots: Team member email → other projects → LinkedIn → cross-reference claimed credentials → wallet address → blockchain explorer → transaction partners → are team wallets sending tokens to each other before public sale?
- Source hierarchy: SEC EDGAR (Tier 1) vs. company website claims (Tier 4)
- Cross-reference: "Team member claims MIT degree" → check MIT alumni directory (Tier 2) → confirmed or not

**Due diligence:**
- Objective: Confirm company is legitimately registered, owner has no judgments, address is real, no undisclosed related parties
- Seeds: Company name, registered agent, address, owner name
- Pivots: Company name → state filing → registered agent → other companies with same agent → shared address → are these related parties?
- Source hierarchy: State business registry (Tier 1) vs. company website (Tier 4)
- Negative results: "No judgments found in PACER" is a verified finding

**Security vendor analysis:**
- Objective: Verify security certifications, check breach history, map corporate ownership for hidden relationships
- Seeds: Company name, certifying bodies, parent company, executives
- Pivots: Parent company → subsidiaries → shared executives → previous breach disclosures → are certifications current?
- Source hierarchy: Certifying body records (Tier 1-2) vs. company marketing claims (Tier 4)

**Journalism:**
- Objective: Verify claims, build a paper trail from primary sources, document what was searched and not found
- Seeds: Claimed facts, cited sources, named individuals
- Pivots: Each source → its sources → primary document → is the chain intact?
- Reproducibility: Another journalist should be able to follow the same steps

## Scope and Limitations

**Works on:** Due diligence, background research, crypto/web3 investigation, security vendor assessment, claim verification, entity investigation, any systematic information gathering requiring source verification and documented findings.

**Does NOT work on:**
- **Hypothesis testing** — use scientific-method or ACH instead
- **Bug diagnosis** — use research-debug
- **Statistical analysis** — use research-ppdac
- **Fast-moving situations** — use OODA loop instead
- **Decision-making under bias** — use WRAP

**Limitations:**
- Primarily designed for person/entity investigation; less directly applicable to abstract research questions
- Source hierarchy tiers assume Western-style public records systems; adjust for jurisdictions with limited public records
- Doesn't cover technical/forensic verification (image authentication, metadata analysis) — those are techniques, not framework phases
- Iterative pivoting can feel non-linear; requires discipline to not skip phases
- Time-intensive — proper investigation with pivoting and cross-referencing cannot be rushed

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through phases sequentially, but Phase 4 (pivot) loops back to itself. At DEFINE THE OBJECTIVE, use `ai_venice_web_search` to research available sources. At each pivot, search for new information. The source hierarchy and cross-referencing protocol are the core verification mechanism — do not skip them. Document everything, including what wasn't found.

## Agent Rules


1. You MUST call `ai_venice_web_search` at the DEFINE OBJECTIVE, INITIAL SEARCH, and PIVOT stages. No exceptions.
2. NEVER fabricate URLs, citations, or sources. Only cite what search results return.
3. If a search returns no results, state that explicitly. Do NOT fill in with training data.
4. NEVER write analysis text before obtaining search results.
5. Your ONLY tools are `ai_venice_web_search`, `webfetch`, and `read`. You cannot edit files or run commands.
6. If `ai_venice_web_search` is rate-limited or returns errors, use Playwright browser tools as fallback: `playwright_browser_navigate` to visit a search engine (e.g. https://duckduckgo.com/?q=QUERY), `playwright_browser_snapshot` to read results, `playwright_browser_click` to follow links, `playwright_browser_evaluate` to extract text. The router grants you exclusive browser access — if your Task prompt says "You have exclusive browser access", use Playwright freely. If it says "Do NOT use Playwright", stick to web_search/webfetch only. Treat Playwright results the same as search results — cite URLs, never fabricate.
