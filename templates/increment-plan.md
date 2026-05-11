# Increment NNN-<slug> — Implementation Plan

> Produced by `implementation-planner`. Drives `developer`. The `Developer Context Manifest` section below is the **complete list** of docs the developer may load — no more.

## Summary

One paragraph: what's being built this increment, and how at a high level.

## Components affected

| Component | Change type | Notes |
|-----------|-------------|-------|
| <component> | modified | adding endpoint X |
| <component> | new | per ADR-TBD-NNNN |

## ADRs to honor

Accepted ADRs that constrain this implementation.

- ADR-NNNN: [title] — relevant because ...
- ...

## ADRs proposed

New ADRs introduced by this plan. Each in `proposed` status until increment-close.

- ADR-TBD-<slug>: [title]
  - **Plain-language summary:** one paragraph the human reads at Gate 4.
  - **Link:** [draft]
- ...

## Task list

Sequenced tasks. Each task names target files and the scenario(s) it satisfies.

1. **[Task name]**
   - Files: `/src/...`, `/tests/unit/...`
   - Scenarios satisfied: [link to feature file scenarios]
   - Notes:
2. **[Task name]**
   - ...

## Test plan

- **Unit tests:** approach per task.
- **UI tests:** scenarios `@inc-NNN` covered by `ui-test-engineer` post-development.
- **Coverage strategy:** how the 80% target is met. Note any justified exemptions.

## Risks

- Risk 1: ...
- Risk 2: ...

## Developer Context Manifest

> The developer may load **only** the following docs. Anything else needed → halt and surface.

- `/docs/increments/NNN-<slug>/plan.md` (this doc)
- `/docs/technical/architecture/components/<component>.md` (for each affected component)
- `/docs/technical/architecture/ADR-NNNN-*.md` (for each ADR to honor)
- `/docs/technical/architecture/ADR-TBD-<slug>.md` (for each proposed ADR)
- `/docs/business/domain/<context>/<aggregate>.md` (for each aggregate touched)
- (any other doc explicitly needed)

Plus always-allowed:

- `/docs/technical/guidelines/coding-standards.md`
- `/docs/technical/guidelines/testing-standards.md`
- `/docs/technical/guidelines/naming-conventions.md`
