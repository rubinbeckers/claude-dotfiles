---
name: increment-start
description: >
  Mandatory orchestration skill for starting a new increment. Invoke at the
  beginning of every increment before generating any sub-agent work packages.
  Loads the correct context from input files and increment summaries, then
  produces scoped work packages for each sub-agent.
invoke: manual
---

## Increment Start Protocol

Execute in order. Do not generate work packages until all steps are complete.

### Step 1 — Identify the current increment

Read `project-plan.md`. Locate the current increment block.
Extract:
- Increment number and name
- Branch name
- Requirements in scope (REQ-N list)
- Architecture sections in scope (§N list)
- Features in scope (feature names)
- Whether this increment includes UI work (if yes, UI Kit must be loaded in Step 3)
- Out-of-scope items

### Step 2 — Load project memory

Load all files matching `docs/increment-*-summary.md`, in ascending order.
These summaries are the sole source of truth for deviations and decisions made in prior increments.
Input files are not re-read for historical context — only summaries provide that.

If no summaries exist, this is increment 1. Note this and continue.

### Step 3 — Load scoped input content

Load only the sections referenced in the current increment block:

- From `business-analysis.md`: the listed REQ-N requirements and the domain model entities relevant to those requirements.
- From `technical-architecture.md`: the listed §N sections only. Do not load the full file.
- From `functional-analysis.md`: the listed feature sections only. Do not load other features.
- From `specs/claude-design/dashboard/project/UI Kit.html`: always load in full for any increment that includes UI work. Pass the UI Kit to the planning agent work package so it can compose dashboard screens from kit components.
- From `coding-guidelines.md`: always load in full. It is small and always relevant.

### Step 4 — Load technical documentation

Load `docs/project-setup.md` if it exists.
This provides build commands, test commands, environment variables, and repository details.

If `project-setup.md` does not exist and this is not increment 1, surface a warning:
`[WARNING: project-setup.md missing. Build and test steps may fail.]`

### Step 5 — Check for technology gaps

Review the technology stack in `technical-architecture.md` against the work to be done this increment.
If any technology required to complete the increment is not listed in the stack, surface it now:
`[GAP: {description of missing technology or tooling}]`

Do not proceed past this step until gaps are acknowledged or resolved.

### Step 6 — Check for conflicts with prior summaries

Cross-reference the loaded input content against deviation entries in all increment summaries.
If any prior deviation affects the current increment's scope, flag it explicitly:
`[DEVIATION IMPACT: Increment N deviated from §X / REQ-Y in the following way: ... This affects the current increment because ...]`

### Step 7 — Create the feature branch

Run: `git checkout develop && git pull && git checkout -b [branch name from project-plan]`

Surface any git errors before continuing.

### Step 8 — Generate sub-agent work packages

Produce four scoped work packages. Each package contains only what that agent needs.

**Planning agent work package:**
- Current increment name and number
- Full list of in-scope requirements (REQ-N with their text)
- Full list of in-scope architecture sections (§N content)
- Full list of in-scope feature scenarios
- UI Kit (`specs/claude-design/dashboard/project/UI Kit.html`) — if this increment includes UI work
- Deviation impacts from Step 6
- Coding guidelines
- Instruction: produce `docs/increment-N-plan.md`

**Development agent work package:**
- The approved `docs/increment-N-plan.md` (filled in after planning)
- Coding guidelines
- In-scope architecture sections
- project-setup.md content
- Instruction: implement the plan; commit logical units of work with clear commit messages
- Note: the development agent does NOT write UI/Playwright/E2E tests — those belong to the functional testing agent. If the plan contains a step for UI tests, remove it from the development work package and note it as handled by the functional agent.

**Technical testing agent work package:**
- The approved `docs/increment-N-plan.md`
- Coding guidelines (especially testing and coverage requirements)
- project-setup.md (for build and test commands)
- Instruction: review compliance, check coverage, flag regression risk, build on approval; escalate to human after 3 failed loops

**Functional testing agent work package:**
- In-scope feature scenarios (Given/When/Then)
- project-setup.md (for app start command and UI test command)
- Path convention: `tests/functional/[feature-name]/`
- Instruction: write and run UI tests for in-scope features; run full existing test suite for regression

### Step 9 — Confirm readiness

State:
- Increment N is ready to begin
- Branch created: [branch name]
- Work packages prepared for: planner, developer, technical tester, functional tester
- Any warnings or gaps raised: [list or "none"]
- Deviation impacts noted: [list or "none"]

Hand the planning work package to the planning agent. Do not proceed to development until the plan exists and has been human-approved.
