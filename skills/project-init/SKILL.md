# project-init

- **Name:** project-init
- **Version:** 1.0.0
- **Purpose:** Scaffold a new project — doc structure, git repo, CI pipeline (tests + SCA + secret scanner), baseline standards stubs, dotfiles/skills access verification.
- **Triggers from:** Manual invocation at project start.
- **Inputs:** Project name, target repo location, dotfiles location (containing `skills/`, `templates/`, `project-seed/` as siblings), optional `no-ci` / `no-sca` / `no-secret-scan` flags.
- **Outputs:**
  - Git repo (created if absent, verified if present).
  - CI pipeline configuration with: unit tests, UI tests, **SCA (dependency scanning)**, **secret scanner**. Each component independently overrulable via flag; defaults all on.
  - Full doc structure scaffolded per workflow.md §4 with INDEX.md stubs.
  - Seeded `/docs/process/workflow.md`, `tag-vocabulary.md` (with `@security-critical` and area-tag-onboarding note), `sequential-increments.md`, `increment-template.md`.
  - Baseline `/docs/technical/guidelines/coding-standards.md` from `templates/coding-standards-stub.md` (secrets handling + logging hygiene seeded; language/stack rules left for project setup).
  - Baseline `/docs/technical/guidelines/testing-standards.md` from `templates/testing-standards-stub.md` (≥80% baseline, `@security-critical` 100% rule).
  - Baseline `/docs/technical/guidelines/naming-conventions.md` (stub).
  - First commit on `main` branch.
- **Hands off to:** Human (project ready; awaits raw input).
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-PI-1: Git unavailable or target repo location inaccessible.
- T-PI-2: Dotfiles location unreachable, OR `project-seed/` missing, OR pinned skill versions cannot be resolved.
- T-PI-3: Target location is non-empty and not an empty git repo (unless user explicitly confirms overlay).
- T-PI-4: CI/SCA/secret-scanner setup fails for components not flagged for skip.

## Process

1. **Verify environment.** Git available; target accessible; dotfiles reachable (`skills/`, `templates/`, and `project-seed/` all present as siblings); each pinned skill version exists.

2. **Initialize repo.** If absent: `git init`, create `main` branch. If present: verify empty (or only README); halt T-PI-3 otherwise.

3. **Scaffold doc structure.** All directories per workflow.md §4. Each INDEX from `templates/index.md`. Seed (copying from `<dotfiles>/project-seed/`):
   - `docs/process/workflow.md` (with skill version placeholders replaced).
   - `docs/process/tag-vocabulary.md` from `templates/tag-vocabulary-seed.md`.
   - `docs/process/sequential-increments.md` from `templates/sequential-increments.md`.
   - `docs/process/increment-template.md` from `templates/increment-template.md`.
   - `docs/technical/guidelines/coding-standards.md` from `templates/coding-standards-stub.md`.
   - `docs/technical/guidelines/testing-standards.md` from `templates/testing-standards-stub.md`.
   - `docs/technical/guidelines/naming-conventions.md` from `templates/naming-conventions-stub.md`.

4. **Set up CI.** Default components: unit tests, UI tests, SCA, secret scanner. Tooling is VCS-specific (project-level ADR records the choice). Each may be skipped via flag. Halt T-PI-4 if any non-skipped component cannot be set up.

5. **First commit.** Message: `chore: scaffold project structure via project-init v1.0.0`.

6. **Step summary** with explicit checklist:

   ```
   ## 🔔 Project initialized
   - ✅ Repo
   - ✅ Doc structure
   - ✅ CI: tests + SCA + secret scan (or ⚠️ skipped per flag)
   - ✅ Skills dotfiles verified, versions pinned
   
   ## Open tasks for human
   - [ ] Configure VCS branch protection on `main` (human-only merge — see workflow.md §10)
   - [ ] Fill in `coding-standards.md` language/stack specifics
   - [ ] Fill in `naming-conventions.md`
   - [ ] When ready: place raw input in /docs/phases/01-<slug>/intake/raw/ and run `session-resume`
   ```

## Notes

- Branch protection (enforcing human-only merge to `main`) is set up by the human in the VCS; this skill cannot enforce it but surfaces it on the checklist.
- The skill runs once per project; re-running on an existing project isn't supported.
- Standards stubs are intentionally minimal — the seeded items (secrets handling, logging hygiene, `@security-critical` coverage rule) are workflow-mandated baselines. Language- and stack-specific rules are filled in during the first phase or as an early phase-intake artifact.
- Skill provenance/signing in dotfiles is **out of scope for v1** — see workflow.md §16. The skill verifies versions exist; it doesn't verify they haven't been tampered with.
