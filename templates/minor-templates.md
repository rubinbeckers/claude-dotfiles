# Minor templates

Small templates used inline by skills. Collected here to avoid proliferating tiny files in the templates/ directory.

## Editorial log

A sibling `editorial-log.md` next to an accepted artifact records typo / formatting / link / capitalisation / whitespace changes made in place (per `_meta` §8 and `doc-structure.md` §8). Semantic changes are supersession, not editorial.

```markdown
# Editorial log: <artifact-path>

- timestamp: <ISO>
  by: <human-identifier or skill name>
  scope: typo | formatting | link | capitalization | whitespace
  description: <one-line>

- timestamp: <ISO>
  by: ...
  ...
```

## Pause record

Written by `project-pause` at `docs/transient/pauses/<ISO>.md`.

```markdown
# Pause: <ISO>

Active phase: <slug or "none">
Active increment: <slug or "none">
Last completed skill: <name>
Next expected skill: <name>

Outstanding items:
  - <halt or unresolved gate>
  ...

Hand-off note:
  <human's note, or "none">

Resume by: running session-resume (or "resume").
```

## Progress log

Per-increment running log appended by `increment-execute`, `increment-close`, and post-merge fix handling. Lives at `docs/transient/phases/<phase>/increments/<inc>/progress.md`.

```markdown
# Progress: <inc-slug>

## Cycle 1 (develop → test → review)

- <ISO>: increment-develop started. Manifest: <N> docs.
- <ISO>: increment-develop returned success. Files: <count>.
- <ISO>: parent-commit classification: <results>.
- <ISO>: increment-test started.
- <ISO>: increment-test returned success. Tests: <unit/int/ui counts>.
- <ISO>: increment-review started.
- <ISO>: increment-review verdict: PASS.

## Cycle 2 (if applicable)

...

## Increment-close

- <ISO>: full regression — pass.
- <ISO>: doc-integrity — clean.
- <ISO>: Gate 3 approved.
- <ISO>: PR opened — <url>.

## Post-merge fixes (if any)

- <ISO>: fix branch fix/<inc-slug>/<short> opened. Description: <one-line>.
- <ISO>: fix PR opened — <url>.
- <ISO>: CI passed; human approved on staging.
- <ISO>: fix merged.

## Close

- <ISO>: human approved; increment status flipped to closed.
```

## Defect-discovered spec

Written by `increment-review` for each Category-C finding at `defects-discovered/<slug>.md`.

```markdown
# Discovered defect: <slug>

logged_at: <ISO>
source_review: <path to review.md>
failing_test: <path>
affected_code: <best-effort path>
pre_existing: yes | no
git_history_check: <result from orchestrator>

## Test output summary

<truncated test output>

## Proposed defect-fix spec

<one-paragraph spec for a backlog-style entry to address in the solidifying increment>

## Proposed size

S | M | L

## Routing

phase-debt (appended at <ISO>)
```

## Status line patterns

`backlog-loop`-style status lines from v1.0 are replaced by these:

- `Routing: <skill> (active <scope>; reason: <one-line>)` — emitted by `session-resume`.
- `Delegating to <agent>: <inc-slug>. Manifest: <doc count>.` — emitted by every orchestration skill on subagent invocation.
- `<agent> returned. Wrote: <files>. Findings: <summary>.` — emitted on subagent return.
- `Cycle <K>/3: <step> (develop | test | review).` — emitted by `increment-execute`.
- `PR opened: <url>. Target: <branch>.` — emitted by `increment-close` step 8.
- `Fix PR opened: <url>. Awaiting CI + validation.` — emitted by `increment-close` step 11.
- `Approval received; increment <slug> → closed. Advancing to <next>.` — emitted by `increment-close` step 12.
- `Phase <slug> closed. <counts>.` — emitted by `phase-close` step 11.

Skills don't need to restate these patterns; this is the canonical list.
