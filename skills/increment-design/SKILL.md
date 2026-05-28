---
name: increment-design
description: Initiates an increment. Detects solidifying-increment handling, seeds the increment scope, delegates to domain-design and technical-design agents in sequence, produces increment-scope (with sequencing) and the implementation plan, triggers Gate 2, and on approval advances to increment-execute. Invoked by session-resume or by phase-design after Gate 1 approval.
---

# increment-design

The increment-level analytical and planning pass, in one skill. Consolidates what v1.0 split between `increment-start` and `increment-planning`.

## Inputs

- INDEX (active phase, current position in the phase plan)
- The current increment's row in `phase-plan.md` (slug, capabilities, ADRs, prototype paths, dependencies, type)
- Accepted permanent docs referenced by the row
- `phase-debt.md` (if this is a solidifying increment)

## Outputs

- Increment workspace under `docs/transient/phases/<phase>/increments/<inc>/`
- Domain-design outputs as proposed artifacts (features, design specs, DRs)
- Technical-design output: `technical-analysis.md` (transient)
- `increment-scope.md` (with sequencing list)
- Gate 2 prompt, then on approval: status flips to `accepted` on proposed artifacts, IDs assigned, INDEX updated, branch created

## Steps

### 1. Verify preconditions

INDEX has an active phase with status `in-progress`. No other increment is in flight (one active increment at a time). The next increment's slug is identified from the phase plan. No undocumented `develop` commits exist since the last recorded state.

### 2. Detect solidifying increment

Read the phase-plan row. If `type: solidifying`:

- If `phase-debt.md` is completely empty: mark the increment `status: skipped` in INDEX, advance to `phase-close`.
- If a debt entry would require new accepted artifacts (a missing capability, a wrong ADR): escalate that entry as a corrective increment instead, before this solidifying increment proceeds.
- Otherwise: run the drain disposition (per `workflow.md` §9).

**Drain disposition.** Read all `disposition: pending` entries from `phase-debt.md`. Estimate cumulative sizing (sum of per-entry sizing, where each entry carries an S/M/L estimate from the source that logged it — default M if unstated).

If the cumulative sizing fits within one increment's normal upper bound (typically 16 hours of work):
- Mark every entry `disposition: included`.
- Seed `increment-scope.md` from the included entries.

If the cumulative sizing exceeds the bound, surface a disposition prompt:

```
═══════════════════════════════════════════════
Phase debt drain — disposition required
Active scope: <phase-slug>/<inc-slug> (solidifying)

Entries: <N> pending. Estimated cumulative size: ~<X> hours (budget: 16h).

The following entries fit within budget (proposed `include`):
  - debt-<id>: <one-line> (size: S/M/L)
  ...

The following entries exceed budget — disposition required:
  - debt-<id>: <one-line> (size: S/M/L)
  ...

For each overflow entry, reply with one of:
  include <id>   → absorb into this increment (budget grows)
  defer <id>     → carry forward to next phase
  accept <id>    → accept as permanent technical debt (recorded, removed from log)

Or: "accept overflow" to accept-all, "defer overflow" to defer-all, or per-entry decisions.
═══════════════════════════════════════════════
```

Parse the reply. For each entry, apply the chosen disposition:
- `include` → entry's `disposition: included`. Stays in the log; absorbed by this increment.
- `defer` → entry moves to `docs/transient/phases/<phase>/carry-forward/deferred-debt.md` with `disposition: deferred`. Removed from the active log.
- `accept` → entry appended to `docs/permanent/architecture/accepted-debt.md` with `disposition: accepted`, `accepted_at: <ISO>`, `accepted_in_phase: <phase-slug>`. Removed from the active log.

After dispositions are applied, no entry in `phase-debt.md` remains `pending`. Seed `increment-scope.md` from the entries with `disposition: included`. Skip the domain-design and technical-design delegations (solidifying entries are concrete code-level work; no new features or ADRs). Advance directly to step 8 (Gate 2) with the debt-derived scope.

For value-adding increments (not solidifying), continue to step 3.

### 3. Create workspace and branch

```
docs/transient/phases/<phase>/increments/<inc>/
  increment-scope.md             (seeded from phase-plan row)
  feedback-inbox.md              (empty stub)
  progress.md                    (empty stub)
  defects-discovered/            (empty)
```

Git: `git checkout -b inc-<NNN>-<slug>` from `develop`.

Update INDEX: `active_increment: <slug>`, `status: design`.

### 4. Seed increment-scope

From the phase-plan row, populate `increment-scope.md`:

```
# Increment scope: <slug>

Grounded in:
  - phase-plan.md (row for <slug>)

## Objective
<from phase plan>

## Capabilities delivered
<list with links to docs/permanent/capabilities/>

## Architecture decisions exercised
<list of ADRs>

## Design coverage
<list of prototype paths>

## Dependencies
<list of prior increments>

## Out of scope (explicit)
<from phase plan, plus human additions>

## Corrects (if corrective)
<reference, defect summary, source>
```

### 5. Delegate to domain-design

Manifest with `mode: increment`. Inputs: increment-scope.md, the capabilities the increment delivers (accepted), prototype paths, existing features the increment touches, glossary, naming-conventions.

Parse return. On success: domain-design wrote proposed features, design specs, and DRs under `docs/permanent/...`. On halt routing back to phase-design (e.g., capability ambiguity, glossary gap): re-pass Gate 1 for the affected phase artifacts.

### 6. Delegate to technical-design

Manifest with `mode: increment`. Inputs: increment-scope.md, domain-design outputs from step 5, accepted architecture docs, accepted ADRs.

Parse return. On success: technical-design wrote `technical-analysis.md` (transient) with per-feature considerations, the sequenced implementation plan, and any new proposed ADRs. On halt to phase-technical-architecture (architecture gap): re-pass Gate 1.

### 7. Author sequencing list

Append a "Sequencing" section to `increment-scope.md` listing the units of work, derived from `technical-analysis.md`. Each entry:

```
- slug: <NNN>-<short>
  objective: <one-line>
  scenarios: [<feature-slug>:<scenario name>, ...]
  design-spec-ids: [DS-<feature-slug>-<id>, ...]
  files: [<paths to create or modify>]
  approach: <prose, ≤200 words>
  cross-references: [<ADR slugs>]
  cross-cutting: [<auth/validation/error/logging/persistence concerns>]
  depends: [<other sequencing slugs in this increment>]
  size: S | M | L
```

Apply the atomic-but-meaningful check to each entry:
- Too small → merge into a sibling.
- Too large → split.
- Otherwise → keep.

Sequencing order: technical dependencies first, then risk (architecturally complex earlier), then feature grouping.

### 8. Cross-reference integrity

Verify every referenced scenario exists in the proposed feature files; every design-spec ID exists; every prototype path exists; every `depends:` is to an earlier sequencing entry. Halt on failure (re-run the relevant subagent).

### 9. Surface oversized entries

Any entry size L, or covering >3 scenarios, or covering >2 design-spec requirements: surface for split-proposal at Gate 2.

### 10. Gate 2

Emit the gate-2 approval prompt per `_meta` §13. List proposed features, design specs, DRs, and any new ADRs (with one-line summaries); list the sequencing entries; reference the increment-scope.md and technical-analysis.md files for review.

Parse reply:
- **approve** → step 11.
- **approve with modifications** → apply modifications; step 11.
- **changes** → targeted edits to proposed artifacts; re-emit prompt.
- **reject** → re-invoke the relevant subagent with rejection notes; updated proposals re-emit prompt.

### 11. Promote and number

For each artifact under `docs/permanent/...` with `status: proposed`:
- Flip `status:` to `accepted`.
- Assign final IDs to any `TBD-<slug>` placeholders.
- Update internal references.

`technical-analysis.md` stays transient — it's consumed by the execute step, not promoted.

Update INDEX: increment `status: in-progress`, `gate_status:` entry recorded.

### 12. Advance

Invoke `increment-execute`.

## Edges

- Active increment already in flight → halt to human (one at a time).
- Phase-plan row malformed → re-pass phase-design.
- Undocumented develop commits → human for backfill.
- Subagent halt routing above the increment → re-pass Gate 1.
- Dependency increment not delivered → human (resequence or abandon).

## Observations to surface

Subagent loopbacks occurring more than once per phase (signal: phase-design quality); increments where the phase-plan row was significantly modified at design time (signal: phase planner needs more detail); recurring oversized-entry flags at step 9 (signal: increment sizing rule too loose).
