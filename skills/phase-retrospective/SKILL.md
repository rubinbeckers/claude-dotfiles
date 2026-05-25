---
name: phase-retrospective
description: Synthesize workflow observations and standards observations into proposed skill diffs and standards updates. Triggers Gate 3 (improvement-review). Invoked by phase-close.
---

# phase-retrospective

Looks back at the phase. Synthesizes `workflow-observations.md` (workflow defects, friction) and `standards-observations.md` (code-quality patterns) into proposed updates. Invokes `workflow-curator` to build skill-diff proposals. Triggers Gate 3 for human approval. Invoked by `phase-close`.

Runs as an orchestration skill in the main chat. Invokes the `workflow-curator` utility sub-skill.

## Inputs

- `docs/transient/phases/<phase-slug>/workflow-observations.md`
- `docs/transient/phases/<phase-slug>/standards-observations.md`
- All halt entries from this phase (across all increments)
- INDEX (for phase delivery stats)
- All skill SKILL.md files (read-only — to construct diffs against)
- Always-allowed set (`_meta` §1)

## Outputs

- `docs/transient/phases/<phase-slug>/phase-retrospective.md` — synthesis document
- Proposed skill diffs at `docs/transient/phases/<phase-slug>/skill-diff-proposals/`
- Proposed standards updates at `docs/transient/phases/<phase-slug>/standards-diff-proposals/`
- INDEX updated: phase status flips to `improvement-review`

## Steps

### Step 1 — Read all observations

Read `workflow-observations.md` and `standards-observations.md` end-to-end. Read all halt entries from the phase's increments.

### Step 2 — Workflow defect synthesis

Synthesize patterns from `workflow-observations.md`:
- Group observations by skill and by pattern (`pattern:` field in each entry).
- For each group with ≥2 occurrences in this phase (T5 — lowered from ≥3 for solo-mode realism), or ≥1 occurrence flagged `critical`, or ≥1 occurrence flagged `human-confirmed`: mark as a candidate for skill change.
- Additionally, count cross-phase occurrences (from prior phases' archived `observations.md` logs): patterns with ≥3 occurrences across the last 3 phases promote even if this phase had only 1 occurrence (T5). This catches recurring friction that solo-phase cadence wouldn't otherwise surface.
- Single-occurrence routine observations are logged in the retrospective but not promoted to proposals (per `agentic-sdlc-principles.md` §7.7 — "Continuous improvement vs stability").

### Step 2.5 — Unresolved debt disposition (M15 + M10)

If the solidifying increment was marked `skipped` (only permitted with completely empty `phase-debt.md` per M15), this step is a no-op.

If the solidifying increment ran but left any unresolved entries in `phase-debt.md` (rare — e.g., entries deferred mid-solidifying), emit a per-entry disposition prompt:

```
Unresolved phase-debt entry: <id>
Description: <one-line>
Choose:
  a) carry-forward to next phase (writes to docs/transient/<phase-slug>/carry-forward/)
  b) accept-and-archive (entry preserved in phase archive, no further action)
  c) open corrective increment (if the entry challenges accepted artifacts)
```

For each entry, the human's reply is applied. No entry vanishes silently.

### Step 3 — Standards adequacy synthesis

Synthesize patterns from `standards-observations.md`:
- Group by standard (coding, testing, naming) and by pattern.
- Same threshold: ≥3 occurrences or ≥1 human-confirmed.
- Standards updates target `docs/permanent/architecture/coding-standards.md` / `testing-standards.md` / `naming-conventions.md`.

### Step 4 — Invoke workflow-curator

Invocation cited under utility-sub-skill carve-out (`_meta` §6):

```
Invoking utility sub-skill workflow-curator (scope: phase <phase-slug>).
Synthesis input: <list of candidate patterns>.
```

`workflow-curator` constructs concrete diffs for each candidate pattern:
- Skill SKILL.md edits (additions, halt-trigger refinements, manifest changes)
- Standards doc additions or revisions
- Workflow.md or _meta.md edits if a meta-level pattern is identified

Each proposed diff has:
- Source observation(s) it addresses
- Concrete change (text diff)
- Estimated risk (low/medium/high based on how invasive the change is)
- Rationale (one paragraph)

### Step 5 — Write phase-retrospective.md

```
# Phase retrospective: <phase-slug>

Grounded in:
  - workflow-observations.md
  - standards-observations.md
  - All halt entries in this phase

## Delivery summary
Increments: <N> delivered, <M> abandoned
Backlog items: <N> delivered, with <Y> avg cycles to review-pass
Corrective increments: <count>
Total gate halts surfaced: <count>

## Workflow defects synthesized
<for each pattern with ≥3 occurrences:>
  Pattern: <description>
  Occurrences: <count> across <skills>
  Proposed: <link to skill-diff-proposals/<id>.diff>

## Standards adequacy
<for each pattern with ≥3 occurrences:>
  Pattern: <description>
  Occurrences: <count>
  Proposed: <link to standards-diff-proposals/<id>.diff>

## Singletons logged (not promoted)
<list of single-occurrence observations, for posterity>

## Halts surfaced (resolution summary)
<for each halt:>
  Source: <skill>
  Resolution: <how it was resolved, link to artifacts>

## Open questions
<patterns that don't yet have a clear proposed action>
```

### Step 6 — Trigger Gate 3 (improvement-review)

Status line:

```
═══════════════════════════════════════════════
Gate 3 reached (improvement-review).
Phase retrospective: docs/transient/phases/<phase-slug>/phase-retrospective.md
Proposed skill diffs: <count>
Proposed standards diffs: <count>

Awaiting human review.
Next: invoke improvement-review skill (or run session-resume).
═══════════════════════════════════════════════
```

Update INDEX: phase status flips to `improvement-review`. Halt; the next session enters via `improvement-review` skill.

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-PR-1 | observations files missing or empty (no signal to synthesize) | continue with empty synthesis (not a halt; emit warning) |
| T-PR-2 | workflow-curator halts (e.g., can't construct a diff for a pattern) | log as open-question in retrospective; do not block |
| T-PR-3 | Critical halt patterns that should have been surfaced inline but were instead batched | open improvement-review halt inline (this is itself a workflow defect) |

## Observations

Surface as `routine`:
- If the phase produced very few observations (<10): is the observation-surfacing discipline being followed? Skills should surface more aggressively.
- If synthesis consistently produces patterns that workflow-curator can't construct diffs for: signal that observation entries lack the structure needed for synthesis.
