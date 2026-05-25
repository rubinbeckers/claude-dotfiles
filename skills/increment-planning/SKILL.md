---
name: increment-planning
description: Decompose increment into atomic-but-meaningful backlog items with per-item implementation plans. Triggers Gate 2 for human approval. Invoked by increment-start after FA and TL subagents return.
---

# increment-planning

Decomposes the increment into atomic-but-meaningful backlog items. Each item has a spec (sourced from FA), an implementation plan (sourced from TL), and a context manifest for the developer subagent. Triggers Gate 2. Invoked by `increment-start`.

Runs as an orchestration skill in the main chat. Does not delegate (this is decomposition, not analysis).

## Inputs

- `increment-scope.md`
- FA outputs from increment-start (features, BDD scenarios, design specs, FDRs)
- TL outputs from increment-start (technical-analysis.md)
- Prototype paths in scope
- Always-allowed set (`_meta` §1)

## Outputs

- `docs/transient/phases/<phase-slug>/increments/<inc-slug>/increment-plan.md`
- `docs/transient/phases/<phase-slug>/increments/<inc-slug>/backlog/<NNN>-<slug>.md` per backlog item

## Steps

### Step 1 — Read all inputs

Read increment-scope.md, FA outputs, TL outputs. Internalize the full set of features, scenarios, and technical considerations.

### Step 2 — Decompose into backlog items

For each feature in scope, identify the implementable units:

- A backlog item delivers ≥1 independently testable behavior (typically one BDD scenario or one design-spec component).
- A backlog item is ≥≈30 minutes of development work (anything smaller merges into a sibling).
- A backlog item is small enough that the develop → test → review cycle returns value (typically ≤4 hours of work; anything larger splits).
- A backlog item references concrete artifacts: one or more BDD scenarios, design-spec components, prototype paths, ADRs.

Per `workflow.md` §1 — apply the atomic-but-meaningful rule:

```
Candidate too small? (single label, single rename, single property) → merge into a sibling
Candidate too big?   (multi-feature, multi-screen, mixed concerns) → split

Otherwise: it's a backlog item.
```

### Step 3 — Order backlog items

Sequence them by:
1. Technical dependencies (item B references state established by item A → A first).
2. Risk: complex/architecturally risky items earlier (so problems surface while there's budget to address them).
3. Then by feature grouping (related items adjacent).

Each item declares `depends:` for explicit dependencies on prior items in this increment.

### Step 4 — Per-item spec construction

For each backlog item, write `backlog/<NNN>-<slug>.md`:

```
# Backlog item: <NNN>-<slug>

Grounded in:
  - docs/transient/.../increment-scope.md
  - <feature file(s)>
  - <design-spec file(s)>
  - <prototype path(s)>
  - <ADR(s) if applicable>

## Objective
<one-line>

## Scope
What this item delivers, in concrete terms:
  - <user-visible behavior 1>
  - <user-visible behavior 2>

## BDD scenarios covered
- <feature-slug>: scenario "<name>"
- ...

## Design-spec requirements
- DS-<feature-slug>-<id>: <one-line>
- ...

## Implementation plan
(from TL's technical-analysis.md, per-item section)
  - Files to modify or create: <list>
  - Approach: <prose, ≤200 words>
  - Cross-references to ADRs: <list>

## Context manifest (for backlog-develop subagent)
This is the manifest the orchestrator will pass to backlog-develop:
  - This backlog-item spec
  - <feature file(s)>
  - <design-spec file(s)>
  - <relevant prior-increment code paths, listed explicitly>
  - <coding-standards.md, testing-standards.md, naming-conventions.md (always-allowed)>

## Context manifest (for backlog-test subagent)
This is the manifest the orchestrator will pass to backlog-test (no implementation files):
  - This backlog-item spec
  - <feature file(s)>
  - <design-spec file(s)>
  - <prototype paths>
  - <testing-standards.md (always-allowed)>

## Context manifest (for backlog-review subagent)
  - This backlog-item spec
  - <feature file(s)>
  - <implementation diff for this item only>
  - <unit tests for this item>
  - <integration/UI tests for this item>
  - <coding-standards.md, testing-standards.md (always-allowed)>

## Depends on
<inc-NNN-<slug> items in this increment, or "none">

## Estimated size
S | M | L

## Notes
<free text, optional>
```

### Step 5 — Cross-reference integrity

For each backlog item:
- Every referenced scenario exists in the feature file.
- Every referenced design-spec ID exists in the design-spec file.
- Every referenced prototype path exists.
- Every `depends:` is to an earlier item in this plan.

Halt with `T-IP-1` on any failure.

### Step 6 — Sizing check

Any item flagged size `L`, or with >3 scenarios covered, or with >2 design-spec requirements: surface for split-proposal. Human reviews at Gate 2.

### Step 7 — Write increment-plan.md

```
# Increment plan: <inc-slug>

Grounded in:
  - increment-scope.md
  - <FA outputs>
  - <TL outputs>

## Summary
<one paragraph: what the increment delivers>

## Backlog (sequential)
1. <NNN>-<slug> — <one-line objective> (size: S/M/L)
2. ...

## Plan integrity
- All items reference concrete spec/design artifacts: ✓
- All dependencies resolved within this increment: ✓
- All items pass atomic-but-meaningful check: ✓ (or: see flagged items)
```

### Step 8 — Gate 2 (structured approval prompt)

Emit the gate-2 approval prompt per `_meta` §13.3:

```
═══════════════════════════════════════════════
APPROVAL REQUIRED — Gate 2 (Increment scope)
Active scope: <phase-slug>/<inc-slug>

Summary of artifacts produced:
  <2–3 sentence summary: features introduced/updated, BDD scenario count,
   design coverage, backlog item count and theme, depends-chain notes>

Files for review (read at your discretion):
  - docs/transient/.../increment-scope.md — increment intent
  - docs/transient/.../increment-plan.md — backlog decomposition
  - docs/transient/.../proposed/features/* — <N> proposed features (<one-line each>)
  - docs/transient/.../proposed/design-specs/* — <N> proposed design specs
  - docs/transient/.../proposed/decision-records/FDR/* — <N> proposed FDRs
  - docs/transient/.../technical-analysis.md — TL implementation analysis
  - docs/transient/.../backlog/* — <N> backlog items

To approve: reply "approve" (or "approve with modifications: <notes>").
To reject: reply "reject: <reason>".
To request changes: reply "changes: <list>".
═══════════════════════════════════════════════
```

Orchestrator parses reply, writes `gate_status:` entry per `_meta` §16.

If approved in the same chat, continue inline (no session-resume needed, per `workflow.md` §5.3).

### Step 9 — On approval — promote and number (C3 + M14)

When `gate_status:` records approval:

- **Move** each artifact under `docs/transient/.../proposed/` to its canonical `docs/permanent/...` location. `status:` flips to `accepted`.
- During the move, assign final numbers per `_meta` §8 to TBD-* IDs in increment-level records (FDRs, scoped CDRs, scoped ADRs). Update references to the TBD IDs in the moved content.
- TL outputs (`technical-analysis.md`) remain transient — they're consumed by the backlog loop, not promoted.
- Update INDEX: increment `status: in-progress`, `gate_status:` entry recorded.
- Invoke `backlog-loop` (per `_meta` §6 utility-sub-skill carve-out).

### Step 10 — On changes or rejection

If `gate_status:` records changes or reject:
- **Targeted changes** (item edits, re-sequencing, scope tweaks): orchestrator applies to proposed artifacts in transient; gate-2 re-emits.
- **Substantive changes** (functional gap → re-invoke `increment-functional-analysis`; technical gap → re-invoke `increment-technical-analysis`). Updated proposed artifacts; gate-2 re-emits.

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-IP-1 | Cross-reference integrity failure | re-run dependent subagent |
| T-IP-2 | Backlog item flagged sub-atomic and can't be merged | human (override or restructure) |
| T-IP-3 | Backlog item flagged super-atomic and can't be split | human (override or restructure) |
| T-IP-4 | Circular dependencies | re-sequence or human |
| T-IP-5 | Increment plan rejected with substantive change at Gate 2 | route per human |

## Observations

Surface as `routine`:
- Frequent sub-atomic flags (signal: FA producing scenarios too small).
- Frequent super-atomic flags (signal: features in scope are too coarse for the chosen increment size).
- Backlog items requiring manifest entries beyond the always-allowed set + listed (signal: manifest construction needs more automation).
