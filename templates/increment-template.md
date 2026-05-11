# Increment Template

> Referenced by `project-init` and used by `increment-start`. Describes the structure of every increment folder. Skeleton files use the per-artifact templates in the skills' `/templates/` directory.

## Folder structure

```
/docs/increments/NNN-<slug>/
  scope.md          # from templates/increment-scope.md
  plan.md           # from templates/increment-plan.md
  step-log.md       # initialized by increment-start
  changelog.md      # written by increment-close
  review.md         # from templates/increment-review.md (technical-reviewer)
```

## Naming

- `NNN` — three-digit zero-padded sequential number, project-wide (not phase-scoped).
- `<slug>` — short kebab-case identifier, derived from the primary in-scope capability or theme.

Examples: `001-user-registration`, `017-billing-receipts`, `042-rate-limiting`.

## Lifecycle

| Phase | Skill | Files produced/touched |
|-------|-------|------------------------|
| Open | `increment-start` | `scope.md`, `step-log.md` (init) |
| Refinement | `business-analyst` | step-log entry; updates to /docs/business/ |
| Specification | `functional-specifier` | step-log entry; updates to /features/, /docs/functional/ |
| Planning | `implementation-planner` | `plan.md`, step-log entry |
| Development | `developer` | step-log entry; code + tests; component doc updates |
| UI Testing | `ui-test-engineer` | step-log entry; UI tests |
| Review | `technical-reviewer` | `review.md`, step-log entry |
| Close | `increment-close` | `changelog.md`, step-log entry; INDEX updates; PR |

## Step log

`step-log.md` is initialized at `increment-start` with this header:

```
# Increment NNN-<slug> — Step Log

> Append-only. Every skill writes a step summary using the template in /skills/_meta/SKILL.md §5.

## Metadata
- Started: YYYY-MM-DD
- Phase: @phase-NN
- Branch: increment/NNN-<slug>
```

Each skill appends its step summary at the end. At `phase-close`, all increment step-logs in the phase are consolidated into `/docs/phases/NN-<slug>/phase-log.md` and the individual step-logs may be archived.

## Deletion / archival

After `phase-close` writes `phase-log.md`, the per-increment `step-log.md` is archived (default) or deleted (if `cleanup_step_logs: true` is set). The other files (`scope.md`, `plan.md`, `changelog.md`, `review.md`) are preserved permanently — they are part of the project's durable record.
