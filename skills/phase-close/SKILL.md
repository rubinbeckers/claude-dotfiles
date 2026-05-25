---
name: phase-close
description: Close a phase. Runs doc-consolidation and integrity sweep, surfaces proposed permanent-doc deltas for human approval, then hands off to phase-retrospective. Invoked by session-resume after the last increment of the phase delivers.
---

# phase-close

Closes a phase. Consolidates transient docs into permanent ones (via `doc-consolidator`), runs a full `doc-integrity` sweep, surfaces proposed permanent-doc deltas, then advances to `phase-retrospective`.

Runs as an orchestration skill in the main chat. Invokes utility sub-skills per the carve-out in `_meta` §6.

## Inputs

- INDEX (with all increments of this phase marked `closed`)
- All transient docs under `docs/transient/phases/<phase-slug>/`
- All permanent docs (read-only at this step; deltas are *proposed*, applied at gate)
- Always-allowed set (`_meta` §1)

## Outputs

- Proposed permanent-doc deltas in `docs/transient/phases/<phase-slug>/consolidation-proposed.md`
- `doc-integrity` report at `docs/transient/phases/<phase-slug>/integrity-report.md`
- INDEX updated: phase status flips to `closing`

## Steps

### Step 1 — Verify pre-conditions

- All increments listed in the phase plan have status `closed` in INDEX.
- No `awaiting-merge` increments remain. If any do, halt with `T-PC-1`.
- No unresolved halts in `workflow-observations.md`. If any, halt with `T-PC-2`.

### Step 2 — Invoke doc-consolidator

Invocation cited under utility-sub-skill carve-out (`_meta` §6):

```
Invoking utility sub-skill doc-consolidator (scope: phase <phase-slug>).
```

`doc-consolidator` walks all transient docs in this phase's workspace, reads their `feeds-into:` headers, and produces a proposed-deltas document listing every change to permanent docs. The deltas are *not* applied yet — they go to `consolidation-proposed.md` for human review at the close gate.

Surface the consolidator's return summary.

### Step 3 — Invoke doc-integrity (full sweep)

Invocation cited under utility-sub-skill carve-out:

```
Invoking utility sub-skill doc-integrity (scope: full).
```

`doc-integrity` performs a full sweep at phase close:
- Reference validation: every `Grounded in:` source exists, is in scope, and is current.
- Supersession bidirectionality: every `superseded-by:` has matching `supersedes:` and vice versa.
- Decision-record status consistency: no `proposed` records remain that should have been numbered or withdrawn.
- TBD-ID resolution: no `TBD-*` placeholders remain in permanent docs.
- Withdrawn/deprecated reference check: no accepted record references a withdrawn or deprecated one.

Surface the integrity report.

### Step 4 — Surface proposed deltas via structured approval prompt

Emit the phase-close approval prompt per `_meta` §13.3:

```
═══════════════════════════════════════════════
APPROVAL REQUIRED — Phase-close consolidation
Active scope: <phase-slug>

Summary of changes proposed:
  <2–3 sentence summary: how many doc-deltas, integrity verdict, carry-forward queue size>

Files for review:
  - docs/transient/phases/<phase-slug>/consolidation-proposed.md — <N> proposed deltas
  - docs/transient/phases/<phase-slug>/integrity-report.md — integrity findings

To approve all deltas: reply "approve".
To approve selectively: reply "approve: <list>".
To reject some: reply "reject: <list with reasons>".
To request changes: reply "changes: <list>".
═══════════════════════════════════════════════
```

This is *not* a separate human gate (Gate 3 is improvement-review, after retrospective). It's the consolidation review inside `phase-close`.

### Step 5 — Apply approved deltas

When the human returns:

- For each approved delta in `consolidation-proposed.md`: apply to the relevant permanent doc. The skill makes the edit; the human's role was approving the delta, not making the edit.
- For each rejected delta: log in INDEX with `delta_rejected:` reason; the source transient content is *not* pruned yet (rejected content survives until retrospective resolves it).
- For integrity findings flagged `critical`: must be resolved before retrospective. Critical findings typically route to a corrective increment per `workflow.md` §9.

### Step 6 — Prune transient content (selective)

For every transient doc in this phase's workspace:
- If all its `feeds-into:` declarations have been processed (either applied or explicitly deferred), the doc is eligible for pruning.
- Pruning happens *after* retrospective and improvement-review, not here. This step just *marks* transient docs as eligible.

Mark in INDEX: `transient_pruning_eligible: <list of paths>`.

### Step 7 — Advance to phase-retrospective

Status line:

```
Phase close consolidation complete. Advancing to phase-retrospective.
```

Update INDEX: phase status flips to `retrospective`. Invoke `phase-retrospective`.

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-PC-1 | Increment in `awaiting-merge` state | human (merge or abandon increment first) |
| T-PC-2 | Unresolved halt in workflow-observations | resolve halt first, then re-invoke |
| T-PC-3 | doc-integrity reports `critical` finding requiring corrective increment | open corrective increment per workflow.md §9 |
| T-PC-4 | Human rejects all deltas (substantive consolidation disagreement) | re-run prior increment(s) consolidation or open corrective increment |
| T-PC-5 | doc-consolidator halts (e.g., feeds-into target doc doesn't exist) | resolve, then re-invoke |

## Observations

Surface as `routine`:
- Transient docs that consistently produce no consolidation deltas (signal: the doc may be permanent-track candidate, or it's working scaffold that doesn't need feeds-into).
- High volume of rejected deltas (signal: doc-consolidator's synthesis quality should be reviewed).
- Integrity findings clustered around a specific doc type (signal: that template's discipline needs reinforcement).

Surface as `critical`:
- Integrity findings indicating bidirectional supersession failures (workflow invariant violated).
- TBD-ID found in a permanent doc that's not from the just-closed increment (numbering rule violation across increments).
