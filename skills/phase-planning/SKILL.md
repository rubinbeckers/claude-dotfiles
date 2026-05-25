---
name: phase-planning
description: Decompose the phase scope into value-adding sequential increments. Each increment links back to specific capabilities, aggregates, and ADRs. Produces phase-plan.md and triggers Gate 1.
---

# phase-planning

Decomposes the phase into sequential, value-adding increments. Produces `phase-plan.md`. Triggers Gate 1 for human approval. Invoked by `phase-start` after BA and TA subagents return.

Runs as an orchestration skill in the main chat. Does not delegate (the analytical work is already done; this is decomposition).

## Inputs

- `phase-scope.md` (transient, from phase-start)
- BA outputs from phase-start: proposed capabilities, aggregates, glossary additions, CDRs/DDRs
- TA outputs from phase-start: proposed architecture entries, ADRs
- Prototype paths (relevant to increment scoping)
- Existing INDEX
- Always-allowed set (`_meta` §1)

## Outputs

- `docs/transient/phases/<phase-slug>/phase-plan.md`
- Updated INDEX: phase status remains `planning` until gate approval, then flips to `in-progress` with `increments` array populated

## Steps

### Step 1 — Read all inputs

Read `phase-scope.md` and the BA / TA outputs. Internalize the full set of proposed capabilities and architecture decisions.

### Step 2 — Decompose into increments

For each capability in scope, evaluate:

- Can it deliver value as a single increment? (Most capabilities can.)
- Does it depend on other capabilities or architecture work that must land first? (If yes, those go in earlier increments.)
- Is it large enough that splitting into multiple increments would each deliver demonstrable value? (Rare but possible — e.g., "user management" might split into "user CRUD" and "user roles".)

Apply the principle: an increment must deliver something the stakeholder would describe as shippable or demonstrable in isolation. Increments are sequential.

Produce a draft increment list, each with:
- A slug (`inc-NNN-<short-slug>`)
- One-line objective
- Capabilities delivered (reference by name to BA outputs)
- Capabilities partially exercised (with notes on what's deferred)
- Architecture decisions exercised (reference to ADRs)
- Design coverage (prototype files relevant to this increment)
- Dependencies on prior increments (`depends: inc-NNN`)
- Estimated relative size (S/M/L — used to flag over-sized increments for splitting)

### Step 3 — Cross-reference integrity

For each increment in the draft, verify:
- Every capability referenced exists in BA outputs.
- Every ADR referenced exists in TA outputs (or in prior accepted ADRs).
- Every prototype path referenced exists in `docs/permanent/design/prototype/`.
- Every `depends:` reference is to an earlier increment in this plan or to a closed increment from a prior phase.
- No capability is referenced by more than one increment (multiple increments may *exercise* a capability, but only one increment *delivers* it as primary).

Halt with `T-PP-1` on any integrity failure (this is exactly the kind of silent drift the workflow exists to prevent).

### Step 4 — Surface oversized increments

Any increment with size `L` or with capability count > 3 is flagged: propose a split. The human can accept the split, override, or reject. Document the override (if any) with a one-line rationale in `phase-plan.md`.

### Step 4.5 — Schedule solidifying increment

Per `workflow.md` §7.3, every phase plans a final solidifying increment as the last entry. At planning time, the solidifying increment is included in the phase plan as a placeholder — its concrete scope is determined later (at its own `increment-start`, reading from `phase-debt.md`).

Add to the phase plan. The solidifying increment uses the project's sequential numbering convention (i.e., the next number in sequence after the last value-adding increment) with a descriptive suffix. The semantic claim is the `type:` field; the slug name is project-convention. Examples: `inc-030-solidify-final`, `inc-015-stabilization`, `inc-008-cleanup`.

```
### inc-<NNN>-<solidifying-descriptor>
Objective: absorb accumulated tech debt from this phase (flaky tests, dead code,
deferred discovered defects, refactoring opportunities, code-level standards
observations). Concrete scope determined at increment-start time from phase-debt.md.
May be marked skipped at increment-start only if phase-debt.md is completely empty.

Capabilities delivered: (none — solidifying increments do not deliver new capabilities)
Architecture decisions: (none — solidifying increments do not introduce new ADRs)
Depends on: all prior increments in this phase
Estimated size: variable (TBD at increment-start)
type: solidifying
```

Important: the `type: solidifying` field is what makes this increment a solidifying one (consumed by `increment-start` to determine handling per `workflow.md` §7.3). The slug is project-convention and does NOT need to match a template literal — `inc-solidifying` as a slug is fine but not required.

Initialize `docs/transient/phases/<phase-slug>/phase-debt.md` as an empty stub. The workflow's other skills (`backlog-review`, `backlog-test`, `feedback-triage`, `increment-close`) will append entries throughout the phase.

### Step 5 — Write phase-plan.md

```
# Phase plan: <phase-slug>

Grounded in:
  - docs/transient/phases/<phase-slug>/phase-scope.md
  - <list of BA outputs>
  - <list of TA outputs>

## Objective
<from phase-scope.md>

## Increments

### inc-001-<slug>
Objective: <one-line>
Capabilities delivered: <list with links>
Architecture decisions: <list of ADRs with links>
Prototype coverage: <list of paths>
Depends on: <list or "none">
Estimated size: S | M | L
Notes: <free text, optional>

### inc-002-<slug>
...
```

### Step 6 — Gate 1 (structured approval prompt)

Emit the gate-1 approval prompt per `_meta` §13.3:

```
═══════════════════════════════════════════════
APPROVAL REQUIRED — Gate 1 (Phase plan)
Active scope: <phase-slug>

Summary of artifacts produced:
  <2–3 sentence summary: capabilities added/modified, aggregates touched, key
   architectural decisions, increment count and theme>

Files for review (read at your discretion):
  - docs/transient/phases/<phase-slug>/phase-scope.md — phase intent
  - docs/transient/phases/<phase-slug>/phase-plan.md — increment decomposition
  - docs/transient/phases/<phase-slug>/proposed/capabilities/* — <N> proposed capabilities (<one-line each>)
  - docs/transient/phases/<phase-slug>/proposed/aggregates/* — <N> proposed aggregates (<one-line each>)
  - docs/transient/phases/<phase-slug>/proposed/decision-records/CDR/* — <N> proposed CDRs
  - docs/transient/phases/<phase-slug>/proposed/decision-records/DDR/* — <N> proposed DDRs
  - docs/transient/phases/<phase-slug>/proposed/decision-records/ADR/* — <N> proposed ADRs
  - <other proposed artifacts>

To approve: reply "approve" (or "approve with modifications: <notes>").
To reject: reply "reject: <reason>".
To request changes: reply "changes: <list>".
═══════════════════════════════════════════════
```

The orchestrator parses the human's reply and writes the corresponding `gate_status:` entry per `_meta` §16. The human never edits INDEX directly.

If approved in the same chat, continue inline (no session-resume needed, per `workflow.md` §5.3).

### Step 7 — On approval — promote and number (C3 + M14)

When `gate_status:` records approval, the orchestrator performs the promotion + numbering atomically:

- For each artifact under `docs/transient/<phase-slug>/proposed/`, **move** the file to its canonical location under `docs/permanent/...`. The `status:` field in each promoted file flips to `accepted`.
- During the move, assign final numbers per `_meta` §8 to any TBD-* IDs in phase-level records (CDRs, DDRs, phase-scope ADRs). Update all references to the TBD IDs in the moved content.
- Update INDEX: phase `status: in-progress`, `gate_status:` entry recorded, `increments:` populated from phase-plan.
- Invoke `increment-start` for the first increment.

If human approved with modifications, apply the modifications first (typically text edits the human provided), then promote.

### Step 8 — On rejection or changes

If `gate_status:` records reject or changes:
- **Targeted changes** (reorder increments, split one, etc.): the orchestrator applies the changes to the proposed artifacts in transient and re-emits the gate-1 prompt.
- **Substantive changes** (scope rejected, capabilities missing, architectural concern): the orchestrator re-invokes the relevant phase-* skill (BA for capability/domain, TA for architecture) with the human's notes as input. The re-passing skill produces updated proposed artifacts; gate-1 re-emits.

No in-place edits of accepted artifacts are needed at this stage — everything proposed is still transient.

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-PP-1 | Cross-reference integrity failure in step 3 | re-run dependent BA/TA work or human |
| T-PP-2 | Phase plan empty (no increments) — scope had no decomposable work | human |
| T-PP-3 | Gate 1 rejected at step 6 with substantive change request | route-to step indicated by human |
| T-PP-4 | Circular dependencies in proposed increments | re-decompose or human |

## Observations

Surface as `routine`:
- Recurring oversized-increment flags at step 4 (signal: increment-sizing rule may need tightening or BA capability granularity is too coarse).
- Frequent cross-reference failures at step 3 (signal: BA/TA outputs lack discoverable identifiers).
- Phases consistently producing >7 increments (signal: phase-sizing convention should be revisited).
