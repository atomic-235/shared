---
name: link-analysis
description: Use when mapping relationships between entities (people, organizations, events, transactions, addresses, accounts) to reveal hidden connections, identify network structure, and discover patterns invisible in linear document review. Applies to due diligence, fraud detection, crypto wallet clustering, corporate ownership mapping, supply chain analysis, and any situation where entity relationships matter.
---

# Link Analysis Framework

Use this framework when you need to map and analyze relationships between entities — people, organizations, events, transactions, addresses, accounts — to reveal hidden connections, identify network structure, and discover patterns invisible in linear document review.

From [Cambridge Intelligence](https://cambridge-intelligence.com/learn/graph-visualization/link-analysis/), [IntegrityRisk](https://www.integrityriskintl.com/link-analysis-due-diligence/), and academic literature on network analysis. Core principle: "Being linked to a suspicious entity does not prove guilt — but it does invite investigation."

## Core Principle

**Network structure reveals what individual documents cannot.** A single filing shows one relationship. A network map shows all relationships simultaneously, revealing central nodes, hidden bridges, clusters, gaps, and anomalies. The pattern of connections IS the finding.

## Stages

### 1. DEFINE SCOPE AND ENTITIES OF INTEREST
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to research the domain and available data sources. Do NOT rely on training data.**
- What network are you mapping? (corporate ownership, transaction flows, social connections, supply chain)
- Who/what are the seed entities? (starting points for the network)
- What relationship types are relevant? (financial, social, operational, hierarchical, temporal, spatial)
- What is the boundary of the network? (how many degrees of separation to include)
- What question are you trying to answer? (hidden ownership? coordinated activity? conflicts of interest? fraud patterns?)
- Search for known relationship patterns, data sources, and network analysis approaches for this domain

### 2. IDENTIFY ALL ENTITIES
Extract every entity from available source materials:
- **People** — individuals, directors, officers, beneficiaries, signatories
- **Organizations** — companies, trusts, partnerships, nonprofits, government entities
- **Events** — transactions, meetings, filings, registrations, legal proceedings
- **Transactions** — fund transfers, asset purchases, contract awards
- **Addresses** — physical locations, registered addresses, mailing addresses
- **Accounts** — bank accounts, wallet addresses, social media accounts, domain registrations
- **Assets** — properties, vehicles, intellectual property
- **Locations** — jurisdictions, regions, specific sites
- Use `ai_venice_web_search` to find additional entities connected to seed entities

### 3. IDENTIFY ALL RELATIONSHIPS
Classify relationships by type:
- **Financial** — ownership, investment, transaction, debt, loan, payment
- **Social** — family, friendship, professional association, shared history
- **Operational** — supplier, customer, employer, partner, contractor
- **Hierarchical** — parent-subsidiary, boss-subordinate, controller-controlled
- **Temporal** — co-occurrence at events, simultaneous transactions, sequential events
- **Spatial** — shared address, co-location, same jurisdiction
- For each relationship, note: type, direction (if applicable), strength, evidence source, date

### 4. BUILD THE NETWORK MAP
Construct the network as nodes (entities) and edges (relationships):
- Can be done with simple tools (whiteboard, spreadsheet, text diagram) or specialized software
- Each node has attributes (type, name, identifiers, risk flags)
- Each edge has attributes (type, direction, strength, evidence, date)
- Look for:
  - Multiple edges between same pair (multi-layered relationships)
  - Edges that create cycles (A→B→C→A — circular transactions, mutual ownership)
  - Edges with temporal patterns (all relationships established in same timeframe)

### 5. ANALYZE NETWORK STRUCTURE
Examine the topology for significant patterns:

**Central nodes (degree centrality):**
- Entities with the most connections — often key players or hubs
- High degree = influence, control, or bottleneck position
- Question: why is this entity connected to so many others?

**Bridges (betweenness centrality):**
- Entities connecting otherwise separate clusters — they control information/resource flow
- Disproportionate influence despite few total connections
- Removing a bridge fragments the network — indicates critical dependency
- Question: who is the single point of connection between two groups?

**Clusters/communities:**
- Tightly connected subgroups — may indicate coordinated activity, shared interests, or organizational units
- Multiple entities forming a closed loop with limited external connections — may indicate concealment
- Question: why do these entities cluster together? What's the common thread?

**Gaps/missing links:**
- Expected connections that DON'T exist — may indicate concealment, avoidance, or genuine separation
- Two companies at the same address with no shared director — unusual, investigate why
- Question: what relationships SHOULD exist but don't?

**Anomalies:**
- Unusual patterns that stand out from the network's baseline:
  - Shared addresses across seemingly unrelated entities
  - Circular transaction flows (A pays B pays C pays A)
  - Multiple companies with same directors/registered agent
  - Sudden appearance of many new connections in a short timeframe
  - Single entity bridging otherwise unconnected domains (e.g., one person on boards of companies in unrelated industries)
- Question: what doesn't fit the expected pattern?

### 6. DRAW CONCLUSIONS
Based on network structure, answer the original question:
- **Hidden ownership?** — Follow control edges through multiple layers to identify ultimate beneficial owner (UBO). Look for chains of holding companies, nominee directors, shared registered agents.
- **Coordinated activity?** — Look for clusters with internal coordination patterns (synchronized transactions, shared infrastructure, cross-appointments).
- **Conflicts of interest?** — Look for unexpected bridges between entities that should be independent (e.g., auditor's spouse on client's board).
- **Fraud patterns?** — Look for circular flows, shell company clusters, layering patterns, unusual timing.
- **Key influencers?** — Identify central nodes and bridges — these are the entities with disproportionate influence.
- **Supply chain risks?** — Map dependencies, identify single points of failure (bridges), assess cluster concentration.
- Use `ai_venice_web_search` to validate conclusions against known patterns or case studies

**Critical caveat:** Network structure suggests relationships but does NOT prove causation or intent. "Being linked to a suspicious entity does not prove guilt — but it does invite investigation." Conclusions are leads, not verdicts.

## How This Differs From Other Skills

- **vs. systems-thinking:** Systems-thinking maps dynamic feedback loops (reinforcing/balancing) and system archetypes over time. Link analysis maps static entity relationships and network topology. Different questions, different outputs, different analytical approaches.
- **vs. ACH:** ACH evaluates evidence against competing hypotheses using a matrix. Link analysis maps relationships between entities using a graph. Different analytical structure.
- **vs. structured-investigation:** Investigation framework is the process of gathering and verifying information. Link analysis is an analytical technique for making sense of relationship data gathered during investigation. Complementary — use structured-investigation first to gather data, then link-analysis to map relationships.
- **vs. red-team:** Red Team constructs attack paths. Link Analysis maps existing relationships. Different purpose.

## Examples by Domain

**Crypto/web3:**
- Entities: wallet addresses, known exchange wallets, team member wallets, token contracts
- Relationships: transactions, token transfers, staking, delegation
- Analysis: wallet clustering (identify entity controlling multiple addresses), fund flow tracing (exchange → unknown wallet → exchange), token distribution mapping (are team wallets sending to each other before public sale?), coordinated trading detection
- Anomalies: circular flows between wallets (wash trading), sudden concentration of tokens in few wallets

**Due diligence:**
- Entities: target company, subsidiaries, parent companies, directors, shareholders, registered agents
- Relationships: ownership, directorship, shared address, shared agent, transaction
- Analysis: map corporate ownership web across jurisdictions, identify ultimate beneficial owner (UBO), uncover shell company layers, detect related party transactions
- Anomalies: multiple companies at same address with no apparent business reason, same nominee director across many companies

**Fraud/AML:**
- Entities: bank accounts, individuals, businesses, transactions
- Relationships: fund transfers, shared signatories, shared addresses
- Analysis: trace transaction flows, identify layering patterns (funds moved through multiple accounts to obscure origin), detect structuring (many small transactions just below reporting threshold)
- Anomalies: circular flows (A→B→C→A), sudden activity in dormant accounts, transactions inconsistent with stated business purpose

**Supply chain:**
- Entities: suppliers, manufacturers, distributors, logistics providers, raw material sources
- Relationships: supplies, manufactures-for, ships-for, owns, partners-with
- Analysis: map full supply chain, identify single points of failure (bridge entities), assess geographic concentration risk, detect hidden dependencies
- Anomalies: sole-source supplier with no alternatives, supplier and competitor sharing same upstream source

**Journalism (Panama Papers example):**
- Entities: individuals, offshore companies, intermediaries, addresses
- Relationships: directorship, ownership, shared registered agent, shared address
- Analysis: connect people to offshore companies across dozens of jurisdictions, identify patterns of hidden ownership, map intermediary networks
- "Journalists used graph databases and visualization tools to connect people and offshore companies across dozens of jurisdictions" — [Social Links](https://blog.sociallinks.io/link-analysis-lifeblood-of-the-modern-investigation/)

## Scope and Limitations

**Works on:** Due diligence, fraud/AML investigation, crypto wallet analysis, corporate ownership mapping, supply chain analysis, stakeholder mapping, conflict of interest detection, any situation where entity relationships reveal important information.

**Does NOT work on:**
- **Dynamic system behavior** — use systems-thinking (feedback loops, delays, emergence)
- **Hypothesis evaluation** — use ACH (evidence against competing hypotheses)
- **Information gathering** — use structured-investigation (this analyzes data already gathered)
- **Future scenario planning** — use alternative-futures
- **Single-entity analysis** — if there's no network to map, this isn't the right tool

**Limitations:**
- Requires sufficient data to build a meaningful network — sparse data produces uninformative maps
- Network structure suggests relationships but doesn't prove causation or intent
- Can produce false positives — being connected to a suspicious entity invites investigation, not conclusion
- Quality depends entirely on entity identification and relationship extraction quality (garbage in, garbage out)
- Large networks become visually overwhelming without filtering; requires analytical judgment about what to include
- Degrees of separation matter — including too many degrees creates noise; too few misses connections

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through stages sequentially. At DEFINE SCOPE, use `ai_venice_web_search` to research the domain and available data sources. At IDENTIFY ENTITIES, search for additional entities connected to seed entities. The network analysis (Stage 5) is the core — do not skip it. Conclusions are leads, not verdicts. Pair with structured-investigation to gather data first, then use link-analysis to map relationships.
