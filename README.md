# Agentic SDLC Scaffolding

Complete scaffolding for the agentic SDLC workflow. Three components, each going to a different place:

```
scaffolding/
├── project-seed/         → COPIES INTO EACH NEW PROJECT REPO
│   └── docs/process/
│       └── workflow.md   # THE source of truth — read first
│
├── skills/               → LIVES IN YOUR DOTFILES REPO
│   ├── _meta/SKILL.md    # shared behavior all skills inherit
│   └── <skill>/SKILL.md  # 15 skills (see inventory below)
│
└── templates/            → LIVES ALONGSIDE THE SKILLS (in dotfiles)
    └── *.md / *.feature  # ~22 document templates the skills use
```

## How to use it

### One-time setup

1. **Put the skills in your dotfiles.** Copy `scaffolding/skills/` to wherever your dotfiles host them. The 15 skill folders + `_meta/` need to be accessible to the orchestrating agent.
2. **Put the templates with the skills.** Copy `scaffolding/templates/` to the same parent location. The skills reference templates by relative path (e.g., `templates/capability.md`).
3. **Verify access.** When you later run `project-init`, it checks the dotfiles location is reachable and validates the pinned skill versions per `workflow.md` §15.

### Starting a new project

1. Tell the orchestrating agent: *"Initialize a new project at `<path>` using `project-init`."*
2. `project-init` scaffolds the repo, sets up CI (unit + UI + SCA + secret scanner), creates the doc structure, seeds `workflow.md`, `tag-vocabulary.md`, baseline standards stubs, verifies skills access.
3. Place raw input (anything — Word docs, notes, transcripts, decks) into `/docs/phases/01-<phase-slug>/intake/raw/`.
4. Tell the agent: *"Run `session-resume`."*

From there, the workflow runs. Your role is to approve gates and answer the halts the non-assumption principle surfaces.

### Starting a coding session on an existing project

Just say: *"Run `session-resume`."* That skill is the workflow's entry point — it reconciles state (git, indices, pinned versions, undocumented main commits) and routes to the right next step.

### Pausing a project

Tell the agent: *"Run `project-pause`."* It captures a clean paused state with a summary. Next session's `session-resume` will detect and surface the pause; clearing it (delete `pause-summary.md`) resumes normally.

## The closed loop

```
session-resume (every session start)
   ↓ (routes to)
[project-init | phase-intake | increment-start | resume | phase-close | wait]

→ phase-intake → increment-start → business-analyst →
  functional-specifier → implementation-planner → developer →
  ui-test-engineer → technical-reviewer → increment-close →
  (next increment OR phase-close → skill-curator → next phase)
```

Each skill explicitly declares inputs, outputs, and handover target. The orchestrator follows the chain. You see it through six required human gates plus any halts the non-assumption principle surfaces.

## Skill inventory (15 + meta)

| Skill | When it runs |
|-------|--------------|
| `_meta` | Inherited by all (not invoked directly) |
| `session-resume` | Every session start — routes to the right next step |
| `project-init` | Project bootstrap |
| `phase-intake` | Each new phase (or amendment mode mid-phase) |
| `increment-start` | Each new increment |
| `business-analyst` | After increment scope approval |
| `functional-specifier` | After business refinement |
| `implementation-planner` | After BDD approval |
| `developer` | After plan approval |
| `ui-test-engineer` | After development |
| `technical-reviewer` | After UI tests |
| `increment-close` | After review approval |
| `phase-close` | After last increment of a phase merges |
| `project-pause` | Manual — captures paused state |
| `skill-curator` | At phase close (or manually) |
| `doc-integrity` | Utility sub-skill, invoked by `increment-close` and `phase-close` |

## The six required human gates

| # | Where | What you decide |
|---|-------|-----------------|
| 0 | After `phase-intake` Pass 1 | Itemized intake-review approvals (gaps, defaults, area tags) |
| 1 | After `phase-intake` Pass 2 | Phase setup outputs (capabilities, direction, threat answers) |
| 2 | After `increment-start` | Increment scope |
| 3 | After `functional-specifier` | BDD scenarios |
| 4 | After `implementation-planner` | Implementation plan (with plain-language ADR digest) |
| 5 | After `technical-reviewer` approval | PR merge — checklist separates *verified mechanically* from *needs human confirmation* |

## Security posture (built in, not bolted on)

Security is built into specific artifacts and checks across the workflow rather than into a dedicated security-reviewer skill (which without expertise would produce false confidence). See `workflow.md` §16 for full details.

- **Capability spec** has discrete fields: `Data classification`, `Authn required`, `Authz model`, `Threat considerations` (questions for the human when classification > public or trust boundary crossed).
- **Aggregate spec** has `Data classification`.
- **`@security-critical` tag** derived deterministically from data classification ≥ confidential.
- **Testing standards** require 100% line + branch coverage on `@security-critical` paths' input-validation and error paths.
- **Coding standards** seed with secrets-handling and logging-hygiene baselines.
- **CI defaults** include SCA + secret scanner alongside tests.
- **ADRs introducing dependencies** include `Supply chain notes` referencing SCA output.
- **Technical-reviewer checklist** covers secrets grep, logging hygiene, input validation at trust boundaries, SCA results, AC coverage, dep-trace.
- **Gate 5** explicitly separates mechanical checks from human confirmations.

**Floor, not ceiling.** Defensible for solo agentic SDLC on pre-production or non-public-facing code. Anything landing in front of real users with real data should have an external security pass before go-live. Known v1 limitations: skills supply chain (signing/provenance), expert threat modeling depth, operational security.

## Design principles in one paragraph

The workflow treats context as a budget. Skills load only what their declared inputs and the plan-manifest authorize. Every claim is grounded in a cited source; ungrounded claims are halt triggers. Decisions are append-only — superseded, withdrawn (terminal), or rejected, never edited. Every artifact carries tags from a controlled vocabulary; loaders filter by tag. Six required gates plus halt-surfaces keep humans in the loop on intent, not on minutiae. Security, supply chain, and standards are mechanically checked where they can be and explicitly surfaced for human judgment where they can't — never mixed.

## Files

```
scaffolding/
├── README.md (this file)
├── project-seed/
│   └── docs/process/workflow.md
├── skills/
│   ├── _meta/SKILL.md
│   ├── session-resume/SKILL.md
│   ├── project-init/SKILL.md
│   ├── phase-intake/SKILL.md
│   ├── increment-start/SKILL.md
│   ├── business-analyst/SKILL.md
│   ├── functional-specifier/SKILL.md
│   ├── implementation-planner/SKILL.md
│   ├── developer/SKILL.md
│   ├── ui-test-engineer/SKILL.md
│   ├── technical-reviewer/SKILL.md
│   ├── increment-close/SKILL.md
│   ├── phase-close/SKILL.md
│   ├── project-pause/SKILL.md
│   ├── skill-curator/SKILL.md
│   └── doc-integrity/SKILL.md
└── templates/
    ├── (artifact templates) aggregate, capability, component, decision-record, feature, flow, ui-spec
    ├── (phase) phase-intake-review, phase-scope, phase-direction, phase-roadmap, phase-retrospective
    ├── (increment) increment-scope, increment-plan, increment-review, increment-changelog, increment-template
    ├── (process) tag-vocabulary-seed, sequential-increments, standards-observations, pause-summary
    ├── (standards stubs) coding-standards-stub, testing-standards-stub, naming-conventions-stub
    └── (utility) index
```
