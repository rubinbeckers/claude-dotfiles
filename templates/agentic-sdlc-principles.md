# Agentic SDLC principles (v1.3)

The why behind the workflow. These are workflow-agnostic; if the workflow's rules ever seem arbitrary, this document is the appeal court.

## 1. The harness exists to leverage the LLM's strengths and constrain its failure modes

LLMs are strong at producing coherent multi-file implementations from clear specs, at writing tests against a spec they haven't seen the implementation for, at synthesizing observations into proposed improvements, and at handling structured workflows with explicit handoffs. They are weak at remembering details across long context windows, at noticing implicit assumptions, at distinguishing what they were told from what they inferred, and at admitting they don't know something.

The workflow is structured to play to the strengths (give each agent a focused scope, a tight manifest, a clear deliverable) and constrain the weaknesses (require grounding declarations, enforce manifest isolation, halt on ambiguity rather than guessing).

## 2. Manifest isolation is the test-quality lever

The test agent does not see the implementation, the unit tests, or the implementation plan. Its job is to write tests from the spec. If it had access to the implementation, it would write tests that confirm what the code does — even where the code is wrong. By writing from the spec only, it produces tests that *catch* a wrong implementation.

This is the single most important architectural decision in the workflow. Everything else about the develop/test/review separation flows from it.

## 3. Grounding before authoring

Every spec-bearing artifact declares its `Grounded in:` sources. Agents don't invent: if a glossary term isn't in the glossary, the agent halts and routes to the domain-design agent, which authors the term with grounding to the source that introduced it. This prevents the LLM's silent-substitution failure mode — confidently producing content that wasn't asked for.

## 4. Append-only history

Accepted artifacts never disappear. They change only by supersession: a new entry, a forward link from the old, a backward link from the new. The cost is a little volume; the benefit is that the project's documentation is reconstructable at every point in its history. A reader twelve phases later can answer "why did we decide X back then?" by reading the relevant records, not by interrogating someone's memory.

## 5. Gates are where humans decide and agents commit

The agent surfaces structured proposals. The human approves, modifies, defers, or rejects. The agent applies the decision. The human doesn't edit INDEX, doesn't move files, doesn't run git operations to record approval. This keeps the human in the role of decision-maker and the agent in the role of bookkeeper — which is the role each is best at.

## 6. The orchestrator owns side effects

Subagents don't traverse the filesystem, don't run git operations outside their declared scope, don't read paths outside their manifest. They produce structured output; the orchestrator applies it. Side effects in the orchestrator are auditable; side effects scattered across agents aren't.

## 7. Observations compound into improvement

Every skill and agent surfaces observations during work — patterns that suggest a standards gap, a recurring friction, a skill that's misshapen. These accumulate during a phase and are synthesized at `phase-close` into proposed diffs to the skills repo and standards docs. The workflow learns from itself.

This is the mechanism by which the workflow stays current with how the project actually works, rather than drifting from how it was specified to work.

## 8. Stability over completeness at every step

A small accepted artifact beats a large proposed one. A 2-scenario feature that ships beats a 6-scenario feature stuck in review. The workflow's bias is to ship a coherent slice and iterate rather than to defer until the picture is complete. Phases capture the picture; increments capture coherent slices.

## 9. Quality assurance is layered

- The develop agent writes unit tests as it implements.
- The test agent writes integration/UI tests from spec.
- The review agent checks both against the spec, standards, and security.
- `increment-close` runs full regression.
- CI runs after merge.
- The human validates on staging during stabilization.

Each layer catches a different failure class. The layered structure is the redundancy that lets us run with confidence at the speed we want.

## 10. The workflow is not the work

The workflow exists to make the work happen well. If the workflow gets in the way of the work, the workflow is wrong. Surface that as a workflow-defect observation; phase-close synthesizes them into proposals; improvement is real.

## 11. Security is a baseline, not a feature

Security flaws can enter at any stage — missing requirements, a logic error in design, a poor coding choice, a careless deployment. So security isn't a checkbox at the end; it is a baseline that every step works against. The workflow carries that baseline as two always-allowed documents: a verbatim OWASP Secure Coding Practices copy (the technology-agnostic industry standard) and a project-owned custom layer for what OWASP doesn't cover. They are mandatory reading for every agent, the same way the design system is mandatory for UI work — and for the same reason: a single, human-owned source of truth that agents read and conform to, never silently reinterpret.

This mirrors the design-system guardrail. The design system is the source of truth for *how the product looks and behaves*; the security baseline is the source of truth for *how the product stays safe*. Both outrank an agent's own judgment, both surface gaps to the human rather than improvising, and both make conformance checkable at the gates rather than hoped-for. A baseline item is relaxed only by a recorded, ADR-backed override — never by an agent deciding a rule doesn't apply. The attacker operates on "any action not specifically denied is allowed"; the workflow answers by making the denials explicit, shared, and enforced.
