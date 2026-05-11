# Increment NNN: <slug>

**Status:** in-progress | delivered | abandoned | superseded-by-increment: inc-MMM
**Tags:** `@inc-NNN` `@phase-NN` `<others>`
**Started:** YYYY-MM-DD
**code-changes:** yes | none
**@corrects:** inc-NNN *(if this is a corrective increment; otherwise omit)*
**@depends:** inc-NNN, inc-MMM *(declared dependencies on prior delivered increments)*

## Summary

One-paragraph description of what this increment delivers.

## In scope

### Capabilities

- `/docs/business/capabilities/<name>.md` — slice: <description>
  - AC: AC-1, AC-2 *(specific AC IDs from the capability spec; the slice may not cover all ACs)*
- *(repeat per capability in scope)*

### Scenarios

- `/features/<capability>.feature` — `@<scenario-tag>` for the in-scope scenarios in this increment.

### Components affected

*(Filled in by `implementation-planner`; left empty at scope-draft time.)*

- <component-name> — <touch type: new | modified | deprecated>

## Out of scope (explicit)

- <item>
- <item>

These are surfaced now so they don't drift in during refinement / planning / development.

## Acceptance for this increment

A short list of what "done" looks like for this increment specifically. This is increment-level acceptance, narrower than capability-level AC. Should be testable.

- <criterion>
- <criterion>

## Corrective context

*(Required when `@corrects:` is set.)*

- **Defect being corrected:** <one-line description>
- **CDR/ADR documenting the defect:** <path to record>
- **Artifacts being superseded:** <list of paths — each will receive `superseded-by-increment: inc-<this>` at close>

## Doc-only mode

*(Required when `code-changes: none`.)*

- **Doc artifacts touched:** <list>
- **Why doc-only:** <e.g., "ADR-0012 supersession; no code changes needed">

The orchestrator routes doc-only increments as `increment-start` → doc-authoring skill(s) → `technical-reviewer` (doc-review mode) → `increment-close`. `developer` and `ui-test-engineer` are skipped.

## References

- Phase: `/docs/phases/NN-<slug>/roadmap.md`
- Step log: `step-log.md` (this folder)
