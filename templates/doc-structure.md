# Documentation structure (v1.2)

How the project's documentation is organized, where each kind of doc lives, and how it moves through its lifecycle.

## 1. The layout

Everything the workflow manages lives under `docs/`. The project root holds project code (`src/`, `tests/`, etc.) and tooling files (`README.md`, `package.json`, `.gitignore`, etc.); the workflow doesn't touch any of those.

```
<project-root>/
  docs/
    INDEX.md                       # project state record; orchestrator updates only
    workflow.md                    # canonical workflow contract (v1.1)
    agentic-sdlc-principles.md     # why the contract is shaped this way
    doc-structure.md               # this file
    skill-versions.lock            # pin to the dotfiles tag
    permanent/                     # spec-bearing artifacts; status field is ground truth
      domain/
        capabilities/
          subtree-INDEX.md         # derived by doc-integrity
          <cap-NNN-slug>.md
        aggregates/
          subtree-INDEX.md
          <agg-NNN-slug>.md
        glossary.md
        domain-model.md            # cross-context invariants (always-allowed)
      features/
        subtree-INDEX.md
        <feature-slug>.md
        design-specs/
          subtree-INDEX.md
          <feature-slug>.md
      flows/
        subtree-INDEX.md
        <flow-slug>.md
      architecture/
        coding-standards.md
        testing-standards.md
        naming-conventions.md
        accepted-debt.md           # permanent record of consciously-accepted debt
        <other-architecture-docs>.md
      decision-records/
        DR/                        # domain / capability / feature decisions
          subtree-INDEX.md
          <DR-NNN-slug>.md
        ADR/                       # architecture / technology / system-impact decisions
          subtree-INDEX.md
          <ADR-NNN-slug>.md
      design/
        design.md                  # the design system — tokens + component inventory (human-owned; always-allowed; source of truth for UI)
        design-deviations.md       # append-only log of every divergence from design.md
        prototype/
        archive/                   # prior prototypes that were replaced
    transient/                     # working state; only the active phase's content is active
      pauses/                      # pause records, by timestamp
      pending-skill-diffs/         # staged high-risk diffs awaiting next session-resume
      phases/
        <phase-slug>/
          phase-scope.md
          phase-plan.md
          observations.md
          feedback-inbox.md
          phase-debt.md
          consolidation-proposed.md
          integrity-report.md
          curator-summary.md
          skill-diff-proposals/
          standards-diff-proposals/
          raw-input/
          prototype-candidate/
          carry-forward-from-<prior-slug>/
          carry-forward/           # content surviving to the next phase
            deferred-debt.md       # debt entries deferred at solidifying-drain
            deferred-proposals.md  # improvement proposals deferred at phase-close
          increments/
            <inc-slug>/
              increment-scope.md   # includes implementation plan + sequencing
              technical-analysis.md
              progress.md
              review.md
              defects-discovered/
      archive/                     # prior phases' transient content, preserved for audit
```

## 2. Why no `proposed/` directory

Spec-bearing artifacts are born under `docs/permanent/...` with `status: proposed`. At gate approval, status flips to `accepted` in place — no file move. This means:

- File paths are stable. Cross-references don't break at gate approval.
- A reader scanning `docs/permanent/capabilities/` sees everything ever proposed; the status field tells them what's accepted.
- The directory structure doesn't change between phases.

The transient/permanent split survives because *working state* (phase plans, increment scopes, observations, feedback inbox, debt log, progress logs) doesn't need long-term preservation in active form — only the spec-bearing outputs do.

## 3. Status fields are the lifecycle

Every spec-bearing artifact declares a `status:`:

- `proposed` — authored, awaiting the gate that promotes it.
- `accepted` — passed its gate; the canonical version for any agent or human consumer.
- `superseded` — replaced by a successor (which carries `supersedes:` pointing back).
- `deprecated` — no longer applicable, with a recorded reason; no successor.
- `withdrawn` — proposed but never accepted; may be re-proposed under a new ID with `prior_withdrawn:`.

Agents and humans always check status before acting on an artifact. The directory it's in doesn't tell you whether you should rely on it; the status does.

## 4. Decision records: two types, two namespaces

- **DR** (Decision Record) — covers capability-scope, domain-model, and feature-design decisions. Authored by the domain-design agent.
- **ADR** (Architecture Decision Record) — covers architecture, technology, system-impact decisions. Authored by the technical-design agent. Carries an additional "Supply chain notes" section when introducing a new external dependency.

Each type has its own numbering namespace. Numbers are assigned at gate approval (Gate 1 for phase-level, Gate 2 for increment-level). `TBD-<slug>` placeholders survive only between authoring and gate approval.

## 5. Carry-forward

Content surviving to the next phase — deferred feedback, deferred improvement proposals, deferred discovered-defect items — lives in `docs/transient/phases/<phase-slug>/carry-forward/` during the active phase and is moved to `<next-phase-slug>/carry-forward-from-<prior-slug>/` at the next `phase-design` step.

Carry-forward content is read by the next phase's design agents as part of their input.

## 6. Archive

When a phase closes (after `phase-close` runs and approves consolidation), the phase's transient directory is moved to `docs/transient/archive/<phase-slug>/`. The active tree contains only:
- `docs/permanent/...` (all of it)
- `docs/transient/phases/<active-phase>/...` (only the in-flight phase)
- `docs/transient/archive/...` (audit trail)

A reader of `docs/transient/archive/<phase-slug>/observations.md` from 12 phases ago can reconstruct what was observed and how it was resolved.

## 7. INDEX

`docs/INDEX.md` is the canonical state record. It contains:
- Project slug and metadata
- Phase history (each with status, gate decisions, increments delivered)
- Active phase and increment, current position within `increment-execute` if applicable
- `gate_status:` entries per gate decision
- `docs/skill-versions.lock` reference

INDEX is read by `session-resume` for routing. The orchestrator updates INDEX at every state transition; the human doesn't edit it directly.

## 8. Editorial changes

Typos, formatting, link fixes, capitalization, and whitespace adjustments happen in place on accepted artifacts. Each accepted artifact may have a sibling `editorial-log.md` recording the changes:

```
- timestamp: <ISO>
  by: <human or agent>
  scope: typo | formatting | link | capitalization | whitespace
  description: <one-line>
```

Anything semantic — status, IDs, supersession links, accepted decision values, AC text — is supersession, not editorial. Boundary cases default to supersession.

## 9. Always-allowed reads

Per `_meta` §1, every agent and skill may always read certain docs without listing them in a manifest:
- `docs/workflow.md`, `docs/agentic-sdlc-principles.md`, `docs/doc-structure.md`
- The agent's or skill's own definition file plus `_meta`
- `docs/permanent/architecture/coding-standards.md`, `testing-standards.md`, `naming-conventions.md`
- `docs/permanent/domain/glossary.md`
- `docs/permanent/domain/domain-model.md`
- `docs/permanent/design/design.md` and `docs/permanent/design/design-deviations.md`

These are the project's universal context. Everything else is by manifest. `domain-model.md` is in the set because cross-context invariants must be respected by every spec-bearing artifact; an agent that doesn't read it can silently violate an invariant. `design.md` is in the set for the same reason on the UI side — it is the source of truth for components and tokens, so any agent producing or validating a UI-bearing artifact must read it (`_meta` §17). It is **human-owned**: always-allowed for reading, never written by an agent.

## 10. Tag vocabulary

Tags used in feature files (`@<capability-id>`, `@high|medium|low` criticality, `@security-critical`, `@error-path`, `@smoke`) are defined in `docs/permanent/architecture/naming-conventions.md`. Folded into naming-conventions because tags are a vocabulary contract that lives alongside other naming rules.

## 11. Subtree indexes

In several subtrees that the orchestrator routinely needs to scan for manifest construction or human review, a `subtree-INDEX.md` exists as a **derived directory map**. It lists every file in the subtree (across all statuses) with its ID, status, name, and a one-line summary.

The indexed subtrees are:
- `docs/permanent/domain/capabilities/`
- `docs/permanent/domain/aggregates/`
- `docs/permanent/features/`
- `docs/permanent/features/design-specs/`
- `docs/permanent/flows/`
- `docs/permanent/decision-records/DR/`
- `docs/permanent/decision-records/ADR/`

**The index is regenerated mechanically by `doc-integrity`** at every close gate (and on demand). Do not edit a `subtree-INDEX.md` by hand — edits are overwritten on regeneration. The summary cell is pulled from each file's frontmatter `summary:` field; templates that participate in indexing carry that field.

This lets the orchestrator and human reviewers see at a glance what exists in a subtree without reading every file. The mechanical regeneration is the safeguard against staleness — the index is always in sync with the directory at the last close gate.
