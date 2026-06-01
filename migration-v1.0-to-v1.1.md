# Migration: agentic-SDLC workflow v1.0 → v1.1

**For the executing agent.** This file is an instruction set. The user attaches it to a prompt like *"Migrate this project to v1.1 per the attached instructions"* — execute the steps in order, halt and surface to the human at any branching decision, and produce a single git commit at the end. The user has already updated their dotfiles to the v1.1 tag; your job is the in-project transformation.

You are operating in the user's project repository, not the dotfiles repository. The dotfiles are pinned externally; you should not modify them.

## 0. Pre-flight

Confirm the following before doing anything else. Halt and surface if any fail.

- The repo's working tree is clean (or only contains workflow-related changes). Run `git status` — if there are uncommitted application code changes, halt and ask the human to commit or stash them first.
- The repo is on the `develop` branch (or the project's `operating_branch` per its INDEX). If on an increment or fix branch, halt.
- The current `skill-versions.lock` references a v1.0 dotfiles tag. If it already references `workflow-v1.1`, the migration is already done — halt and confirm with the human.
- The dotfiles installation has been updated to the v1.1 tag (the user runs the installer separately). Verify by checking that `~/.claude/agents/domain-design.md` exists and `~/.claude/agents/phase-business-analysis.md` does NOT. If both are present, the dotfiles weren't updated cleanly — halt.

Create a migration branch: `git checkout -b migration-v1.0-to-v1.1`. All changes go here; the human merges to develop when satisfied.

## 1. Determine project state and solidifying-increment disposition

Read `INDEX.md` (still at project root for now). Note:
- Active phase and its status.
- Active increment (if any) and its status.

**Branching on solidifying-increment state.** The user has indicated the only remaining increment in the active phase is a solidifying increment. Determine its state from INDEX:

| Solidifying increment state | Decision | Action |
|---|---|---|
| Not yet started — listed in phase plan but no active increment row | Safe to migrate now | Proceed with all steps below. v1.1's `increment-design` will read the migrated `phase-debt.md` and run the drain disposition. |
| `design` state — increment-start ran but Gate 2 not yet passed | Safe to migrate now | Proceed. The proposed artifacts under `docs/transient/.../proposed/` (if any) will be relocated per step 6. v1.1's `increment-design` will resume from a fresh design pass since v1.0's planning artifacts will be migrated. |
| `in-progress` — backlog loop running, some items delivered | **Halt — finish under v1.0.** | Surface this to the human. Recommend: complete the solidifying increment under v1.0 (the running v1.0 skills will execute it), close the phase under v1.0, then re-run this migration on the fresh state. Mid-flight migration would require mapping in-flight backlog-item state to v1.1's increment-execute cycle state — that's possible but error-prone and not worth the risk for the last increment of a phase. |
| `closing` — increment-close running, PR not yet opened | **Halt — finish under v1.0.** | Same reasoning. Complete the close, merge, then migrate. |
| `awaiting-merge` — PR open or merged but not finalised | **Halt — finish under v1.0.** | Resolve the merge/stabilisation under v1.0 (no separate stabilisation skill in v1.0, but the human will know what's needed), then migrate at phase boundary. |
| `closed` (the phase-debt log is empty and solidifying was skipped, or already delivered) | Safe to migrate now | Proceed. The phase may be ready for phase-close — let v1.1's `phase-close` handle the close after migration. |

Once the decision is made and you have the green light to proceed, surface a one-line summary:

```
Proceeding with migration. Active phase: <slug>, status: <status>. Solidifying-increment disposition: <one-line>.
```

## 2. Relocate root-level files to docs/

The v1.1 contract places everything workflow-managed under `docs/`. Move:

```bash
mkdir -p docs
git mv workflow.md docs/workflow.md
git mv agentic-sdlc-principles.md docs/agentic-sdlc-principles.md
git mv doc-structure.md docs/doc-structure.md
git mv INDEX.md docs/INDEX.md
git mv skill-versions.lock docs/skill-versions.lock
```

If any of these don't exist at root, check whether they're already under `docs/` (some projects may have started there). If they're under `docs/` already, skip the move for that file.

Use `git mv` (not `mv`) so the rename is tracked.

## 3. Replace contract docs with v1.1 versions

The v1.0 `workflow.md`, `agentic-sdlc-principles.md`, and `doc-structure.md` describe the old contract; they must be replaced with the v1.1 versions from the dotfiles. Locate the v1.1 templates in `~/.dotfiles/templates/` (or `~/.dotfiles/templates/`):

```bash
cp ~/.dotfiles/templates/workflow.md docs/workflow.md
cp ~/.dotfiles/templates/agentic-sdlc-principles.md docs/agentic-sdlc-principles.md
cp ~/.dotfiles/templates/doc-structure.md docs/doc-structure.md
```

These overwrites are intentional — the contract has changed. The git diff will be substantial; that's expected.

## 4. Update `docs/skill-versions.lock`

Open `docs/skill-versions.lock`. Update the pinned tag to `workflow-v1.1`. Record an override note (the human will accept this as a DR after migration):

```
dotfiles_tag: workflow-v1.1
migrated_from: workflow-v1.0
migrated_at: <ISO timestamp>
override_reason: workflow upgrade — see DR to be authored post-migration
```

## 5. Update `docs/INDEX.md`

Apply the v1.1 INDEX schema additions. For each increment in each phase entry, add (if absent):
- `fix_branches_merged: []`
- `cycle_extensions_granted: 0`

At the top level of INDEX, add (if absent):
- `transient_pruning_eligible: []`
- `pending_skill_diffs: []`
- `dotfiles_tag: workflow-v1.1`

Preserve all existing fields and values. Don't renumber phases or increments.

## 6. Collapse `transient/.../proposed/` staging

In v1.0, in-flight artifacts lived under `docs/transient/phases/<phase>/proposed/...` (and similar under increments) until Gate approval promoted them to `docs/permanent/...` via file move. In v1.1, artifacts are born under `docs/permanent/...` with `status: proposed` and the status flips in place at gates.

For each `proposed/` directory under `docs/transient/`:

1. List its contents (capabilities, aggregates, features, design-specs, decision-records subtrees).
2. For each file:
   - **If the active phase is in design state and this artifact is in flight (status: proposed)**: move it to its canonical `docs/permanent/...` location, keeping `status: proposed`. Update internal references.
   - **If the artifact's gate already passed in v1.0** (which means it was already moved to `docs/permanent/...` by v1.0's promotion step): there should be nothing left in `proposed/` for it; if there is, it's stale — surface it and ask the human to decide whether to drop or promote.
3. Remove the now-empty `proposed/` directory.

The user's project likely has empty `proposed/` directories from the prior phases (already promoted at their gates). Just remove those — they're vestigial.

## 7. Convert decision records: CDR / DDR / FDR → DR

In v1.0, four record types lived in separate subdirectories under `docs/permanent/decision-records/`: `CDR/`, `DDR/`, `FDR/`, `ADR/`. In v1.1, the first three collapse into `DR/`; `ADR/` is unchanged.

**Approach: renumber sequentially with prior-id traceability.**

1. Collect every file under `docs/permanent/decision-records/CDR/`, `DDR/`, and `FDR/`. Read each one's frontmatter; note `id`, `accepted_at_gate` (or `introduced_in` if no gate timestamp), `status`, `slug`.
2. Sort by acceptance order (use `accepted_at_gate` timestamp if present, falling back to `introduced_in` phase number + a stable per-phase order).
3. Assign new IDs sequentially: `DR-001-<slug>`, `DR-002-<slug>`, etc. Preserve the slug — slugs are unique within v1.0's per-type namespaces and almost always unique across all three; if you find a slug collision (same slug across CDR/DDR/FDR), append a disambiguator to one and surface it.
4. For each record:
   - Add to frontmatter: `prior_id: <old-id>` and `prior_type: CDR | DDR | FDR`.
   - Change `type:` to `DR`.
   - Update the `id:` field to the new `DR-NNN-<slug>`.
   - If `summary:` field is absent, add it with the first line of the `## Description` or `## Decision` section, truncated to 120 chars.
   - Update `superseded_by:` and `supersedes:` cross-references to the new DR IDs.
5. Move the file from `docs/permanent/decision-records/CDR/` (or DDR/, FDR/) to `docs/permanent/decision-records/DR/`.
6. Use `git mv` for the moves so renames are tracked.
7. After all moves, remove the empty `CDR/`, `DDR/`, `FDR/` directories.

**Cross-reference update.** With the new IDs assigned, do a project-wide search for the old IDs in artifact bodies and `Grounded in:` declarations. Replace each old ID reference with the new DR ID. Use grep across `docs/` for `CDR-`, `DDR-`, `FDR-` patterns. Skip references in archived phase content (`docs/transient/archive/...`) — those preserve historical state and should not be rewritten.

For `ADR/`: no changes. ADRs keep their IDs.

## 8. Add `summary:` fields to existing artifacts

For each accepted artifact missing a `summary:` frontmatter field, add one:

- `docs/permanent/domain/capabilities/*.md`
- `docs/permanent/domain/aggregates/*.md`
- `docs/permanent/features/*.md`
- `docs/permanent/features/design-specs/*.md`
- `docs/permanent/flows/*.md`
- `docs/permanent/decision-records/DR/*.md`
- `docs/permanent/decision-records/ADR/*.md`

If `summary:` is absent, derive a one-line summary (≤120 chars) from the artifact's `## Description` section (or `## Decision` for decision records). Use the first sentence, truncated as needed. If you can't infer one, leave it as an empty string `summary: ""` and surface the list for the human to fill in later — don't fabricate.

## 9. Convert backlog-item files into increment-scope sequencing

In v1.0, each increment had `backlog/<NNN>-<slug>.md` files for each work unit. In v1.1, these are absorbed into a `## Sequencing` section in `increment-scope.md`.

For each increment under `docs/transient/phases/<active-phase>/increments/<inc>/`:

1. Read `increment-scope.md` (v1.0 version).
2. Read every file under `backlog/` for that increment.
3. Append a `## Sequencing` section to `increment-scope.md` with one entry per backlog item, per the v1.1 `increment-scope.md` template format:
   ```
   ### NNN-<slug>
   - objective: <one-line from the backlog item's Objective>
   - scenarios: [<BDD scenario references>]
   - design-spec-ids: [<DS-IDs>]
   - files: [<files to create/modify from Implementation plan>]
   - approach: <prose from Implementation plan, ≤200 words>
   - cross-references: [<ADR slugs from backlog item>]
   - cross-cutting: [<concerns>]
   - depends: [<other sequencing slugs>]
   - size: S | M | L
   ```
4. Also append the `## Implementation plan` section, summarising the per-feature considerations from `technical-analysis.md` (if not already there).
5. Move the original `backlog/` directory to `docs/transient/archive/migration-v1.0/phases/<phase>/increments/<inc>/backlog/` for audit. Use `git mv`.

For closed prior increments under the active phase, do the same — but the conversion is purely archival. Reading them later is rare; the audit trail in archive preserves the original.

For increments in prior closed phases (under `docs/transient/archive/<phase>/...`): leave them untouched. Historical state is preserved as-is.

## 10. Update `phase-debt.md` to v1.1 schema

Read the active phase's `docs/transient/phases/<phase>/phase-debt.md`. For each entry:

1. Add `disposition: pending` if absent.
2. Add `size: M` if absent (default; the human can override at the drain step).
3. Add `dispositioned_at: null` and `dispositioned_by: null`.

The v1.1 `increment-design` step 2 will run the drain disposition on the next solidifying increment, so this prepares the log for that.

If `standards-observations.md` or `workflow-observations.md` exist as legacy logs in the active phase, merge their content into `observations.md` (they were deprecated in v1.0; this is the cleanup). Delete the legacy logs after merge.

## 11. Create new v1.1 files

If absent:

- `docs/permanent/architecture/accepted-debt.md` — copy from `~/.dotfiles/templates/accepted-debt.md`, strip the template's explanatory prose, leave just the header and an empty `## Entries` section.
- `docs/permanent/domain/domain-model.md` — if it doesn't exist, copy from `~/.dotfiles/templates/domain-model.md` with placeholder body. If it exists but uses v1.0 schema (no invariant IDs), update each invariant entry to carry an `inv-NNN-<slug>` ID, status field, and `Grounded in:` declaration. If you can't reconstruct grounding from existing content, leave the field empty and surface for human fill-in.

## 12. Regenerate subtree indexes

For each indexed subtree (per `doc-structure.md` §11), regenerate `subtree-INDEX.md` by globbing the directory, reading each file's frontmatter, and writing the index per the template format. The relevant subtrees:

- `docs/permanent/domain/capabilities/`
- `docs/permanent/domain/aggregates/`
- `docs/permanent/features/`
- `docs/permanent/features/design-specs/`
- `docs/permanent/flows/`
- `docs/permanent/decision-records/DR/`
- `docs/permanent/decision-records/ADR/`

This bootstraps the indexes so `doc-integrity` doesn't have to do a cold regeneration at the next gate.

## 13. Delete v1.0 remnants

Remove the following if present:

- Any `docs/transient/phases/<phase>/proposed/` directories (now empty).
- Any `docs/permanent/decision-records/CDR/`, `DDR/`, `FDR/` directories (now empty after moves).
- Any reference in `INDEX.md` or other artifacts to v1.0-only concepts: `phase-start`, `phase-planning`, `phase-retrospective`, `improvement-review`, `increment-start`, `increment-planning`, `backlog-loop`, `doc-consolidator`. Rewrite citations to the v1.1 equivalents:
  - `phase-start` / `phase-planning` → `phase-design`
  - `phase-retrospective` / `improvement-review` → `phase-close`
  - `increment-start` / `increment-planning` → `increment-design`
  - `backlog-loop` → `increment-execute`
  - `doc-consolidator` → (no replacement; the step is gone)
- Any reference to v1.0 agents: `phase-business-analysis`, `phase-technical-architecture`, `increment-functional-analysis`, `increment-technical-analysis`, `backlog-develop`, `backlog-test`, `backlog-review`. Rewrite:
  - `phase-business-analysis` / `increment-functional-analysis` → `domain-design`
  - `phase-technical-architecture` / `increment-technical-analysis` → `technical-design`
  - `backlog-develop` → `increment-develop`
  - `backlog-test` → `increment-test`
  - `backlog-review` → `increment-review`
- Any reference to `feeds-into:` declarations on transient docs (the field is no longer used in v1.1). Strip them but keep the surrounding content.

Use grep across `docs/` to find these. Skip references in `docs/transient/archive/...` — historical content is preserved.

## 14. Author the migration DR

Write `docs/permanent/decision-records/DR/DR-<NNN>-workflow-migration-v1.0-to-v1.1.md` (use the next sequential DR number). Frontmatter:

```yaml
---
id: DR-<NNN>-workflow-migration-v1.0-to-v1.1
type: DR
title: Migrate from agentic-SDLC v1.0 to v1.1
summary: Project upgrade to workflow v1.1 — consolidated skills/agents, born-permanent docs, drain protocol.
status: accepted
authored_by: human
introduced_in: <active-phase-slug>
accepted_at_gate: pin-override@<ISO timestamp>
---
```

Body:

```markdown
# DR: Migrate from agentic-SDLC v1.0 to v1.1

Grounded in:
  - docs/agentic-sdlc-principles.md (rationale for the change)
  - prior phase outputs (preserved under docs/transient/archive/)

## Context

The project ran under workflow v1.0 from <first phase> through <active phase>. v1.0's per-backlog-item agent invocation, four decision-record types, and transient → proposed → permanent file-move staging accumulated overhead disproportionate to value. v1.1 consolidates these — see `agentic-sdlc-principles.md` and the v1.1 README's "Migrating from v1.0" section.

## Decision

Migrate the project to v1.1 effective <ISO timestamp>. All v1.0 artifacts retained; conversion of decision records (CDR/DDR/FDR → DR) preserves prior IDs via `prior_id:` field. The active phase continues under v1.1 from this point.

## Alternatives considered

- Finishing the current phase under v1.0 and migrating at the next phase boundary: rejected — the only remaining increment is a solidifying increment which is cheaper to run under v1.1's increment-level loop.
- Staying on v1.0: rejected — v1.1's leanness benefits compound over time.

## Consequences

### Positive
- Phase-debt drain protocol prevents accumulation across phases.
- Single develop / test / review pass per increment instead of per item.
- `docs/`-only project layout — cleaner separation from project code.

### Negative / trade-offs
- One-time migration cost (this commit).
- v1.0 archive content uses different ID conventions; `doc-integrity` skips it.
```

## 15. Commit and verify

```bash
git add .
git commit -m "chore: migrate workflow v1.0 → v1.1

Workflow contract upgraded per ~/.dotfiles/migration-v1.0-to-v1.1.md.
- All workflow files moved under docs/.
- CDR/DDR/FDR consolidated into DR.
- backlog-item files folded into increment-scope sequencing.
- proposed/ staging removed; artifacts born permanent with status.
- Added summary fields, accepted-debt.md, domain-model.md schema.
- Migration DR: DR-<NNN>-workflow-migration-v1.0-to-v1.1.

See DR-<NNN> for rationale."
```

Run `session-resume` (or just say "resume" to the next session). It will:
1. Validate the v1.1 pin in `docs/skill-versions.lock`.
2. Run the new TBD-aging scan (should be clean).
3. Apply any staged skill diffs (none expected at this point).
4. Route per the current INDEX state.

If `session-resume` routes to the solidifying increment's `increment-design`, the v1.1 drain disposition will run on the migrated `phase-debt.md`. If the log was small enough, all entries are included by default. If it overflows, you'll get the per-entry disposition prompt.

If anything in the v1.1 contract halts (e.g., a `doc-integrity` finding from the migration), surface to the human; do not attempt to auto-fix structural issues.

## 16. Rollback

If anything goes seriously wrong:

```bash
git checkout develop
git branch -D migration-v1.0-to-v1.1
# Restore the v1.0 dotfiles tag in skill-versions.lock and re-run the v1.0 installer.
```

The migration branch is the only place changes were made; develop is untouched.

---

End of migration instructions. When complete, surface to the human:

```
═══════════════════════════════════════════════
Migration complete. Branch: migration-v1.0-to-v1.1.

Changes:
  - <N> files moved to docs/
  - <N> CDR/DDR/FDR records consolidated into DR/
  - <N> backlog-item files folded into increment-scope sequencing
  - phase-debt.md updated to v1.1 schema (<N> entries pending drain)
  - accepted-debt.md, domain-model.md schema initialised
  - Migration DR: DR-<NNN>-workflow-migration-v1.0-to-v1.1

Next: review the diff, merge migration-v1.0-to-v1.1 into develop, then run session-resume.
═══════════════════════════════════════════════
```
