---
name: phase-close
description: Closes a phase. Runs a full doc-integrity sweep (including subtree-INDEX regeneration), invokes workflow-curator to synthesize observations, surfaces consolidated deltas + skill diffs + standards diffs at Gate 4, applies approved changes (staging critical-path skill diffs for next session), prunes transient docs to archive. Invoked by increment-close when the last increment of the phase advances to `closed`.
---

# phase-close

The end-of-phase consolidation gate. Combines what v1.0 split between `phase-close`, `phase-retrospective`, and `improvement-review` into a single approval cycle.

## Inputs

- INDEX (all increments of the phase marked `closed`)
- All transient docs under `docs/transient/phases/<phase>/`
- Accepted permanent docs (read-only at this step; deltas are proposed)
- `observations.md` from the phase
- `docs/skill-versions.lock`
- Always-allowed set

## Outputs

- `integrity-report.md` (full sweep)
- `curator-summary.md` and proposal files under `skill-diff-proposals/` and `standards-diff-proposals/`
- Approved deltas applied to permanent docs
- Approved skill diffs applied to the dotfiles repo (or staged for next session if critical-path)
- Updated `docs/skill-versions.lock`
- INDEX updated: phase `status: closed`, transient archived

## Steps

### 1. Verify preconditions

All increments in the phase plan have status `closed` in INDEX. No increment is `awaiting-merge` or `abandoned-without-routing`. No unresolved halts in any increment's `progress.md` or in `observations.md` of severity `critical`.

### 2. Invoke doc-integrity (full sweep)

Utility carve-out per `_meta` §7.

```
Invoking utility sub-skill doc-integrity (scope: full).
```

Full sweep validates references, supersession, statuses, invariants, and regenerates every indexed subtree's `subtree-INDEX.md`. Output: `docs/transient/phases/<phase>/integrity-report.md`.

### 3. Invoke workflow-curator

Utility carve-out.

```
Invoking utility sub-skill workflow-curator (mode: synthesize, scope: phase <phase>).
```

Curator reads `observations.md`, filters against the rejection log, and writes proposal files under `skill-diff-proposals/` and `standards-diff-proposals/`. Output: `curator-summary.md`.

### 4. Identify consolidation deltas

Most increments produced no consolidation deltas at close — proposed artifacts are already promoted at Gate 2. But the phase may have accumulated:
- Standards-doc deltas from observations the curator synthesized.
- Permanent-doc updates from human-classified feedback entries.
- New cross-context invariants surfaced during the phase.

Aggregate any such deltas into `docs/transient/phases/<phase>/consolidation-proposed.md`.

### 5. Gate 4 — Phase close

Emit the gate-4 approval prompt per `_meta` §13:

```
═══════════════════════════════════════════════
APPROVAL REQUIRED — Gate 4 (Phase close)
Active scope: <phase-slug>

Summary:
  doc-integrity: <clean | critical count, routine count>
  Consolidation deltas: <count>
  Skill/agent diff proposals: <count> (<low/med/high risk distribution>)
  Standards diff proposals: <count>

Files for review:
  - integrity-report.md
  - curator-summary.md
  - consolidation-proposed.md (if non-empty)
  - skill-diff-proposals/* (per-proposal decision)
  - standards-diff-proposals/* (per-proposal decision)

For each proposal, reply with one of:
  approve <id>          → apply as-is
  modify <id>: <notes>  → apply with notes (you'll be asked to edit the diff)
  defer <id>            → carry forward to next phase
  reject <id>: <reason> → reject and log

To approve all: "approve all".
To handle individually: list per-proposal decisions.
═══════════════════════════════════════════════
```

Parse reply. For "approve all", every proposal is approved. For per-proposal decisions, apply each.

### 6. Apply approved consolidation deltas

For each approved delta in `consolidation-proposed.md`: apply to the target permanent doc. Track in INDEX.

### 7. Apply approved skill/agent diffs (with staging)

For each approved proposal:

- **High-risk** (targets `_meta`, `session-resume`, `increment-execute`, `workflow-curator`, or any subagent definition): **stage** for next session. Copy the diff to `docs/transient/pending-skill-diffs/<id>.diff` and record in INDEX. `session-resume` applies it before any routing decision in the next session.
- **Medium/low risk** (all other skills and standards docs): apply now. Invoke `workflow-curator` in `mode: apply` with the proposal IDs.

For each applied diff in the dotfiles repo, the curator commits with a structured message. For diffs in the project repo (standards docs), commit on the project's `develop` branch.

### 8. Update skill-versions.lock

For each applied dotfiles change, the new dotfiles commit hash or tag is the new canonical. Update `docs/skill-versions.lock` in the project to pin to the new version. Commit on `develop`.

### 9. Log rejections and deferrals

- **Rejected proposals**: append to `rejection-log.md` in the dotfiles repo with proposal ID, reason, source observations, timestamp.
- **Deferred proposals**: append to `docs/transient/phases/<phase>/carry-forward/deferred-proposals.md`. The next phase's `phase-design` step relocates carry-forward content.

### 10. Archive the phase

Move `docs/transient/phases/<phase>/` to `docs/transient/archive/<phase>/`. Preserves the audit trail; clears the active tree of working state for the next phase.

### 11. Close the phase

INDEX:
- Phase `status: closed`.
- `active_phase: null`.
- Closed-phase summary recorded (increments delivered, gate decisions, key outcomes).
- `transient_pruning_eligible:` cleared.

Status line:

```
═══════════════════════════════════════════════
Phase <phase-slug> closed.
Skill/agent diffs applied: <count> (in-session) + <count> (staged for next session)
Standards diffs applied: <count>
Transient archived: docs/transient/archive/<phase-slug>/

<if staged diff count > 0:>
⚠ <N> high-risk skill/agent diff(s) staged at docs/transient/pending-skill-diffs/.
   These are NOT yet active. Run session-resume before proceeding so they apply.
   If you supply raw input for the next phase in the same session, phase-design
   will defensively apply them before its first step — but session-resume is the
   intended entry point.

Next action: provide raw input for the next phase (if any), then run session-resume.
═══════════════════════════════════════════════
```

## Edges

- Increment still `awaiting-merge` → halt; route to that increment-close to finish first.
- doc-integrity reports critical findings → halt to human (likely opens a corrective increment).
- Staged diff fails to apply at next session-resume → re-synthesize at that point (handled by session-resume).
- Applied diff produces a malformed skill or standards doc → revert; halt to human.
- All proposals rejected (no improvements adopted) → continue; surface a warning that the phase's signal was discarded.

## Observations to surface

Phases with no proposals at all (signal: observations aren't being surfaced, or the curator's threshold is too tight); phases where the consolidation produced 0 deltas (signal: nothing was learned during execution that fed back, or the observation channel didn't reach worthy content); high deferral rate (signal: the human isn't engaging with improvements at this gate).
