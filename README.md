# claude-dotfiles — agentic-SDLC workflow v1.0

Personal dotfiles hosting the skills, subagents, and templates that drive the **agentic-SDLC workflow v1.0** in Claude Code (VS Code extension).

## What's in here

```
.dotfiles/
├── skills/                      → 16 orchestration + utility skills + _meta
│   ├── _meta/SKILL.md           cross-cutting rules every skill inherits
│   ├── session-resume/          canonical session entry point
│   ├── project-init/            bootstrap a new project (replaces the old
│   │                              project-seed/ copy mechanism)
│   ├── project-pause/
│   ├── phase-start/             phase lifecycle (start → planning → close →
│   ├── phase-planning/            retrospective → improvement-review)
│   ├── phase-close/
│   ├── phase-retrospective/
│   ├── increment-start/         increment lifecycle (start → planning →
│   ├── increment-planning/        backlog-loop → close)
│   ├── increment-close/
│   ├── backlog-loop/            per-backlog-item iteration (develop / test /
│   │                              review delegation + verdict handling)
│   ├── feedback-triage/
│   ├── improvement-review/      Gate 3 — human approval of skill diffs +
│   │                              standards updates
│   ├── workflow-curator/        utility — synthesizes observation patterns
│   ├── doc-consolidator/        utility — proposes permanent-doc deltas
│   └── doc-integrity/           utility — validates ref + supersession +
│                                  status integrity at close gates
│
├── agents/                      → 7 subagent definitions (NEW in v1.0; old
│                                  workflow had no agent layer)
│   ├── phase-business-analysis.md
│   ├── phase-technical-architecture.md
│   ├── increment-functional-analysis.md
│   ├── increment-technical-analysis.md
│   ├── backlog-develop.md       (TL implementation)
│   ├── backlog-test.md          (isolated test author)
│   └── backlog-review.md        (verdict + standards observations)
│
├── templates/                   → 17 doc templates the skills consume
│   ├── INDEX.md                 project state record schema
│   ├── capability.md / aggregate.md / feature.md / flow.md
│   ├── decision-records.md      (CDR / DDR / FDR / ADR — unified spec)
│   ├── increment-scope.md / phase-plan.md / phase-debt.md
│   ├── backlog-item.md / feedback-inbox.md / observations.md
│   ├── tag-vocabulary.md / subtree-INDEX.md / minor-templates.md
│   └── standards-observations.md + workflow-observations.md
│                                (deprecated redirects — kept so legacy
│                                 transient logs still find their home)
│
├── README.md                    this file
├── claude.md                    (empty placeholder)
├── install-claude.ps1           Windows symlink installer (see below)
└── install-claude.sh            macOS / Linux symlink installer
```

## How to use it

### One-time setup (a new machine)

1. **Clone this repo to `~/.dotfiles`.**

   **Windows (PowerShell):**
   ```powershell
   git clone https://github.com/rubinbeckers/claude-dotfiles.git $env:USERPROFILE\.dotfiles
   ```

   **macOS / Linux (bash, zsh):**
   ```bash
   git clone https://github.com/rubinbeckers/claude-dotfiles.git ~/.dotfiles
   ```

2. **Install the symlinks** that expose skills as slash commands and agents as subagents in Claude Code. Both scripts do the same thing — pick the one for your OS.

   **Windows (PowerShell):**
   ```powershell
   & $env:USERPROFILE\.dotfiles\install-claude.ps1
   ```
   > Requires Developer Mode enabled, or run PowerShell as Administrator. Symlink creation on Windows is gated otherwise.

   **macOS / Linux (bash):**
   ```bash
   bash ~/.dotfiles/install-claude.sh
   ```
   > No special privileges needed. `ln -s` is available out of the box.

   Either script creates:
   - `~/.claude/commands/<skill>.md` → symlink to `~/.dotfiles/skills/<skill>/SKILL.md` (16 entries)
   - `~/.claude/agents/<agent>.md` → symlink to `~/.dotfiles/agents/<agent>.md` (7 entries)

   Symlinks point at the live files in this repo, so a subsequent `git pull` on the dotfiles propagates without re-running the installer. Re-run only when skills or agents are added / removed / renamed.

3. **Verify access.** When you later run `session-resume` in a project, the orchestrator validates `skill-versions.lock` against the dotfiles tag (default: `workflow-v1.0`); the pin check halts if anything's missing.

### Starting a new project

In a new repo with no `INDEX.md`, no `docs/`, and no `skill-versions.lock`:

1. In Claude Code, open the project. The harness auto-loads the workflow on session start.
2. Invoke `project-init`. It scaffolds:
   - `workflow.md`, `agentic-sdlc-principles.md`, `doc-structure.md` at project root
   - `INDEX.md` (with the project's slug, branch config, first phase placeholder)
   - `skill-versions.lock` pinned to the current dotfiles tag
   - `docs/permanent/` + `docs/transient/` skeleton per `doc-structure.md` §2.2 / §3.2
3. Provide raw input for the first phase. `project-init` then routes to `phase-start`.

### Resuming work

Any subsequent session, anywhere in the lifecycle:

> *"resume"* — or *"continue"* — or any unspecified opening.

`session-resume` reads `workflow.md`, validates pins, scans git on the project's `operating_branch`, and routes to the correct next skill (per its routing table in `skills/session-resume/SKILL.md`).

## Branch model

| Branch / tag | What it is |
|---|---|
| `main` | The canonical workflow-v1.0 install. Default branch. |
| `pre-v1.0-archive` | Snapshot of the prior (custom) workflow at the v1.0 migration point. Reference only — not for use. |
| tag `workflow-v1.0` | Stable pin target. `skill-versions.lock` in projects references this tag. |
| tag `pre-v1.0-migration-2026-05-25` | Local pre-migration snapshot. |
| tag `pre-v1.0-main-2026-05-25` | Pre-v1.0 origin/main snapshot (includes the old `intake-prep` skill orphaned by the force-push at v1.0 install). |

## Migrating from a prior workflow

If you have a project running an older custom workflow (skills like `business-analyst`, `developer`, `functional-specifier`, `implementation-planner`, `technical-reviewer`, `ui-test-engineer`, `phase-intake`, `skill-curator`), the migration to v1.0 is a one-shot agent-driven operation. The reference run is documented in the `lcm-agile-assessment-dashboard` project's `migration-2026-05-v1.0/` audit trail.

## References

- The v1.0 workflow contract: `workflow.md` (at any v1.0-using project's root)
- The principles this workflow instantiates: `agentic-sdlc-principles.md`
- Documentation layout: `doc-structure.md`
- Cross-cutting skill rules: `skills/_meta/SKILL.md`
