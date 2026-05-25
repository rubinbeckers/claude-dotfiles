# Backlog item template

```markdown
# Backlog item: <NNN>-<slug>

feeds-into:
  - (none by default — backlog items are transient; delivery state is tracked in INDEX)

Grounded in:
  - docs/transient/phases/<phase>/increments/<inc>/increment-scope.md
  - docs/permanent/features/<feature>.md (specific scenarios)
  - docs/permanent/features/design-specs/<feature>.md (specific DS-IDs)
  - docs/permanent/design/prototype/<paths>
  - <ADRs if applicable>

## Objective

<One-line.>

## Scope

What this item delivers:
- <user-visible behavior 1>
- <user-visible behavior 2>

What this item does NOT deliver (out-of-scope explicit):
- <item>

## BDD scenarios covered

- <feature-slug>: scenario "<scenario name>"
- ...

## Design-spec requirements

- DS-<feature-slug>-<id>: <one-line>
- ...

## Implementation plan

(Populated by increment-planning from technical-analysis.md's candidate-item section.)

- Files to create: <list>
- Files to modify: <list>
- Approach: <prose, ≤200 words>
- Cross-references to ADRs: <list>
- Cross-cutting concerns: auth/authz, validation, error handling, logging, persistence

## Context manifest (for backlog-develop)

The orchestrator passes these to the developer subagent:
- This backlog item spec
- <feature file(s)>
- <design-spec file(s)>
- <listed prior-increment code paths, explicitly>
- <referenced ADR(s)>
- (always-allowed: coding-standards, testing-standards, naming-conventions, glossary)

## Context manifest (for backlog-test)

The orchestrator passes these to the tester subagent (no implementation):
- This backlog item spec
- <feature file(s)>
- <design-spec file(s)>
- <prototype paths>
- (always-allowed: testing-standards, naming-conventions, glossary)

NOT passed: implementation diff, unit tests, technical-analysis.md.

## Context manifest (for backlog-review)

The orchestrator passes these to the reviewer subagent:
- This backlog item spec
- <feature file(s)>
- Implementation diff (from backlog-develop output)
- Unit tests (from backlog-develop)
- Integration/UI tests (from backlog-test)
- Test results
- <referenced ADR(s)>
- (always-allowed: all standards docs, glossary)

## Depends on

(References use SLUG only per workflow.md §15.5 — position numbers shift on injection, slugs don't.)

- <slug>: <reason>

## Estimated size

S | M | L

## Lifecycle

(Updated as the item progresses.)

- status: pending | develop-in-progress | test-in-progress | review-cycle-K-of-3 | done | abandoned | injected
- develop_at: <timestamp>
- test_at: <timestamp>
- review_at: <timestamp>
- done_at: <timestamp>
- review_cycles: <count>
- cycle_extensions_granted: <count>     # M5 — number of human-approved budget extensions
- correction_depth: 0                    # M5 — depth in corrective lineage (0 = original; >0 = corrective of corrective)
- injected_from: <source-item-slug>     # only if this item was injected via §7.1 discovered-defect
- discovered_during: <source-item-slug> # only if injected; original item that surfaced the defect
```
