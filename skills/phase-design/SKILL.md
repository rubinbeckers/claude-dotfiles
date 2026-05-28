---
name: phase-design
description: Initiates a new phase. Handles raw input and prototype classification, delegates to domain-design and technical-design agents in sequence, decomposes the result into sequential value-adding increments, triggers Gate 1, and on approval advances to the first increment's design. Invoked by session-resume at the start of a phase.
---

# phase-design

The phase-level analytical and planning pass, in one skill. Consolidates what v1.0 split between `phase-start` and `phase-planning`.

## Inputs

- Raw input files at `docs/transient/phases/<NN>-<slug>/raw-input/`
- Any prototype files at `docs/transient/phases/<NN>-<slug>/prototype-candidate/`
- Carry-forward content from the prior phase (relocated automatically)
- INDEX
- Accepted permanent docs (referenced by the subagents)

## Outputs

- The new phase's transient workspace under `docs/transient/phases/<NN>-<slug>/`
- Domain-design outputs as proposed artifacts under `docs/permanent/...` (capabilities, aggregates, glossary additions, DRs)
- Technical-design outputs as proposed artifacts under `docs/permanent/...` (ADRs, architecture-doc proposals)
- `docs/transient/phases/<NN>-<slug>/phase-plan.md` with the sequential-increments decomposition
- Gate 1 prompt, then on approval: status flips to `accepted` on all proposed artifacts, IDs assigned, INDEX updated

## Steps

### 1. Create the phase workspace

**Defensive staged-diff apply.** Before any other work, check `docs/transient/pending-skill-diffs/` for any staged skill or agent diffs that haven't been applied (they would normally be applied by `session-resume` §2 at session start). If present, invoke `workflow-curator` in `mode: apply` with the staged proposal IDs now — this guards against the case where `phase-close` finished and the human supplied phase raw input within the same session, bypassing `session-resume`. After application, clear `pending_skill_diffs:` from INDEX.

Determine the phase slug (next number + human-supplied descriptor). Create:

```
docs/transient/phases/<NN>-<slug>/
  raw-input/                          (move human's input here)
  prototype-candidate/                (if any)
  observations.md                     (empty stub)
  feedback-inbox.md                   (empty stub)
  phase-debt.md                       (empty stub)
  carry-forward-from-<prior>/         (relocated from prior phase, if any)
```

Update INDEX: `active_phase: <slug>`, `status: design`.

### 2. Prototype classification

Per `workflow.md` §6.1, classify:
- **A — Overwrite**: prototype-candidate has files colliding with existing `docs/permanent/design/prototype/`. Archive the existing prototype to `docs/permanent/design/archive/<ISO>/`, move the candidate into place, record a DR documenting the replacement.
- **B — Additive**: no collisions. Merge into the prototype directory, record a DR documenting the additions.
- **C — None**: prototype-candidate empty or absent. Run capability-coverage analysis: for each planned capability from raw input, check whether existing prototype covers it. Surface gaps; the human chooses to accept the risk (record a DR per uncovered capability) or halts and provides a prototype.

### 3. Draft phase-scope

Read raw input. Produce `docs/transient/phases/<NN>-<slug>/phase-scope.md`:

```
# Phase scope: <slug>

Grounded in:
  - raw input
  - carry-forward content (if any)
  - prior phase's accepted artifacts (referenced where relevant)

## Objective
<high-level statement>

## Capabilities expected
<names from raw input>

## Out of scope
<human's exclusions>

## Prototype handling outcome
<from step 2>
```

Surface to human for confirmation. On modifications, apply and re-surface. Once confirmed, proceed.

### 4. Delegate to domain-design

Construct the manifest per `_meta` §4 with `mode: phase`. Invoke via Task tool with the standard prompt format.

Parse the return. On success: domain-design wrote proposed capabilities, aggregates, glossary entries, and DRs under `docs/permanent/...` with `status: proposed`. On halt: route per the halt entry (typically raw-input ambiguity escalates to the human).

### 5. Delegate to technical-design

Construct the manifest with `mode: phase` and the domain-design outputs from step 4. Invoke.

Parse the return. On success: technical-design wrote proposed ADRs and standards-doc proposals. On halt where domain output surfaces an architecture-incompatible need: loop back to domain-design with the surfaced gap as input.

### 6. Decompose into increments

For each capability in scope, evaluate against the atomic-but-meaningful principle:
- Can it deliver value as a single increment? (Usually yes.)
- Does it depend on other capabilities or architecture work that must land first?
- Is it large enough that splitting would each deliver demonstrable value?

Produce a draft increment list. Each entry: slug, one-line objective, capabilities delivered, capabilities partially exercised, ADRs exercised, prototype coverage, dependencies on prior increments, estimated size (S/M/L).

### 7. Plan integrity

Verify:
- Every capability referenced exists in domain-design outputs (proposed or accepted).
- Every ADR referenced exists in technical-design outputs or prior accepted ADRs.
- Every prototype path referenced exists.
- Every `depends:` is to an earlier increment in this plan or a closed prior increment.
- No capability is "delivered" by more than one increment (multiple may *exercise* it; only one is primary).

Halt on any failure (`cross-reference`); re-run the relevant subagent with the gap as input.

### 8. Surface oversized increments

Any increment with size L, or with capability count >3, or with ADR count >3: surface for split proposal. The human accepts the split, overrides (logged in the plan), or rejects.

### 9. Schedule solidifying increment

Append a final solidifying increment to the plan per `workflow.md` §9:

```
### inc-<NNN>-<descriptor>
Objective: absorb accumulated tech debt from this phase. Concrete scope determined at increment-design time from phase-debt.md. May be skipped if phase-debt.md is empty at start.
type: solidifying
Capabilities delivered: none
Architecture decisions: none
Depends on: all prior increments in this phase
Estimated size: variable (TBD at increment-design)
```

Initialise `phase-debt.md` as an empty stub.

### 10. Write phase-plan.md

Per the `phase-plan.md` template. Include all increments with their sequencing rationale.

### 11. Gate 1

Emit the gate-1 approval prompt per `_meta` §13. List the proposed artifacts (capabilities, aggregates, DRs, ADRs, phase-plan) with one-line summaries.

Parse the human's reply:
- **approve** → step 12.
- **approve with modifications: <notes>** → apply modifications to proposed artifacts, then step 12.
- **changes: <list>** → targeted changes applied to proposed artifacts; re-emit the prompt.
- **reject: <reason>** → re-invoke the relevant subagent (domain or technical) with the rejection notes; updated proposals re-emit the prompt.

### 12. Promote and number

For each artifact under `docs/permanent/...` with `status: proposed`:
- Flip `status:` to `accepted`.
- Assign final IDs to any `TBD-<slug>` placeholders (DRs and ADRs use their respective numbering namespaces; numbering reflects phase-level acceptance order).
- Update all internal references to the new IDs.

Update INDEX: phase `status: in-progress`, `gate_status:` entry recorded, `increments:` populated from phase-plan.

### 13. Advance

Invoke `increment-design` for the first non-solidifying increment in the plan.

## Edges

Halt routes for the orchestrator:
- Raw input absent → wait for human input.
- Raw input contradicts existing permanent docs non-trivially → human clarification before delegation.
- Subagent halt above phase level → human.
- Plan integrity failure that can't be auto-resolved → human (manual restructure).
- Circular dependencies in the plan → re-decompose or human.

## Observations to surface

Raw input that lacks structure helpful for grounding (signal: a raw-input template might reduce friction); recurring prototype coverage gaps (signal: design pipeline could integrate earlier); domain halts surfacing glossary terms not present (signal: glossary-authoring expectations may need adjustment); plans consistently producing >7 increments (signal: phase sizing convention should be revisited).
