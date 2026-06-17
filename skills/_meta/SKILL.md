---
name: _meta
description: Cross-cutting rules every skill in this workflow inherits. Not invoked directly; referenced by other skills.
---

# _meta

The contract every skill and agent operates under. If a skill's text contradicts `_meta`, `_meta` wins.

## 1. Always-allowed reads

Every skill and agent may always read, without listing them in its manifest:

- `docs/workflow.md`, `docs/agentic-sdlc-principles.md`, `docs/doc-structure.md`
- `docs/owasp-guidelines.md` (the verbatim OWASP Secure Coding Practices baseline) and `docs/security-guidelines.md` (the project's custom security layer) — the mandatory security baseline; every skill and agent reads and works against both, per §18
- `.claude/skills/_meta/SKILL.md` and the skill's or agent's own definition file
- `docs/permanent/architecture/coding-standards.md`, `testing-standards.md`, `naming-conventions.md`
- `docs/permanent/domain/glossary.md`
- `docs/permanent/domain/domain-model.md` (cross-context invariants — must be readable by any agent that produces or validates spec-bearing artifacts so invariants aren't silently violated)
- `docs/permanent/design/design.md` (the design system — tokens + component inventory; same rationale as `domain-model.md`: any agent that produces or validates a UI-bearing artifact must read it so the design contract isn't silently violated. Human-owned — agents read, never write, per §17)
- `docs/permanent/design/design-deviations.md` (the design-deviation log — readable so review and integrity can confirm any provisional component is logged)

Everything the workflow manages lives under `docs/`. Project code lives elsewhere (e.g., `src/`) and is not workflow scope unless explicitly listed in a manifest. Anything outside the always-allowed set must appear in the agent's manifest or the skill's `Inputs` section; the agent halts and surfaces the gap rather than reading outside scope.

`project-init` is exempt — its job is to create this set.

## 2. No silent substitution

A skill or agent never fills in for a missing or contradictory input. If a required input is absent or two sources disagree, halt with a structured entry naming the missing or conflicting artifact, the upstream that should have produced it, and the proposed route.

Specifically forbidden: writing a glossary entry, capability, feature, decision record, or design spec without a named source; resolving a contradiction by silently picking one.

## 3. Grounded-in declarations

Every spec-bearing artifact (capability, aggregate, feature, design spec, decision record, increment scope, phase plan) declares a `Grounded in:` header listing the documents whose content supports it. `doc-integrity` validates that listed sources exist and are current (accepted, not withdrawn).

Code and test files do not carry per-file `Grounded in:` headers. Their grounding is the increment scope they implement. The reviewer resolves code-to-spec traceability via the increment's manifest, not via per-file headers.

## 4. Subagent manifest and return contracts

Every subagent invocation opens with a fenced manifest block:

```
<<<MANIFEST>>>
agent: <name>
mode: <agent-specific, e.g. phase | increment | stabilization>
scope: <phase-or-increment slug>
inputs:
  - <path>
allowed_writes:
  - <path or directory>
gate_state: <current gate or "in-loop">
parent_commit: <git hash or "n/a">
<<<END>>>
```

The agent's first step reads the block, asserts it matches its declared inputs, and halts if not. Every return is also fenced:

```
<<<RETURN>>>
status: success | halt | scope-expansion | design-gap
files_written: [<paths>]
key_findings: <prose, <=200 words>
grounded_in: [<sources>]
observations: [<entries per §6>]
halt: { at_step: <id>, reason: <one-line>, route_to: <destination> }
design_gap: { kind: component | token, use_case: <one-line>, candidates: [<component names, if any>], recommendation: <option or "no match">, recommended_classification: <A | B-phase | B-accept | accept-gap> }
<<<END>>>
```

Malformed returns halt to the human. A `design-gap` return is the agent surfacing a design-system decision it must not make itself (§17); the orchestrator emits the design-decision prompt and re-invokes with the resolution.

## 5. Subagents do not traverse the filesystem

Subagents read only paths in their manifest plus the always-allowed set. No globbing, no grep across the tree, no directory listing outside manifest scope. The orchestrator traverses; agents don't.

The **discovery scope** exception: agents may read type and interface declarations within the same module tree as listed code paths without halting. "Declaration" means `.d.ts`, type-only sections of `.ts`/`.tsx`, Python `.pyi`, Go interface declarations, equivalents in other languages — per the project's `coding-standards.md`. Behavioral code outside the manifest still requires expansion.

## 6. Observations

Agents and skills surface observations to `docs/transient/phases/<phase-slug>/observations.md`. Each entry:

```
- timestamp: <ISO>
  source: <skill or agent>
  category: workflow-defect | standards-coding | standards-testing | standards-naming | other
  severity: routine | critical
  pattern: <one-line>
  context: <where it occurred>
  proposed_action: <what to do about it>
```

`critical` halts inline for review at the next gate. `routine` accumulates and is synthesized at `phase-close`. The agent picks the best category; the synthesis step at phase-close re-routes if needed.

## 7. Skills don't invoke skills

A skill operates within its declared scope and does not invoke other skills. Handoffs run through the orchestrator. The exceptions are the three declared utilities — `doc-integrity`, `workflow-curator`, `feedback-triage` — which may be invoked by any skill that cites the carve-out in its step.

## 8. Append-only with supersession for accepted artifacts

Once an artifact's `status:` is `accepted`, it changes only by supersession:
- A new entry is created with a successor ID and `supersedes: <original>`.
- The original flips to `superseded_by: <successor>`, or to `deprecated` (with reason), or to `withdrawn` (only valid from `proposed`).

Editorial changes (typos, formatting, link fixes, capitalization, whitespace) happen in place and are logged in a sibling `editorial-log.md`. The boundary: anything touching status, IDs, supersession links, accepted decision values, or AC bodies is supersession. Boundary cases default to supersession; the human may override inline.

Code is exempt from append-only.

## 9. Artifact lifecycle and status

Spec-bearing artifacts are born under `docs/permanent/...` with `status: proposed`. At the gate that approves them, status flips to `accepted` in place — no file move. Subsequent changes follow §8.

Status state machine:

```
proposed -> accepted -> superseded -> (terminal)
                     -> deprecated -> (terminal)
proposed -> withdrawn -> (terminal, may be re-proposed under new ID with prior_withdrawn:)
```

`doc-integrity` validates transitions.

## 10. Decision-record numbering

Two record types: **DR** (domain, capability-scope, feature design) and **ADR** (architecture, technology, system-impact). Each has its own numbering namespace.

Numbers are assigned at gate approval as part of the status flip from `proposed` to `accepted`:
- Phase-level records at Gate 1.
- Increment-level records at Gate 2.

Records sit with `TBD-<slug>` placeholders between authoring and gate approval (minutes, not hours). `doc-integrity` halts if any `TBD-*` ID survives a passed gate.

## 11. Pin validation

`session-resume` validates `skill-versions.lock` against the dotfiles tag at the start of every session. A mismatch halts with two human options:
- **Override** (recorded as a DR): proceed with the available version.
- **Rollback**: restore the pinned version or roll back the project's pin.

Pin failures don't get silently absorbed.

## 12. Expected-duration bands

Each skill declares a typical duration. Exceeding the upper bound is itself a workflow-defect signal — surface as an observation. Bands:

- `session-resume`: 5–60 seconds.
- `project-init`: 1–5 minutes (one-time).
- `phase-design` (includes domain-design + technical-design agents): 5–20 minutes.
- `phase-close` (consolidation + retrospective + skill diffs): 3–15 minutes.
- `increment-design` (includes domain-design + technical-design agents): 4–15 minutes.
- `increment-execute` (one develop + one test + one review pass, plus cycle retries): 10–60 minutes typical, longer on cycle-3 retries.
- `increment-close` (full regression + integrity + PR): 3–25 minutes depending on suite size.
- Post-merge fix cycles (handled inline by the orchestrator while increment status is `awaiting-merge`): per fix, 2–10 minutes plus CI wait and human validation.
- `feedback-triage`: 30 seconds – 2 minutes per entry.
- Utilities (`doc-integrity`, `workflow-curator`): 30 seconds – 5 minutes scoped; up to 10 minutes for full sweep.

## 13. Gate-approval prompt contract

The human never edits INDEX directly to signal a gate decision. At every gate, the orchestrator emits:

```
═══════════════════════════════════════════════
APPROVAL REQUIRED — Gate <N> (<name>)
Active scope: <slug>

Summary: <2–3 sentences>

Files for review:
  - <path> — <one-line>
  ...

To approve: reply "approve" (optionally "approve with modifications: <notes>").
To reject: reply "reject: <reason>".
To request changes: reply "changes: <list>".
═══════════════════════════════════════════════
```

The orchestrator parses the reply, writes the `gate_status:` entry in INDEX, and routes per the response. For "changes", the orchestrator applies targeted edits to proposed artifacts in place and re-emits the gate prompt; substantive changes re-invoke the relevant upstream skill. For "reject", the workflow routes per the gate's defined rejection path.

## 14. Gate-state schema in INDEX

```yaml
gate_status:
  - gate_id: gate-1@<phase-slug>
    decision: approve | reject | changes
    decided_at: <ISO>
    decided_by: <human>
    modifications: <text or "none">
  - gate_id: gate-2@<phase-slug>/<inc-slug>
    decision: approve
    ...
```

`session-resume` reads this for routing.

## 15. Visibility lines

Every skill and agent emits structured status lines so the human can follow progress. Subagents return their lines as part of the fenced return block; the orchestrator surfaces them to chat.

## 16. The principles document is referenced, not duplicated

`agentic-sdlc-principles.md` is the workflow-agnostic statement of why these rules exist. Skills reference principles by section when explaining a behavior; they don't restate them.

## 17. Design-system guardrail

`docs/permanent/design/design.md` is the project's design system — the authoritative inventory of design tokens (`colors`, `typography`, `rounded`, `spacing`, `motion`, `state`) and the `components:` catalog. It is the **source of truth** for UI: it outranks prototypes. It is **human-owned** — agents read it (§1) and never write to it.

Every agent that produces or validates a UI-bearing artifact (design specs, UI implementation, UI tests) resolves the components and tokens it needs against `design.md`:

- **Direct match** — exactly one component (or token) clearly fits → proceed, referencing it by name. No surfacing.
- **Ambiguous / multiple candidates** — one or more components *may* fit, or several fit → do not pick silently (§2). Return `design-gap` with the candidate list and a **recommendation**. The orchestrator surfaces the choice to the human.
- **No match — component** → return `design-gap` (no candidates, `recommended_classification` set). The human chooses: **(A)** supply an updated `design.md` containing the component, or **(B)** instruct the agent to design it from `design.md`'s guidelines — and, if B, set the debt class: **B-phase** (the solidifying increment reconciles it) or **B-accept** (logged as accepted debt, not fixed).
- **No match — foundation token** → return `design-gap`, **human-only**: the agent never improvises a color/type/spacing/motion/state value. The human supplies an updated `design.md` or explicitly accepts the gap as debt (`accept-gap`). This honors the design system's own rule that new use cases add components, not foundations.

**Provisional components.** When the human chooses B, the authoring agent records the improvised component *inside the design-spec* (marked `provisional: true`, with `guidelines_basis:`) and **never** edits `design.md`. Promoting a provisional into `design.md` is a human act, typically at the solidifying-increment drain.

**Deviations are always logged.** Every divergence from `design.md` — a B-path provisional component, an accepted token gap, or a prototype that diverges from the system — is appended to `docs/permanent/design/design-deviations.md`. The fix-vs-accept disposition is carried by an ordinary `phase-debt.md` entry (`category: design-deviation`, drained by the solidifying increment) or `accepted-debt.md` entry. A human-supplied `design.md` update is still logged (`resolution: human-updated-design-md`, `debt_class: none`) for history. `doc-integrity` flags any design-spec reference that resolves to neither `design.md` nor a logged provisional, and any `design-deviation` phase-debt entry left `pending` past the solidifying-increment drain.

**Design-decision prompt (orchestrator → human).** Emitted by `increment-design` (Gate 2) and `increment-execute` (backstop) on a `design-gap` return:

```
═══════════════════════════════════════════════
DESIGN DECISION REQUIRED — <component | foundation token>
Active scope: <phase-slug>/<inc-slug>

Use case: <what UI/design is needed>

[ Ambiguous-match case ]
Candidate(s) in design.md:
  1. <component> — <why it might fit>
  2. <component> — <why it might fit>
Agent recommendation: <option N> — <one-line rationale>
Reply: "use <N>" | "use <component-name>"

[ No-match case ]
No matching <component | token> found in design.md.
Options:
  A.        Provide an updated design.md containing the needed <component | token>.
  B-phase.  (components only) Design it from design.md's guidelines; reconcile in the solidifying increment.
  B-accept. (components only) Design it from guidelines; log as accepted debt (won't be fixed).
  accept-gap. Accept the gap as debt without designing now.
  (tokens: only A or accept-gap — no agent improvisation)
Agent recommendation: <A | B-phase | B-accept | accept-gap> — <rationale>
Reply: "A" (then supply the file) | "B-phase" | "B-accept" | "accept-gap"
═══════════════════════════════════════════════
```

The orchestrator parses the reply, records the deviation (and any debt entry), and re-invokes the agent with the resolution. A B-path resolution that materially changes an accepted spec re-passes the relevant gate, as with any spec change.

## 18. Security baseline (mandatory, every step)

Two documents form the project's **security baseline**:

- `docs/owasp-guidelines.md` — a *verbatim* copy of the OWASP Secure Coding Practices Quick Reference Guide. Treat it as a vendored upstream standard: it is **not edited** in-project. Refreshed only by re-importing a newer OWASP release.
- `docs/security-guidelines.md` — the project's **own** security layer: rules OWASP doesn't cover, project-specific elaborations, and any conscious overrides. Human-owned, exactly like `design.md` (§17): agents read it and work against it, but **never write to it**.

Both are always-allowed reads (§1). They are **not optional**. Every skill and every agent reads both and works against them at every step where it produces, modifies, or validates an artifact — analysis, design specs, code, tests, and reviews alike. This mirrors the design-system guardrail (§17): the design system is the source of truth for UI; the security baseline is the source of truth for security.

**Precedence.** Where `security-guidelines.md` is silent, the OWASP baseline governs. Where it states a stricter rule, the stricter rule governs. A baseline item may be relaxed or replaced **only** by an explicit entry in the "Overrides" section of `security-guidelines.md` that names the overridden item, gives a rationale, and references an approving ADR. An agent never infers an override and never silently relaxes a baseline item (§2) — absent a recorded override, the baseline stands.

**What "work against" means by role.**

- **Design agents** (`domain-design`, `technical-design`): treat the baseline as a source of security requirements and abuse cases. Design specs and ADRs that touch authentication, authorization, sessions, data protection, cryptography, input handling, file handling, or external communication must reflect the applicable baseline items, and must declare them in `Grounded in:` where the item shaped the design. A new external dependency's ADR "Supply chain notes" reflects the dependency/supply-chain rules.
- **`increment-develop`**: implement against the baseline (it subsumes the inline security rules already in the agent — secrets, input validation at trust boundaries, no sensitive data in logs, fail-secure error handling, parameterized queries, etc.). A required pattern absent from `coding-standards.md` but mandated by the baseline is followed from the baseline, with a routine observation that `coding-standards.md` should absorb it.
- **`increment-test`**: derive security test cases from the baseline and from `security-guidelines.md` for the scenarios in scope (negative/abuse cases for validation, authz, session, error-leakage), consistent with manifest isolation.
- **`increment-review`**: run an explicit, mandatory security pass against the baseline (see the review agent's Security check). A baseline violation with no recorded override **blocks the increment**, regardless of other passes.

**Surfacing gaps.** An agent never edits either baseline file. When work reveals a needed project rule, a baseline item that doesn't fit the project, or a candidate override, the agent surfaces a `category: other` (or `standards-coding`) observation (§6) proposing the addition to `security-guidelines.md`; the human dispositions it. A genuine conflict between an instruction and the baseline is a halt (§2), not a silent resolution.

Both files are part of the always-allowed-read set (§1), so if either is missing the read fails to resolve and the agent halts and surfaces the gap, exactly as for any other always-allowed doc. `project-init` scaffolds both on day one so this resolves from the start.
