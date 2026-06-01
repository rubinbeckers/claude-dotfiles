---
name: project-init
description: Bootstrap a new project. Scaffolds the workflow contract docs, INDEX, doc directory skeleton, and skill-versions.lock. Invoked in a fresh repo with no INDEX.md.
---

# project-init

The only skill exempt from the always-allowed-set precondition (`_meta` §1), because its job is to create that set.

## Inputs

- The empty (or near-empty) project repo
- The human's project slug and optional initial raw input for phase 1
- The dotfiles repo's current tag (used to pin `skill-versions.lock`)

## Outputs

Everything lands under `docs/`. The project root holds project code, not workflow artifacts.

- `docs/workflow.md`, `docs/agentic-sdlc-principles.md`, `docs/doc-structure.md`
- `docs/INDEX.md` with project slug, branch config, and an empty phase array
- `docs/skill-versions.lock` pinned to the dotfiles tag
- `docs/permanent/` skeleton per `doc-structure.md` (capabilities, aggregates, features, design-specs, flows, architecture, decision-records/DR, decision-records/ADR, domain, design/prototype, design/archive)
- `docs/permanent/architecture/coding-standards.md`, `testing-standards.md`, `naming-conventions.md` as placeholder docs (the human or the first phase-design fills them in)
- `docs/permanent/architecture/accepted-debt.md` as an empty file (appended via human disposition at solidifying drain)
- `docs/permanent/domain/glossary.md` and `docs/permanent/domain/domain-model.md` as empty placeholders
- `docs/permanent/design/design.md` as a placeholder design system (from `templates/design.md`; the human replaces it with the project's real design system before any UI work) and `docs/permanent/design/design-deviations.md` as an empty header file (from `templates/design-deviations.md`)
- `docs/transient/` skeleton

## Steps

### 1. Confirm preconditions

Verify the repo has no `docs/INDEX.md`, no `docs/permanent/`, no `docs/skill-versions.lock`. If any exist, halt — this is not a fresh project; the human should use `session-resume`.

### 2. Gather project metadata

Ask the human for:
- Project slug
- Operating branch name (default: `develop`)
- Whether raw input for phase 1 is ready (and if so, where it lives)

### 3. Write the workflow contract docs

Create `docs/` if it doesn't exist. Copy `workflow.md`, `agentic-sdlc-principles.md`, `doc-structure.md` from the dotfiles `templates/` directory to `docs/`. The contract lives with the project so future humans (or agents) opening the project find it alongside the work.

### 4. Write the doc skeleton

Create the `docs/permanent/` and `docs/transient/` directory trees per `doc-structure.md` §1.

Create placeholder `coding-standards.md`, `testing-standards.md`, `naming-conventions.md`, `glossary.md`, `domain-model.md` files (in their respective subdirectories per the layout) with a one-line "this file will be populated during phase-design" comment. These exist so that the always-allowed-read set in `_meta` §1 resolves on day one.

Create `docs/permanent/design/design.md` (placeholder from `templates/design.md`) and `docs/permanent/design/design-deviations.md` (empty header from `templates/design-deviations.md`), so the design-system always-allowed reads (`_meta` §1) resolve on day one. `design.md` is a placeholder until the human supplies the project's real design system — it is human-owned and must be populated before the first UI increment, the same discipline as the placeholder standards docs.

Create `docs/permanent/architecture/accepted-debt.md` as an empty file with just the header from `templates/accepted-debt.md` (the project will append entries via human disposition during solidifying increments).

### 5. Write INDEX

Initialise `docs/INDEX.md` per the `templates/INDEX.md` template, with the project slug and an empty phase array.

### 6. Pin skills

Write `docs/skill-versions.lock` referencing the dotfiles tag the project will pin to. The human can override the default tag.

### 7. Initial git commit

If the project is in a fresh git repo, commit the scaffold with a message like `chore: project-init v1.2 scaffold`. If the project already has commits, do not commit automatically — surface the staged changes to the human for review.

### 8. Advance

If the human provided raw input in step 2 and pointed at its location, invoke `phase-design`. Otherwise, surface a status line:

```
project-init complete.
Workflow files scaffolded under docs/.
Before UI work: replace the placeholder docs/permanent/design/design.md with your project's design system.
Provide raw input for phase 1 at docs/transient/phases/01-<slug>/raw-input/, then run session-resume (or "resume").
```

## Edges

- Repo not empty (existing INDEX, docs/) → halt; redirect to `session-resume`.
- Dotfiles tag not reachable (skill-versions.lock would resolve to nothing) → halt with environment fix instructions.
- Workspace permissions don't allow writes → halt to human.

## Observations to surface

Recurring missing-input issues during init (signal: the project-init prompt may need more upfront questions); placeholder standards docs never being filled in by phase 1 (signal: phase-design should produce them as part of its outputs).
