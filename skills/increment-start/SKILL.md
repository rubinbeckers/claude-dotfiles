---
name: increment-start
description: Initiate an increment. Delegates functional analysis and technical analysis to subagents, then hands off to increment-planning. Invoked by session-resume when the next increment in the phase plan is to begin.
---

# increment-start

Initiates an increment. Creates the increment workspace, delegates FA and TL subagents in sequence, hands off to `increment-planning`. The point at which most of the human-visible analytical detail of a phase becomes concrete.

Runs as an orchestration skill in the main chat. Delegates to subagents.

## Inputs

- INDEX (with phase plan and current position)
- The current increment's row in the phase plan (slug, capabilities, ADRs, prototype paths, dependencies)
- Permanent docs referenced by the phase plan row
- Always-allowed set (`_meta` §1)

## Outputs

- The increment workspace: `docs/transient/phases/<phase-slug>/increments/<inc-slug>/`
- FA subagent outputs (features, BDD scenarios, design specs, FDRs as proposed)
- TL subagent outputs (technical analysis, implementation plans)
- INDEX updated: active increment set, status `planning`

## Steps

### Step 1 — Verify pre-conditions

- INDEX has an active phase with status `in-progress`.
- No active increment is in flight. If one is, halt with `T-IS-1`.
- The next increment's slug from the phase plan is identified.
- Per `workflow.md` §13/§17: no undocumented `develop` commits exist (session-resume would have caught this; double-check).

### Step 2 — Create increment workspace and branch

Create:
```
docs/transient/phases/<phase-slug>/increments/<inc-slug>/
  increment-scope.md             (seeded from phase plan row)
  feedback-inbox.md              (empty stub)
  progress.md                    (empty stub)
  backlog/                       (empty; populated by increment-planning)
  defects-discovered/            (empty; backlog-review writes here per M8)
  proposed/                      (empty; FA proposals go here, promoted at Gate 2 per C3)
    features/
    design-specs/
    decision-records/
      CDR/
      DDR/
      FDR/
      ADR/
```

Git: `git checkout -b inc-<NNN>-<slug>` from `develop`.

Update INDEX: `active_increment: <slug>`, status `planning`.

### Step 2.5 — Detect solidifying increment

Read the phase plan row for this increment. If `Type: solidifying` is set (per `phase-planning` step 4.5), this is the solidifying increment per `workflow.md` §7.3 — its scope comes from `phase-debt.md`, not from new capabilities.

Branch behavior:

- **Solidifying increment, phase-debt.md completely empty:** Mark the increment `status: skipped` in INDEX with `reason: empty debt log`. Skip steps 3–6 of this skill; advance directly to phase-close. Skip is permitted only when the debt log has zero entries — *any* entry forces the increment to run (M15).
- **Solidifying increment, phase-debt.md has any entries:** Proceed to step 3, but seed `increment-scope.md` from `phase-debt.md` entries rather than from a phase-plan-row capability list (see step 3 branching). Skip the FA delegation in step 4 (no new features for solidifying work). Skip the TL delegation in step 5 (the TL has nothing architectural to plan; the debt entries are concrete enough). Advance directly to `increment-planning` with the seeded scope.
- **Solidifying increment, but a debt entry would require new accepted artifacts:** Per workflow.md §7.3 and the §8 halt matrix, escalate the offending entry as a corrective increment instead. Open it before the solidifying increment proceeds.
- **Value-adding increment (not solidifying):** continue normally to step 3.

### Step 3 — Seed increment-scope.md

From the phase plan row, populate `increment-scope.md`:

```
# Increment scope: <inc-slug>

Grounded in:
  - docs/transient/phases/<phase-slug>/phase-plan.md (row for <inc-slug>)

## Objective
<from phase plan>

## Capabilities delivered
<list with links to docs/permanent/capabilities/>

## Architecture decisions exercised
<list of ADRs>

## Design coverage
<list of prototype paths>

## Dependencies
<list of inc-NNN with status>

## Out of scope
<from phase plan, plus anything the human added pre-increment-start>

## Corrects (if corrective increment)
<inc-NNN reference, defect description, link to source observation>
```

### Step 4 — Delegate to increment-functional-analysis subagent

Status line:
```
Delegating to increment-functional-analysis: <inc-slug>.
Manifest: increment-scope.md, referenced capabilities, prototype paths, existing features/, existing FDRs.
```

Construct subagent prompt per `increment-functional-analysis.md`. Invoke via Task tool.

Parse return:
- On success: FA wrote/updated `docs/permanent/features/<feature-slug>.md` (with BDD scenarios), `docs/permanent/features/design-specs/<feature-slug>.md`, possibly new FDRs (still proposed). Update INDEX.
- On halt (domain gap): route to `phase-business-analysis` loopback — re-passes Gate 1.
- On halt (capability ambiguity): route to human at phase level.

### Step 5 — Delegate to increment-technical-analysis subagent

Status line:
```
Delegating to increment-technical-analysis: <inc-slug>.
Manifest: increment-scope.md, FA outputs from step 4, referenced architecture docs, existing ADRs.
```

Construct subagent prompt per `increment-technical-analysis.md`. Invoke via Task tool.

Parse return:
- On success: TL produced `docs/transient/phases/<phase-slug>/increments/<inc-slug>/technical-analysis.md` with per-feature implementation considerations and a per-backlog-item plan template. Update INDEX.
- On halt (architecture gap): route to `phase-technical-architecture` loopback — re-passes Gate 1.

### Step 6 — Advance to increment-planning

Status line:
```
Increment start complete. FA wrote: <N> features, <M> scenarios. TL wrote: technical analysis covering <N> features.
Advancing to increment-planning.
```

Invoke `increment-planning`.

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-IS-1 | Active increment already in flight | human (one active increment at a time, §1) |
| T-IS-2 | Phase plan row for the next increment is malformed | `phase-planning` re-run |
| T-IS-3 | Undocumented develop commits detected | human (corrective-increment backfill per §17) |
| T-IS-4 | FA halt: capability not in this phase's accepted set | `phase-business-analysis` loopback |
| T-IS-5 | TL halt: ADR not in this phase's accepted set | `phase-technical-architecture` loopback |
| T-IS-6 | Either subagent halt is critical (workflow defect surfaced) | inline improvement-review halt |
| T-IS-7 | Dependency increment not delivered | human (resequence or abandon) |

## Observations

Surface as `routine`:
- FA loopbacks occurring more than once per phase (signal: phase-business-analysis quality is below threshold).
- TL loopbacks occurring more than once per phase (signal: phase-technical-architecture is leaving gaps).
- Increments where the phase-plan row was significantly modified at increment-start (signal: phase planner needs more detail upstream).
