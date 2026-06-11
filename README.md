# claude-dotfiles — agentic-SDLC workflow v1.3

Personal dotfiles hosting the skills, subagents, and templates that drive the **agentic-SDLC workflow v1.3** in Claude Code.

v1.3 is a minor, additive update over v1.2: it adds the **security baseline guardrail**. Two project-level docs become permanent, always-allowed references that every skill and agent reads and works against at every step: `docs/owasp-guidelines.md` (a verbatim copy of the OWASP Secure Coding Practices Quick Reference Guide — a vendored upstream standard, not project-edited) and `docs/security-guidelines.md` (the project's own custom security layer plus a baseline-overrides table, human-owned, shipped as an empty scaffold). The baseline is mandatory, not optional: the design agents derive security requirements and abuse cases from it, `increment-develop` implements against it, `increment-test` derives abuse-case tests from it, and `increment-review` runs a mandatory security pass where an un-overridden violation blocks the increment. A baseline item is relaxed only by a recorded, ADR-backed override. This is the security analogue of the v1.2 design-system guardrail. No lifecycle, gate, or schema change. See `migration-v1.2-to-v1.3.md`.

v1.2 is a minor, additive update over v1.1: it adds the **design-system guardrail**. A project-level `docs/permanent/design/design.md` (the design system — design tokens + component inventory) becomes a permanent, always-allowed, human-owned source of truth for UI. When UI work needs a component or token with no match in `design.md`, the gap is surfaced to the human (at Gate 2, with an execute-time backstop) for disposition — supply an updated `design.md`, or design the component from guidelines and class it as phase debt or accepted debt — and every divergence is logged in `design-deviations.md`. The fix-vs-accept choice reuses the existing solidifying-increment and accepted-debt machinery. No lifecycle, gate, or schema change. See `migration-v1.1-to-v1.2.md`.

v1.1 was a leanness pass over v1.0: the develop / test / review loop runs once per increment (not once per backlog item), the four decision-record types collapse to two (DR and ADR), the transient → proposed → permanent file-move staging is replaced by status-in-place, and several skills consolidated. The dev / test agent split — the workflow's core quality lever — is preserved.

## What's in here

```
.dotfiles/
├── skills/                      → 12 orchestration + utility skills + _meta
│   ├── _meta/                   cross-cutting rules every skill inherits
│   ├── session-resume/          canonical session entry point
│   ├── project-init/            bootstrap a new project
│   ├── project-pause/           clean-handoff pause
│   ├── phase-design/            phase analytical + planning pass (Gate 1)
│   ├── phase-close/             phase consolidation + retrospective + improvement (Gate 4)
│   ├── increment-design/        increment analytical + planning pass (Gate 2)
│   ├── increment-execute/       develop → test → review loop at increment scope
│   ├── increment-close/         regression + integrity + PR + post-merge fix handling (Gate 3)
│   ├── feedback-triage/         utility — dispositions on feedback-inbox entries
│   ├── doc-integrity/           utility — reference / supersession / status validation; subtree-INDEX regeneration
│   └── workflow-curator/        utility — synthesizes observations into proposed skill / standards diffs
│
├── agents/                      → 5 subagent definitions
│   ├── domain-design.md         (BA + FA in one; mode-parameterised)
│   ├── technical-design.md      (TA + TL in one; mode-parameterised)
│   ├── increment-develop.md     (develop, with mode: increment | fix)
│   ├── increment-test.md        (test from spec; isolation forbidden-reads section)
│   └── increment-review.md      (review at increment scope; 3-cycle budget)
│
├── templates/                   → doc templates the skills consume
│   ├── INDEX.md                 project state record
│   ├── workflow.md              project-level workflow contract (project-init writes to root)
│   ├── agentic-sdlc-principles.md  (project-init writes to root)
│   ├── doc-structure.md         (project-init writes to root)
│   ├── owasp-guidelines.md      (verbatim OWASP secure-coding baseline; project-init writes to root; always-allowed; not project-edited)
│   ├── security-guidelines.md   (project's custom security layer + baseline overrides; project-init writes empty scaffold to root; human-owned; always-allowed)
│   ├── capability.md
│   ├── aggregate.md
│   ├── feature.md
│   ├── design-spec.md
│   ├── design.md                (placeholder design system — tokens + components; human-owned; always-allowed)
│   ├── design-deviations.md     (append-only log of divergences from design.md)
│   ├── flow.md
│   ├── decision-record.md       (DR + ADR shared spec, two-type)
│   ├── increment-scope.md       (includes implementation plan + sequencing)
│   ├── phase-plan.md
│   ├── phase-debt.md
│   ├── feedback-inbox.md
│   ├── observations.md
│   ├── subtree-INDEX.md         (derived; regenerated by doc-integrity)
│   ├── minor-templates.md       (editorial-log, pause-record, progress.md, defect-discovered, status-line patterns)
│   ├── coding-standards.md      (placeholder; project-init writes; first phase populates)
│   ├── testing-standards.md     (placeholder; project-init writes)
│   ├── naming-conventions.md    (placeholder; includes tag vocabulary)
│   ├── glossary.md              (placeholder)
│   ├── domain-model.md          (placeholder for cross-context invariants — always-allowed read)
│   └── accepted-debt.md         (permanent record of debt the team consciously accepted)
│
├── README.md                    this file
├── claude.md                    (empty placeholder)
├── install-claude.ps1           Windows symlink installer
└── install-claude.sh            macOS / Linux symlink installer
```

## How to use it

### One-time setup (a new machine)

1. **Clone this repo to `~/.dotfiles`.**

   Windows (PowerShell):
   ```
   git clone https://github.com/rubinbeckers/claude-dotfiles.git $env:USERPROFILE\.dotfiles
   ```

   macOS / Linux:
   ```
   git clone https://github.com/rubinbeckers/claude-dotfiles.git ~/.dotfiles
   ```

2. **Install the symlinks.**

   Windows (PowerShell, with Developer Mode enabled or PowerShell run as Administrator):
   ```
   & $env:USERPROFILE\.dotfiles\install-claude.ps1
   ```

   macOS / Linux:
   ```
   bash ~/.dotfiles/install-claude.sh
   ```

   Either script creates:
   - `~/.claude/commands/<skill>.md` → symlink to `~/.dotfiles/skills/<skill>/SKILL.md` (12 entries)
   - `~/.claude/agents/<agent>.md` → symlink to `~/.dotfiles/agents/<agent>.md` (5 entries)

   Symlinks point at the live files in this repo. `git pull` propagates without re-running the installer. Re-run when skills or agents are added / removed / renamed.

3. **Verify access.** When you run `session-resume` in a project, the orchestrator validates `skill-versions.lock` against the dotfiles tag (default: `workflow-v1.3`).

### Starting a new project

In a new repo with no `docs/INDEX.md`:

1. In Claude Code, open the project. The harness auto-loads the workflow on session start.
2. Invoke `project-init`. It scaffolds everything under `docs/`: `workflow.md`, `agentic-sdlc-principles.md`, `doc-structure.md`, `INDEX.md`, `skill-versions.lock`, the `permanent/` and `transient/` trees, placeholder standards docs, and a placeholder `design/design.md` + empty `design/design-deviations.md`. The project root holds project code, not workflow artifacts. Replace the placeholder `design.md` with your real design system before UI work begins.
3. Provide raw input for the first phase. `project-init` routes to `phase-design`.

### Resuming work

Any subsequent session, anywhere in the lifecycle: type *"resume"* or *"continue"* or any opening that isn't a fresh project bootstrap.

`session-resume` reads `docs/INDEX.md`, validates pins, scans git on the operating branch, parses your opening message, and routes to the correct next skill.

**Post-merge fix handling.** After `increment-close` opens the PR and you merge it, the increment is `awaiting-merge`. If you ask for fixes in the ongoing session, the orchestrator creates a `fix/<inc-slug>/<short-slug>` branch and runs `increment-develop` in `mode: fix`. If you signal approval (or run session-resume with no further input), the increment advances to `closed`.

## Branch model

| Branch / tag                        | What it is                                                                                                |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `main`                              | Stable; production-deployable. Workflow does not manage `main`.                                          |
| `develop`                           | Integration; receives increment PRs.                                                                     |
| `inc-<NNN>-<slug>`                  | Increment branch; cut from develop at increment-design, merged at increment-close.                       |
| `fix/<inc-slug>/<short>`            | Post-merge fix branch; cut from develop, merged before the increment advances to `closed`.               |
| tag `workflow-v1.3`                 | Stable pin target. `docs/skill-versions.lock` in projects references this tag.                           |

## Migrating from v1.0

If you have a project running v1.0:

1. **Pin the project to its current v1.0 dotfiles tag** before installing v1.1.
2. Finish the current phase under v1.0 (avoid mid-phase migration).
3. At phase-close, switch the project's `docs/skill-versions.lock` pin to `workflow-v1.1` (or use the migration prompt at `migration-v1.0-to-v1.1.md` for a one-shot migration).
4. The first session under v1.1 will run `session-resume`'s pin check; it will detect the migration, halt, and prompt for override or rollback. Choose override; record a DR documenting the migration.
5. The lifecycle states and INDEX schema are compatible — v1.1 reads v1.0's INDEX. Existing artifacts under `docs/permanent/...` keep their statuses. The `docs/transient/.../proposed/` subdirectories from v1.0 are no longer used; their content (if any) was either promoted or pruned at the prior phase's close, so they should be empty.
6. Existing CDR / DDR / FDR records keep their IDs but get re-classified as DR. ADRs unchanged.

A migration helper isn't currently part of the workflow; the steps above are manual but tractable.

## Migrating from v1.1

v1.2 is additive. At a phase boundary, drop `design.md` (your design system, or the placeholder) and an empty `design-deviations.md` into `docs/permanent/design/`, switch the pin to `workflow-v1.2`, override the pin check (record a DR), and continue. No data migration. Full steps: `migration-v1.1-to-v1.2.md`.

## Migrating from v1.2

v1.3 is additive. At a phase boundary, drop `owasp-guidelines.md` (verbatim, from `templates/`) and a populated-or-scaffold `security-guidelines.md` into `docs/`, switch the pin to `workflow-v1.3`, override the pin check (record a DR), and continue. No data migration; the baseline applies to changed surfaces from the next increment forward. Full steps: `migration-v1.2-to-v1.3.md`.

## References

- The v1.3 workflow contract: `docs/workflow.md` (at any v1.3-using project; incl. §17 security baseline)
- The principles this workflow instantiates: `docs/agentic-sdlc-principles.md` (incl. §11 security is a baseline)
- Documentation layout: `docs/doc-structure.md`
- Cross-cutting skill rules (incl. §17 design-system guardrail and §18 security baseline): `skills/_meta/SKILL.md` (in the dotfiles)
- The security baseline (source of truth for security): `docs/owasp-guidelines.md` (verbatim OWASP, not project-edited) + `docs/security-guidelines.md` (project's custom layer; human-owned). Mandatory reading for every skill and agent.
- The design system (source of truth for UI): `docs/permanent/design/design.md`
- Migration from v1.1: `migration-v1.1-to-v1.2.md`; from v1.0: `migration-v1.0-to-v1.1.md` (in the dotfiles)
