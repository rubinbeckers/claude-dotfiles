---
name: increment-close
description: >
  Mandatory closing skill for completing an increment. Invoke after all sub-agent
  work is done and the functional test agent has approved. Writes the increment
  summary, updates docs/project-setup.md if needed, commits, and opens a pull request
  to develop.
invoke: manual
---

## Increment Close Protocol

Execute in order. Do not open the PR until all steps are complete.

### Step 1 — Confirm all outputs are present

Verify:
- `docs/increment-N-plan.md` exists
- Technical testing agent has approved (no outstanding issues)
- Functional testing agent has confirmed all in-scope scenarios pass and regression is clean

If any output is missing or unresolved, do not proceed. Surface the gap.

### Step 2 — Update docs/project-setup.md

If any of the following changed during this increment, update `docs/project-setup.md` accordingly:
- New environment variables added
- Build or start commands changed
- New tooling or scripts introduced
- Test commands changed

If nothing changed, skip this step.

If `docs/project-setup.md` does not yet exist, create it now with all known setup information:
repository URL, branch strategy, environment variables, build command, start command, test commands.

### Step 3 — Write the increment summary

Create `docs/increment-N-summary.md` using this exact structure:

```markdown
# Increment [N] — [Name] Summary

## Delivered
Plain-language description of what was built.

## Deviations
Record every deviation from input files. If none, write "None."
Future increments read this section instead of re-reading input files.

### From business requirements
- REQ-N: [what was specified] → [what was actually done and why]

### From technical architecture
- §N: [what was specified] → [what was actually done and why]

### From functional analysis
- [Scenario name]: [what was specified] → [what was actually done and why]

## Architectural decisions made
Decisions not specified in technical-architecture.md that were made during implementation.
These are binding for future increments unless explicitly overridden.
If none, write "None."

## Patterns established
Coding or structural patterns introduced this increment that future agents must follow.
If none, write "None."

## Tech debt introduced
Any shortcuts taken. Include a note on what would be needed to resolve.
If none, write "None."

## Deferred items
Anything planned for this increment that was moved out. State where it was deferred to.
If none, write "None."

## Test results
- Technical tests: [pass / fail — summary]
- UI tests (in-scope): [pass / fail — summary]
- UI tests (regression): [pass / fail — summary]
```

### Step 4 — Final commit

Stage all remaining changes including the increment summary and any docs/project-setup.md updates.
Commit with message: `chore: close increment N — [increment name]`

### Step 5 — Open pull request

Push the feature branch and open a pull request targeting `develop`.

The PR should include:
- Title: `Increment N — [name]`
- A summary of what was delivered (from the increment summary)
- Test results (from the increment summary)
- Any deviations or decisions worth highlighting for the reviewer

Merging into `develop` and subsequently into `main` is done manually by the human developer.

### Step 6 — Confirm closure

State:
- Increment N is closed
- Summary written at: `docs/increment-N-summary.md`
- docs/project-setup.md: [updated / unchanged]
- PR opened: [PR URL or confirmation]
- Next increment: [N+1 name, or "project complete" if this was the last]
