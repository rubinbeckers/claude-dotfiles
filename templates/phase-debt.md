# phase-debt.md template

Rolling log of tech debt accumulated during a phase. Sources the solidifying increment's scope.

`backlog-review`, `backlog-test`, `feedback-triage`, and `increment-close` (full regression step) append entries throughout the phase. The solidifying increment's `increment-start` reads this log to seed its scope.

```markdown
# Phase debt: <phase-slug>

feeds-into:
  - (none — consumed by the solidifying increment's scope; pruned at improvement-review)

## Entries

- id: dt-001
  added_at: <ISO timestamp>
  added_by: <skill-name>
  category: flaky-test | dead-code | refactor | discovered-defect-deferred | code-standards-cleanup | other
  source_context: <where this was identified — increment, item, test, observation>
  description: |
    <one-paragraph description of the debt>
  affected_paths:
    - <code or test paths>
  proposed_action: |
    <what should be done to discharge this debt>
  estimated_size: S | M | L
  blocks: <list of phase-debt IDs this depends on, or "none">

- id: dt-002
  added_at: <ISO timestamp>
  added_by: backlog-review
  category: refactor
  source_context: inc-005-invoice-crud, review-cycle-2
  description: |
    The InvoiceController is doing both validation and persistence; the validation
    logic should be extracted into a separate module per the existing pattern used
    by ContactController.
  affected_paths:
    - src/controllers/invoice-controller.ts
    - src/validation/  (new)
  proposed_action: |
    Extract InvoiceValidator; update tests to use the new module; remove the
    inline validation from InvoiceController.
  estimated_size: S
  blocks: none

- id: dt-003
  added_at: <ISO timestamp>
  added_by: backlog-test
  category: flaky-test
  source_context: inc-005-invoice-crud, item 003-add-invoice-form
  description: |
    integration test `invoice-form-submission-with-line-items.test.ts` shows
    intermittent failures on assertion of UI loading state — flake rate ~10%
    across 30 runs without code changes. Likely race in mocked clock advancement.
  affected_paths:
    - tests/integration/invoice-form-submission-with-line-items.test.ts
  proposed_action: |
    Investigate the timing assumption; replace setTimeout-based mocked clock with
    explicit virtual-clock advancement; verify <1% flake rate over 100 runs.
  estimated_size: S
  blocks: none
```

## Categories

- `flaky-test` — test exhibits intermittent pass/fail without code changes.
- `dead-code` — code is reachable but unused (imports, functions, components, routes).
- `refactor` — code works correctly but violates a pattern, has poor cohesion, or duplicates logic.
- `discovered-defect-deferred` — a Category-C discovered defect that was logged here instead of injected as an immediate backlog item (rare; only when injection wasn't appropriate — e.g., defect surfaced at increment-close, too late to inject).
- `code-standards-cleanup` — code violates a standard but the violation wasn't blocking; cleanup queued.
- `other` — catch-all; should be rare.

## Synthesis at solidifying increment-start

`increment-planning` for the solidifying increment reads `phase-debt.md` and decomposes entries into atomic-but-meaningful backlog items per the usual rules. Entries with `blocks:` references are sequenced accordingly.

If the log is empty or has fewer than ~2 material entries, the solidifying increment may be marked `skipped` per `workflow.md` §7.3.
