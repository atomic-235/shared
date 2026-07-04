---
name: microservices
description: Use when designing, evaluating, or migrating to a microservices architecture. Covers service decomposition, inter-service communication, data consistency, event-driven architecture, API gateway patterns, service mesh, observability, and the critical monolith-vs-microservices-vs-modular-monolith decision. Applies at the distributed-system level — not individual service internals.
---

# Microservices Architecture Framework

Use this framework when designing, evaluating, or migrating to a microservices architecture at the distributed-system level. For individual service internals (SOLID, patterns, module design), use the software-design skill instead.

## Stages

### 1. DECIDE: DO YOU NEED MICROSERVICES?
**IMPORTANT: You MUST use the `ai_venice_web_search` tool to research the current state of microservices vs monolith vs modular monolith trade-offs. Do NOT rely on training data or fabricate sources. The landscape is rapidly evolving.**

Fowler's framing: "Many, indeed most, situations would do better with a monolith." Do not default to microservices — justify the overhead.

**Microservice Prerequisites** (Fowler) — if you lack these, do NOT adopt microservices:
- Rapid provisioning: can you spin up a new server in hours, not weeks?
- Rapid deployment: mature CI/CD with automated pipelines per service
- DevOps culture: teams own deployment and operations, no handoff to a separate ops team
- Monitoring: distributed tracing, centralized logging, alerting across services
- Design for failure: services must degrade gracefully when dependencies fail

**Context factors to evaluate:**
- Team size: <20 engineers → monolith is likely correct. >50 → microservices may justify overhead. 20-50 → modular monolith is the sweet spot.
- Product maturity: early-stage with evolving domain → start monolith. Premature decomposition locks in boundaries that are hard to change. "If you can't build a well-structured monolith, what makes you think you can build a well-structured set of microservices?" (Simon Brown via Fowler)
- Scaling: do different parts have dramatically different scaling needs?
- Cost: microservices infrastructure costs 3.75x-6x monoliths (2025 CNCF data). 42% of orgs that adopted microservices have consolidated services back.
- Consider the modular monolith: firm module boundaries within a single deployable. You get most benefits without distributed-system costs.
- "Beware of architectural recipes that are too simple and too obvious" (Fowler). Sometimes a monolith is preferable, sometimes it's not.

### 2. DECOMPOSE SERVICES
Use Domain-Driven Design to find service boundaries:
- Identify bounded contexts — each maps to a business capability
- Each service: single responsibility, independent deployability, owns its data
- "Keep things that change at the same time in the same module. Parts that change rarely should be in different services to those undergoing lots of churn." (Kent Beck via Fowler)
- Avoid nano-services: "far too often I see an overcorrection from large monolith to really small services whose design is driven by the existing normalized view of the data" (Fowler)
- If a service can't survive independently, merge it with its closest collaborator
- Use the Strangler Fig pattern for incremental migration from monolith
- "Deciding what capability to decouple when and how to migrate incrementally are the core architectural challenges." Evaluate each decomposition step as an atomic improvement.

### 3. DESIGN INTER-SERVICE COMMUNICATION
**IMPORTANT: Use `ai_venice_web_search` to research current best practices for service communication patterns and tools.**

- Synchronous (HTTP/gRPC) vs asynchronous (message brokers: Kafka, RabbitMQ, NATS)
- Prefer async for decoupling; use sync only when the caller needs the response immediately
- Choreography (event-driven, no central controller) vs Orchestration (central coordinator) — each has trade-offs in coupling, visibility, debugging complexity
- API Gateway pattern for external-facing entry points (routing, auth, rate limiting)
- Service mesh (Istio, Linkerd) for cross-cutting concerns — but evaluate whether the operational overhead is justified. Service mesh adoption dropped from 18% to 8% (2025 data).
- Fowler's "First Law of Distributed Object Design": "don't distribute your objects" — microservices distribute at service boundaries, not object boundaries. Keep inter-service calls coarse-grained.

### 4. MANAGE DATA CONSISTENCY
Decentralized data management is a defining characteristic of microservices:
- Database per service: each service owns its data. No shared databases — they create "cancerous coupling" (Fowler)
- Saga pattern for transactions spanning multiple services
- CQRS for separating read/write models when patterns diverge
- Event sourcing for auditability and temporal queries
- Outbox pattern for reliable event publishing alongside state changes
- Accept eventual consistency where strong consistency isn't required
- "It's perfectly possible to have firm module boundaries with a monolith, but it requires discipline." (Fowler) — in microservices, the boundaries are enforced physically.

### 5. BUILD RESILIENCE & OBSERVABILITY
Distributed systems fail in more ways than monoliths. Design for failure:
- Circuit Breaker, Bulkhead, Timeout patterns for fault tolerance
- Distributed tracing (OpenTelemetry) — non-negotiable for microservices
- Centralized logging and metrics aggregation
- Health checks and graceful degradation: "a complete failure of your component shouldn't stop other parts of the system from working" (Fowler)
- Chaos engineering for validating resilience assumptions
- Contract testing between services to catch integration breaks early

### 6. EVALUATE TRADE-OFFS & DOCUMENT
Every decomposition decision has costs. Make them explicit:
- Network latency replaces in-process calls
- Debugging requires distributed tracing, not a stack trace
- Operational complexity: more repos, pipelines, servers, domains to manage
- Eventual consistency replaces ACID transactions
- Use ADRs (Architecture Decision Records) for significant decisions
- "Each cost and benefit will have a different weight for different systems, even swapping between cost and benefit." (Fowler) — strong module boundaries are good in complex systems, a handicap in simple ones.
- Plan the evolutionary path: services may merge or split as the domain evolves
- Revisit decomposition periodically — boundaries that made sense at creation may not make sense after organizational or domain changes

## Source Integrity Rules
- You MUST use `ai_venice_web_search` whenever research or external information is needed.
- NEVER fabricate, invent, or hallucinate URLs, citations, or sources.
- NEVER cite sources from training data — only cite sources returned by `ai_venice_web_search` results.
- If a search returns no results, say so explicitly rather than making up sources.
- All claims about external facts, studies, or data must be traceable to a search result.

## Usage
Work through each stage sequentially. At DECIDE (Stage 1) and DESIGN INTER-SERVICE COMMUNICATION (Stage 3), use `ai_venice_web_search` to research current industry data and trade-offs. Never recommend microservices without first verifying the prerequisites are met.
