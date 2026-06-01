# Workflow contract (v1.2)

This document is the canonical reference for what the workflow does, how phases and increments are structured, and what the gates mean. Skills implement this contract; if a skill's behavior diverges, the skill is wrong.

## 1. Atomic-but-meaningful

The decomposition principle at every level: a unit (phase, increment, sequencing entry) delivers something stakeholders would describe as shippable or demonstrable in isolation. Units too small merge into siblings; units too large split.

## 2. Lifecycle

```
project-init
  ↓ (raw input for phase 1)
phase-design ──── Gate 1 ───┐
  ↓                         │
increment-design ── Gate 2 ─┤
  ↓                         │
increment-execute           │
  ↓                         │
increment-close ── Gate 3 ──┤ (PR to develop; status: awaiting-merge)
  ↓ [human merges, reviews on staging]
  [optional: fix cycles handled inline by orchestrator while awaiting-merge]
  ↓ [human approves OR session ends without further input]
  next increment or         │
phase-close ──── Gate 4 ────┘ (end of phase)
```

Sessions can pause anywhere. `session-resume` reads INDEX, validates pins, and routes to the correct next skill. When `session-resume` finds an increment in `awaiting-merge` and the human supplies no new input, it assumes approval and advances.

## 3. Phase

A phase delivers a coherent block of capability. Typical scope: a major feature area, a redesign, an integration. Phases produce permanent domain, feature, and architecture artifacts.

Each phase starts with raw input from the human (a brief, a prototype, a problem statement) and ends when its planned increments have shipped to develop, been stabilized, and the phase-close gate has applied any skill or standards improvements surfaced during the phase.

## 4. Increment

An increment delivers value in 4–16 hours of work. It exercises one or more capabilities (defined at the phase level), produces feature files with BDD scenarios, and ships to develop via PR. Increments are sequential within a phase.

Increment sequencing within a phase is by technical dependency first, then risk (risky items earlier), then feature grouping.

## 5. Increment-scope sequencing

`increment-scope.md` enumerates the units of work within the increment — each with slug, objective, scenarios covered, design-spec IDs, dependencies, and estimated size. These are sequencing notes, not separate agent invocations: the develop, test, and review agents each receive the full increment, not individual entries.

The "atomic-but-meaningful" check applies to entries:
- Too small (a rename, a single property) → merge into a sibling
- Too large (multi-feature, multi-screen) → split

## 6. Gates

**Gate 1 — Phase design.** Approves the phase plan, proposed capabilities/aggregates, glossary additions, and proposed phase-level decision records (DRs and ADRs).

**Gate 2 — Increment design.** Approves the increment scope (including sequencing), proposed features/design-specs, increment-level decision records, and the implementation plan.

**Gate 3 — Increment close.** Approves the full-regression result, integrity sweep, and PR contents before merge to develop.

**Gate 4 — Phase close.** Approves consolidated observations synthesis, proposed skill diffs, and standards updates at end of phase.

A gate's prompt and reply contract is in `_meta` §13. The human never edits INDEX directly to record a decision.

## 7. Test cadence

- During `increment-execute`: the develop agent runs new unit tests + relevant existing tests on the increment scope. The test agent runs its newly written integration/UI tests + the smoke set.
- At `increment-close`: full regression on the integration branch.
- During post-merge fix cycles (orchestrator behaviour while `awaiting-merge`): per fix, the develop agent runs the tests touching the changed code paths; CI runs the full suite externally.

The smoke set is tagged `@smoke` on tests that cover capabilities with `data_classification ≥ confidential`, paths tagged `@security-critical`, or critical user flows listed in `testing-standards.md`.

## 8. Test classification

When tests fail, classify per:

- **Spec divergence**: implementation doesn't match the spec the test was written from. Blocks the review or the increment until fixed.
- **Regression**: implementation broke previously-passing behavior. Detected by re-running the same test against the parent commit. Blocks the work.
- **Discovered defect**: a pre-existing defect surfaced by the work. Does not block; logs to `phase-debt.md`.
- **Structural error**: test infrastructure broken. Halts to the technical-design agent.

The orchestrator (not the test agent) performs the parent-commit check — the test agent's manifest isolation forbids it.

## 9. Solidifying and corrective increments

**Solidifying increment — full drain at every phase.** Every phase plans a final increment whose scope is read from `phase-debt.md`. It absorbs discovered defects, flaky tests, refactoring opportunities, and code-level standards observations. The contract: **the phase-debt log is fully drained by the solidifying increment**. There is no rolling balance; every entry receives a disposition.

If `phase-debt.md` is empty at start, the solidifying increment is skipped.

If `phase-debt.md` has entries that fit within one increment's sizing budget (per the project's increment-size convention, typically 4–16 hours of work), all entries are included as `disposition: included` and the increment proceeds.

If the entries exceed what one increment can absorb, the orchestrator at `increment-design` step 2 surfaces a disposition prompt to the human. Per entry, the human chooses one of:

- **include** — absorb into this solidifying increment.
- **defer** — carry forward to the next phase's `phase-debt.md` via the M10 carry-forward mechanism. The entry is moved to `docs/transient/phases/<phase>/carry-forward/deferred-debt.md`.
- **accept** — accept as permanent technical debt; the entry is recorded in `docs/permanent/architecture/accepted-debt.md` (audit trail) and removed from the active log.

Any entry the human doesn't explicitly defer is treated as either `included` or `accepted` per the disposition. **An entry cannot remain `pending` past the solidifying-increment-design step.** This guarantees reasonable drain at every phase.

The solidifying increment's `increment-close` truncates `phase-debt.md` to empty — every entry has been delivered, deferred, or accepted. New debt entries that arise between solidifying-increment-design and phase-close (uncommon, but possible from `increment-close` regression findings on the solidifying increment itself) go directly to `carry-forward/deferred-debt.md`, not back into the truncated log.

**Corrective increment.** Opened when a discovered issue requires re-passing a gate — a missing capability, a wrong ADR, a feature that doesn't work as specified — or when a post-merge fix surfaces scope expansion the human chooses to address now. Rare. Most post-merge issues are fixes (see §10), not corrections.

## 10. Post-merge fix cycles

After `increment-close` opens the PR, the increment is `awaiting-merge`. The human reviews CI and the staging environment after merging. If they request fixes during the ongoing session, the orchestrator recognises the input as a fix request (not approval) and handles it inline without changing status. Per fix:

1. Orchestrator branches `fix/<inc-slug>/<short-slug>` from develop.
2. Invokes `increment-develop` in `mode: fix` with a constrained manifest (the fix description + affected files + relevant tests).
3. Agent makes the change, re-runs relevant tests, returns.
4. Orchestrator pushes, opens PR.
5. Human awaits CI. Pass → validates on staging → approves → merges. Fail → agent reads CI output and applies a follow-up fix; loop in place.

The increment stays `awaiting-merge` throughout. It advances to `closed` when the human signals approval (any message indicating acceptance — "good", "approved", "ship it", "all set", etc.) or when `session-resume` runs without any new input directed at the increment (no input = assumed approval).

**Scope-expansion guard.** If a fix would require new scenarios, touch an accepted artifact, or expand behaviour beyond a bugfix, the dev agent halts with `scope-expansion`. The human routes: absorb into next increment's scope, open a corrective increment now, or override and proceed (logged as a DR).

Fixes update the increment's `progress.md` (audit trail). They don't update accepted artifacts unless they correct an implementation-vs-spec divergence (in which case the implementation is being brought back to the existing spec).

## 11. Discovered defects

A test that fails on adjacent code unrelated to the work — classified as discovered defect per §8 — is logged in `phase-debt.md` for the solidifying increment to absorb. The discovery doesn't block the current work. The discovering agent provides the failing test path, best-effort affected code path, and the git-history evidence the orchestrator collected.

## 12. Append-only with supersession

Once accepted, spec-bearing artifacts (capabilities, aggregates, features, design specs, decision records) change only by supersession. New entry with `supersedes:`, original with `superseded_by:` or `deprecated:`. See `_meta` §8.

## 13. Routing on session resume

`session-resume` reads INDEX and routes:

- No active phase → wait for human raw input → `project-init` or `phase-design`.
- Phase in `design`, gate 1 pending → resume `phase-design`.
- Phase `in-progress`, no active increment → start next increment via `increment-design`.
- Increment in `design`, gate 2 pending → resume `increment-design`.
- Increment `in-progress` → resume `increment-execute` at last position.
- Increment `closing` → resume `increment-close`.
- Increment `awaiting-merge`:
   - If session-resume was triggered with no new human input directed at the increment → assume approval, advance.
   - If the human's input describes a fix → orchestrator handles inline per §10.
   - If the human's input is approval → advance.
   - If CI failed on a prior fix branch and the human is reporting it → orchestrator handles the follow-up fix per §10.
- Phase `closing` → resume `phase-close`.

## 14. Cross-reference invariants

- Every accepted feature references at least one accepted capability.
- Every accepted capability references at least one accepted aggregate (where applicable).
- Every decision record (DR or ADR) is referenced by at least one artifact within a sprint of its acceptance, or it's deprecated.
- Every accepted code change references the increment scope it was built for.

`doc-integrity` validates these at every close gate.

## 15. Branch model

- `main`: stable; production-deployable.
- `develop`: integration; receives increment PRs.
- `inc-<NNN>-<slug>`: increment branch; cut from develop at increment-design, merged at increment-close.
- `fix/<inc-slug>/<short-slug>`: post-merge fix branch; cut from develop, merged before the increment advances to `closed`.

The workflow does not manage `main`. Promotion from develop to main is human-driven and outside the contract.

## 16. Design-system guardrail

`docs/permanent/design/design.md` is the project's design system — the authoritative inventory of design tokens and components, and the **source of truth for UI** (it outranks prototypes). It is human-owned: agents read it, never edit it. The full rule is in `_meta` §17; the contract-level summary:

- UI-bearing work resolves every component and token against `design.md`. A direct match proceeds; an ambiguous or absent match is surfaced to the human via the design-decision prompt at Gate 2 (design time) or, as a backstop, during `increment-execute`.
- For a missing **component**, the human either supplies an updated `design.md` or directs the agent to design it from `design.md`'s guidelines, choosing whether the result is **phase debt** (reconciled by the solidifying increment) or **accepted debt**. For a missing **foundation token**, the choice is human-only — agents never improvise tokens.
- Every divergence from `design.md` is logged in `docs/permanent/design/design-deviations.md`. The fix-vs-accept disposition reuses the existing debt machinery: a `category: design-deviation` entry in `phase-debt.md` (drained by the solidifying increment per §9) or a record in `accepted-debt.md`. `doc-integrity` enforces that design-spec references resolve and that no design-deviation stays `pending` past the drain.
