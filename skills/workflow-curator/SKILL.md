---
name: workflow-curator
description: Utility skill. Synthesizes accumulated observations into proposed diffs to skills, agents, and standards docs. Invoked by phase-close.
---

# workflow-curator

The observation-to-improvement synthesizer. Cited under the utility carve-out per `_meta` §7.

## Inputs

- `docs/transient/phases/<phase>/observations.md` (all entries from the phase)
- Prior `rejection-log.md` from the dotfiles repo (so already-rejected patterns aren't re-proposed)
- Always-allowed set

## Outputs

- `docs/transient/phases/<phase>/skill-diff-proposals/<id>.diff` per proposed skill or agent change
- `docs/transient/phases/<phase>/standards-diff-proposals/<id>.diff` per proposed standards change
- Synthesis summary in `docs/transient/phases/<phase>/curator-summary.md`

## Steps

### 1. Cluster, then read selectively

Observations accumulate at scale (a long-running project may produce hundreds per phase). Loading every full entry up front is wasteful and degrades synthesis as the pile grows.

Do a two-pass read:

1. **Summary scan first.** Iterate `observations.md` reading only each entry's `category`, `severity`, `pattern`, and `timestamp`. Cluster by `category` × similar `pattern` (string similarity is fine).
2. **Selective full read.** For each cluster, load full entries only if: (a) the cluster has ≥3 occurrences across the phase, OR (b) any entry in the cluster carries `severity: critical`, OR (c) the cluster matches an open carry-forward proposal from a prior phase. Singletons of `severity: routine` without matching patterns are surfaced in the curator summary but not turned into proposals — the threshold for proposing is "pattern has reoccurred or is critical."

This keeps the curator's context bounded as the project grows and prevents low-signal entries from drowning real patterns.

### 2. Filter against rejection log

For each clustered pattern, check the rejection log: has this same pattern been rejected in a prior phase? If yes, surface only with new occurrences flagged `human_confirmed: true`, or skip — don't re-propose what's been rejected unless there's new evidence.

### 3. Synthesize proposals

For each cluster the rejection-log filter leaves, propose a concrete diff:

- **category: workflow-defect** → diff to the affected skill's SKILL.md, or to `_meta`, or to a new skill if the pattern indicates a gap.
- **category: standards-coding / standards-testing / standards-naming** → diff to the relevant standards doc.
- **category: other** → surface as an open question; the human classifies at the gate.

Each proposed diff is a real unified diff (with `--- a/<path>` and `+++ b/<path>` headers) so it can be applied mechanically on approval.

### 4. Assess risk per proposal

For each proposal, assign a risk level:
- **low**: edit to standards docs, observation surfacing changes, comment-only changes in skills.
- **medium**: behavioural changes to a non-critical-path skill.
- **high**: changes to `_meta`, `session-resume`, `increment-execute`, `workflow-curator` itself, or any subagent definition.

High-risk changes get the staging treatment at `phase-close` step (next session applies them before routing).

### 5. Write proposals

For each proposal, write a `.diff` file at the path above with a header block:

```
# proposal-id: <id>
# source-observations: <count>
# patterns:
#   - "<pattern 1>"
#   - "<pattern 2>"
# risk: low | medium | high
# rationale: <one-paragraph: why this change addresses the pattern>
```

followed by the unified diff.

### 6. Write curator-summary.md

```
# Curator summary: <phase>

Observations processed: <count>
Patterns identified: <count>
Proposals generated: <count>
  - Skill/agent diffs: <count>
  - Standards diffs: <count>
Patterns filtered (matched rejection log): <count>

## Proposals

- <id>: <one-line> (risk: <level>)
- ...
```

### 7. Return

Structured return per `_meta` §4 with the proposal count by category.

### Apply mode (called by phase-close on approval)

When invoked with `mode: apply` plus a list of approved proposal IDs:

For each ID:
- Read the proposal file.
- Apply the unified diff to the target file (in the dotfiles repo if it's a skill/agent, in the project repo if it's a standards doc).
- Verify the result parses (SKILL.md frontmatter intact, standards doc readable). If not, revert and halt to human.
- If the target is in the dotfiles repo, commit with `feat(<target>): <one-line summary> [phase <slug>]`.
- For rejected proposals, append to `rejection-log.md` in the dotfiles repo with reason.

## Edges

- A proposal would touch a file outside the workflow's edit scope (e.g., an .env, a third-party doc) → flag as out-of-scope; don't generate.
- Two proposals conflict (same file, overlapping diffs) → merge into one or surface both with the conflict explicit; the human picks.
- Apply-mode finds the target file has changed since proposal generation → halt; re-synthesize with the current state.

## Observations to surface

Patterns rejected three or more times across phases (signal: the synthesis heuristic is wrong, not the observation); proposals never being approved (signal: the pattern threshold for proposing may need raising, or the human disagrees with the synthesis).
