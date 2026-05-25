---
name: project-init
description: Bootstrap a new project. Use exactly once per project when there is no INDEX.md, no docs/ structure, and no skill-versions.lock. Invoked by session-resume when it detects an uninitialized project, or directly by the human at first session.
---

# project-init

One-time project bootstrap. Creates the directory structure, the initial permanent-doc stubs, the INDEX, the skill-versions lockfile, and the git scaffolding for the develop-branch model.

Runs as an orchestration skill in the main chat. Does not delegate.

## Inputs

Inherits the always-allowed set (`_meta` §1). Project-init also reads:
- `workflow.md` (already loaded by `session-resume`)
- The skills repo (to enumerate available skill and template versions for pinning)
- Whatever raw input the human provides about the project (name, brief description, tech preferences)

## Outputs

- `INDEX.md` — initial state, no active phase
- `skill-versions.lock` — pins for all skills and templates
- `docs/permanent/` directory tree with stub files
- `docs/transient/` directory (empty)
- Git scaffolding: `develop` branch created and checked out
- `README.md` (project-level, brief — not workflow documentation)
- `CONTRIBUTING.md` reference to workflow.md

## Steps

### Step 1 — Verify pre-conditions

- No `INDEX.md` exists. If one does, halt with `T-PI-1` (project already initialized).
- The current working directory is a git repository or can be initialized as one.
- The skills repo (dotfiles or local) is reachable; `workflow.md` §14.1 dotfiles symlink is in place if used.

### Step 2 — Gather project metadata from human

Ask the human (via the chat, not AskUserQuestion — this is a setup conversation):
- Project name (slug)
- One-line project description
- Primary technology stack hint (used for initial coding-standards.md stub, but full TA work happens at phase-1)
- Whether a dotfiles-symlinked skills repo is in use; if yes, the dotfiles repo path

Record answers in a temporary `project-init-input.md` to ground subsequent stubs.

### Step 3 — Initialize git

- `git init` if not already a repo.
- Create and check out `develop` branch.
- Verify `main` exists (or create from empty); the workflow will never write to `main`.
- Per `workflow.md` §17: confirm with human that direct-to-main commits will be human-only.

### Step 4 — Create directory structure

Create the canonical layout (full mapping in `doc-structure.md`):

```
docs/
  permanent/
    domain/
      domain-model.md             (stub, with empty "Cross-context invariants" section per workflow.md §15.7)
      glossary.md                 (stub)
      capabilities/
        INDEX.md                  (empty subtree INDEX per workflow.md §15.8)
      aggregates/
        INDEX.md                  (empty)
    architecture/
      architecture.md             (stub)
      database-model.md           (stub)
      tech-stack.md               (stub)
      ci-pipeline.md              (stub)
      coding-standards.md         (stub, seeded by tech-stack hint)
      testing-standards.md        (stub)
      naming-conventions.md       (stub)
      components/
        INDEX.md                  (empty)
    features/
      INDEX.md                    (empty)
      design-specs/               (empty)
    flows/
      INDEX.md                    (empty)
    design/
      prototype/                  (empty)
      design-language/            (empty; optional)
    ops/                          (empty; populated as project approaches production)
    process/
      tag-vocabulary.md           (seeded with the standard categories from templates/tag-vocabulary.md)
    decision-records/
      CDR/
        INDEX.md                  (empty)
      DDR/
        INDEX.md                  (empty)
      FDR/
        INDEX.md                  (empty)
      ADR/
        INDEX.md                  (empty)
  transient/
    phases/                       (empty)
```

Every stub file declares its owner role (from `workflow.md` §2) and a "first authoring expected at: phase-1" header. Empty INDEX entries are seeded.

Three architecture stubs are seeded with substantive content (not just placeholders) because they encode discipline the workflow enforces:

**`testing-standards.md` seed** must include:

- *Hermeticity requirement.* Every test owns its own data: creates fixtures it needs, asserts, tears down. No test depends on pre-existing data, on the order of test execution, or on side effects of other tests. Tests must run in parallel and in any order. The *property* is what's required; the *mechanism* may be inline (each test does its own setup/teardown) or centralized (a project-wide `beforeEach` + global teardown). Both satisfy the rule (T4).
- *Clean-state precondition.* Every test starts from a clean state. If centralized setup handles this, individual tests need not duplicate the assertion; if not, each test asserts. Tests that detect dirty state fail fast with a clear message.
- *Test cadence policy.* Per backlog item: item-scope tests + `@smoke`-tagged regression. Per increment-close: full suite. CI on `develop`: full suite on every push. (Configurable but the default is encoded here.)
- *Smoke tag criteria.* Apply `@smoke` to a test if any of: (a) it covers a capability with `data_classification ≥ confidential`, (b) it covers a path tagged `@security-critical`, (c) it covers a critical user flow listed in this standard, (d) it is a regression hotspot (test that has failed on `develop` previously). `backlog-test` applies the tag at authoring time; `backlog-review` validates it.
- *Coverage rules.* ≥80% line coverage on new code (default). Security-critical paths: 100% line + 100% branch on input-validation and error paths.
- *Critical user flows.* A short list (initially empty; human-curated) of named user flows that always carry `@smoke`. Updated at `improvement-review`.
- *Framework section.* Project-specific (stub at project-init; populated during phase-1 by TA).

**`coding-standards.md` seed** must include: secret-handling rules, logging hygiene (no PII/tokens/sensitive data), error handling discipline, file-organization conventions. Tech-stack-specific details stub at project-init; populated during phase-1.

**`naming-conventions.md` seed** must include: file naming, identifier naming, branch naming (`inc-NNN-<slug>` per workflow.md §17), commit message conventions. Project-specific stub at project-init.

### Step 5 — Pin skill versions

Read the skills repo. Enumerate all skills and templates currently available. For each, record the version (commit hash if it's a git repo, or a date-stamp if it's filesystem-only). Write `skill-versions.lock`:

```yaml
# skill-versions.lock
# Pinned versions of skills and templates for this project.
# Updates happen at improvement-review (Gate 3) between phases.

dotfiles_repo: <path or "none">
dotfiles_commit: <hash or "n/a">

skills:
  session-resume: <version>
  project-init: <version>
  # ... etc.

templates:
  capability: <version>
  # ... etc.
```

### Step 6 — Initialize INDEX

Write `INDEX.md`:

```yaml
# INDEX.md
project: <name>
description: <one-line>
initialized: <ISO timestamp>
workflow_version: <hash or tag>

active_phase: null
active_increment: null
last_action: project-init
last_action_at: <timestamp>

phases: []
```

### Step 7 — Initial commit

- `git add` the new structure.
- `git commit` with message: `chore: project-init bootstrap (workflow vX.Y)`
- The commit lives on `develop`.

### Step 8 — Status summary

Emit to human:

```
═══════════════════════════════════════════════
Project initialized.
Name: <name>
Branch: develop (workflow-managed). main is human-managed.
Skills pinned: <N> skills, <M> templates.
Stubs created: <N> permanent doc stubs.
Next action: provide phase-1 raw input, then invoke session-resume.
═══════════════════════════════════════════════
```

## Halt triggers

| Trigger ID | Condition | Route-to |
| --- | --- | --- |
| T-PI-1 | INDEX.md already exists | human |
| T-PI-2 | Cannot initialize git (no permissions, etc.) | human |
| T-PI-3 | Skills repo not reachable for pinning | human (fix repo access, retry) |
| T-PI-4 | Required human input not provided | human (re-prompt) |

## Observations

This skill rarely produces observations (it runs once). Surface as `routine` if any stub creation seems redundant (signal that the template structure could be simplified).
