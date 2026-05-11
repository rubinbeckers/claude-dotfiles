# intake-prep

> **Standalone skill — NOT part of the agentic SDLC workflow.**
>
> This skill lives outside the workflow scaffolding and does not inherit the workflow's meta-skill or follow its halt-trigger / handover conventions. It exists solely to bridge the gap between "I have an unstructured idea" and "phase-intake can do something useful with it." Use it in Claude Cowork, not in coding sessions.

- **Name:** intake-prep
- **Version:** 1.0.0
- **Purpose:** Convert unstructured initial input (a prompt, an attached Claude design zip, loose notes, transcripts) into a set of structured raw-input files that the agentic SDLC workflow's `phase-intake` can productively process on its first pass. Trigger targeted Q&A to fill gaps without over-specifying.

## When to use this skill

- You're about to scaffold a new agentic SDLC project with `project-init`.
- Your starting material is unstructured: a prompt, maybe a Claude design zip, maybe some notes — but nothing organized into capabilities, actors, tech stack, etc.
- You want `phase-intake`'s first pass to be productive rather than surfacing 20 trivial gaps in `intake-review.md`.

## When NOT to use this skill

- You already have structured input (existing PRD, capability list, architecture brief) — drop those directly into `<project>/docs/phases/01-<slug>/intake/raw/` and run `session-resume`.
- You're mid-phase with new information for an existing project — use `phase-intake`'s amendment mode instead (workflow.md §6 Phase 1).
- You're in an SDLC coding session — this skill is Cowork-only, never invoked by the workflow's orchestrator.

## Design constraints

- **Lightweight.** The workflow does detailed analysis per phase and increment. This skill bridges the gap; it does not pre-empt phase-intake's job.
- **Conversational, not form-based.** Ask in coherent batches of 2–4 questions per round. No giant up-front questionnaires; no one-question-at-a-time drips.
- **"Open for the workflow to propose" is a valid answer.** Many decisions are designed to be made at Gate 0 / Gate 1 inside phase-intake. Don't try to nail them down here.
- **Respect what's already provided.** If a Claude design zip is attached, read it before asking about UI direction. If the prompt is explicit about tech stack, don't ask about tech stack.
- **No invention.** If the user doesn't know something, capture that. Don't write "users authenticate via OAuth" unless the user said so.
- **Minimum viable, not maximum thorough.** The goal is to clear the obvious gaps, not to anticipate every halt phase-intake might trigger.

## Output

A set of plain-markdown files for the user to copy into `<project>/docs/phases/01-<slug>/intake/raw/`:

| File | Contains |
|------|----------|
| `01-vision.md` | What the system is for, why it exists, what "first version successful" looks like |
| `02-actors.md` | Primary and secondary users, their context, what they're doing today this replaces |
| `03-capabilities-sketch.md` | What the system needs to do, in loose terms — not specified, not prioritized |
| `04-technical-context.md` | Tech preferences/constraints, deployment target, existing systems to integrate, dev environment notes |
| `05-non-functional.md` | Performance expectations, security stance, compliance constraints, scale, accessibility |
| `06-out-of-scope.md` | Explicit no's surfaced now to prevent drift later |
| `07-reference-materials.md` | Index of attached materials (design zip contents, mockups, notes) and where they live |

Each file is short — a paragraph to a page. They are **input** for phase-intake, not refined specs.

If something is genuinely unknown, the file marks the section explicitly:

```
## Tech stack
> Open — to be proposed by phase-intake at Gate 1.
```

That's legitimate. phase-intake will surface it as a decision item in `intake-review.md` and propose a default the user can approve or override.

## Process

### 1. Ingest

Read everything provided. If a Claude design zip is attached, unpack it and read:
- Any manifest or README inside.
- The prototype HTML/CSS for UI direction signals.
- Any notes the design tool generated about user flows or features.

If other files are attached (notes, transcripts, PDFs), read them and note their content.

Summarize what was provided in plain language. Don't editorialize yet.

### 2. Restate intent

Produce a one-paragraph "as I understand it" summary of what the user is trying to build. Show it back. Let them correct.

This is the single most important checkpoint — if the agent has misunderstood the core intent, everything downstream is wrong. Don't proceed until the user confirms the restatement is close enough.

### 3. Gap-driven Q&A (iterative)

Compare what's now known against the seven output files. Identify the biggest gaps. Ask 2–4 focused questions per round, grouped by theme. Continue rounds until the user is satisfied or the remaining gaps are reasonable to defer to phase-intake.

**Question banks by theme** (pick what's relevant; don't ask everything):

*Intent / success:*
- What does success look like for the first version — three users solving one problem, or thousands?
- What's the alternative the user uses today, and what's wrong with it?
- Is this a product, an internal tool, or a one-off?

*Actors:*
- Who is the primary user, and what are they doing today this replaces?
- Are there secondary actors (admins, integrators, customers of customers)?
- What's the user's technical comfort level?

*Capabilities:*
- Of the things this needs to do, which one is the hardest to NOT have on day one?
- What's the one thing that, if missing, makes this not worth using?
- Are there capabilities that are "nice to have, not first version"?

*Technical:*
- Do you have an opinion on tech stack, or is it open for the workflow to propose?
- Where will this run — web, mobile, desktop, CLI, server, edge?
- Are there systems it must integrate with from day one?
- Is there an existing codebase or is this greenfield?

*Data / security:*
- What kind of data does this hold? Public, internal-only, sensitive customer data, regulated?
- Are there compliance constraints — GDPR, HIPAA, SOC2, PCI, financial reporting?
- Does it need authentication? If yes, what type (session, SSO, API key, none)?

*Scale / non-functional:*
- Single-user app, small-team internal tool, or public product?
- Any hard performance requirements (sub-second response, real-time, batch)?
- Availability expectations — best effort, business hours, 24/7?

*Boundaries:*
- What is this explicitly NOT trying to be?
- Are there directions it should consciously avoid (e.g., "no AI features," "no mobile," "no integrations")?
- What's the timeline / budget shape, if any?

**Respect "I don't know yet."** That's a legitimate answer — capture it as "open for phase-intake to propose" in the relevant file.

### 4. Show drafts

When gaps feel reasonable (not necessarily zero, just no longer blocking), draft all seven files. Show them inline for review.

Each file should be:
- Short (a paragraph to a page).
- Factual — claims grounded in the user's actual input or prior Q&A answers.
- Explicit about what's "open" vs. what's "decided" (decided here means the user expressed an opinion in the conversation; refined specs come later in phase-intake).

### 5. Polish loop

Let the user request tweaks. Common adjustments:
- Reword the intent.
- Move something from `02-actors.md` to `06-out-of-scope.md` ("on reflection, admins aren't actually users").
- Add a constraint that surfaced during the review.
- Mark something previously "decided" as "open."

Don't push for completeness. The workflow's design assumes phase-intake will surface gaps systematically; this skill's bar is "no longer a wall of obvious gaps."

### 6. Finalize

Once the user is satisfied, present the seven files. Tell them where to put them:

> Copy these into `<your-new-project>/docs/phases/01-<slug>/intake/raw/`. Then run `session-resume` (or `project-init` first, if the project doesn't exist yet). The workflow's `phase-intake` skill will pick them up.

## Notes

- This skill is standalone. It does not load `workflow.md`, the SDLC meta-skill, or any other agentic SDLC artifact. It produces input *for* the workflow, not *with* the workflow.
- The file count (seven) and naming are conventions, not requirements. phase-intake reads anything in `/intake/raw/`. The numbering is for human reading order; the names are for human navigation.
- "Open for phase-intake to propose" answers are first-class citizens. Many design decisions belong in Gate 0 / Gate 1 of phase-intake, not here.
- Don't simulate phase-intake here. Don't draft capability specs, ADRs, or aggregate models. That's phase-intake's job and it's better at it because it has the full workflow context, scoring rules, and gate discipline behind it.
- The skill is for **Cowork** sessions specifically. It is not invoked by the workflow's orchestrator and has no role in coding sessions.
