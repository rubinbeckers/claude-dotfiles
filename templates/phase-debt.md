# Phase-debt template

Entries appended throughout the phase by `increment-review` (Category-C discovered defects, code-level standards observations, refactoring opportunities), `increment-test` (flaky tests), `feedback-triage` (SOLIDIFYING_DEBT dispositions), `increment-close` (regression findings deferred to solidifying), and `increment-design` / `increment-execute` (design deviations the human classed as phase debt — `_meta` §17).

The phase's solidifying increment fully drains this log at `increment-design` step 2 by dispositioning every entry. After the solidifying increment's `increment-close`, the log is empty.

```markdown
# Phase debt: <phase-slug>

(Appended chronologically. Every entry receives a disposition at the solidifying increment's drain step.)

## Entries

### debt-001 — <one-line description>

- logged_at: <ISO>
- source: <skill or agent>
- source_increment: <inc-slug>
- category: discovered-defect | flaky-test | refactor | standards-observation | regression | design-deviation
- severity: low | medium | high
- size: S | M | L                          # estimate from the logging source; default M
- description: |
  <Multi-line description.>
- failing_test_path: <path, if applicable>
- affected_code: <best-effort path, if applicable>
- proposed_action: <what the solidifying increment should do>
- references:
  - <links to observations, review.md, defect-discovered files, etc.>
- disposition: pending                      # set to one of: pending | included | deferred | accepted
- dispositioned_at: null                    # ISO timestamp when disposition was assigned
- dispositioned_by: null                    # human identifier

### debt-002 — <one-line>

...
```

## Disposition values

- `pending` — accumulating; not yet dispositioned. Only valid before the solidifying-increment-design drain step.
- `included` — to be absorbed by the active solidifying increment. Stays in the log until that increment's close, at which point the log is truncated.
- `deferred` — moved to `docs/transient/phases/<phase>/carry-forward/deferred-debt.md`. Carried to the next phase via M10.
- `accepted` — accepted as permanent technical debt; appended to `docs/permanent/architecture/accepted-debt.md`. Removed from the active log.

Any entry that's `pending` past the solidifying-increment-design step is a workflow defect — `doc-integrity` flags it at the next close gate.

## Design-deviation entries

A `category: design-deviation` entry is a provisional component (or accepted token gap) the human classed as phase debt at a `design-gap` decision (`_meta` §17). Its `references:` point to the `design-deviations.md` entry and the design-spec's provisional component. Reconciling it usually requires a **human edit to `design.md`** (promoting the provisional into the design system) followed by an agent refactor of the provisional usage to reference the now-official component — so the solidifying increment surfaces a proposed component definition for the human rather than editing the human-owned `design.md` itself. When reconciled, append `reconciled_at:` / `reconciled_in:` to the `design-deviations.md` entry.
