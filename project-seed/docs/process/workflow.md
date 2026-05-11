# Agentic SDLC Workflow

> **For the orchestrating agent reading this file:** This document is the single source of truth for how this project is built. Read it fully before any action. It tells you what skills exist, when to invoke them, what the doc structure is, and what principles bind every agent involved. Skills are loaded from the configured dotfiles location (see §11) and inherit shared behavior from the meta-skill.
>
> **At session start, invoke `session-resume`** (see §11). It reconciles state and routes you to the right next step.

## 1. Purpose

This workflow delivers software through agentic coding, end-to-end: from unstructured business input to merged code with passing tests and updated documentation across all three layers (business, functional, technical).

The workflow is **project-agnostic** — the same skills and structure run across multiple projects. Project-specific knowledge accumulates in each project's repository; cross-project learnings flow into the shared skills via a controlled curation process.

The core engineering principle is **selective context loading**: every artifact, phase, and handoff is shaped so agents pull only the context relevant to the task at hand, regardless of how the documentation set grows.

## 2. Core Principles

These apply to every phase, artifact, and skill.

1. **Atomic units.** Every doc is small, named, and self-contained. No monoliths.
2. **Living docs vs. decision records.** Current-state truth lives in mutable files (domain model, capability specs, component docs). Historical reasoning lives in append-only decision records (DDRs, CDRs, FDRs, ADRs). Decisions are never edited — they are superseded.
3. **INDEX-first loading.** Every directory has a lightweight index, always cheap to read. Full files are pulled only on demand.
4. **Tags as routing.** Every doc carries tags drawn from a controlled vocabulary. Selective loading happens by tag filter.
5. **Cross-references over duplication.** Docs link to each other; no doc restates another.
6. **Non-assumption principle.** When an agent encounters a gap, ambiguity, or conflict it cannot reconcile from existing structured docs, it halts and surfaces. Suggested resolutions may be offered; human approval is required before acting. See §7 for concrete halt triggers.
7. **Plan as context manifest.** The increment's `plan.md` is the curated list of docs the developer loads. Converts "search and hope" into "load this list."
8. **Append-only history.** Old decisions remain visible, marked superseded/withdrawn/abandoned. Loaders filter by status to skip stale guidance.
9. **Grounded claims.** Every step summary lists the source docs each claim is grounded in. `doc-integrity` lints that the cited sources exist, are in scope, and are current. Ungrounded claims are assumptions and must be flagged.

## 3. Hierarchy of Organizational Units

- **Product** — the lifetime of the system.
- **Phase** — a coherent body of work driven by a coherent input set. A phase starts with `phase-intake` and ends with `phase-close`.
- **Increment** — the unit of delivery: docs at all three layers + code (or doc-only — see §10) + ≥80% unit coverage on code paths + automated UI tests + merged PR. Belongs to a phase via `@phase-NN`.

## 4. Documentation Structure

```
/docs
  /business
    /domain
      INDEX.md, glossary.md, cross-context-invariants.md
      /<bounded-context>/<aggregate>.md, invariants.md
      /decisions/DDR-NNNN-<slug>.md
    /capabilities
      INDEX.md, <capability>.md
      /decisions/CDR-NNNN-<slug>.md
  /functional
    /flows/INDEX.md, <flow>.md
    /ui/INDEX.md, <screen>.md
    /decisions/FDR-NNNN-<slug>.md
  /technical
    /architecture
      INDEX.md, overview.md, tech-stack.md, ADR-NNNN-<slug>.md
      /components/INDEX.md, <component>.md
    /guidelines/coding-standards.md, testing-standards.md, naming-conventions.md
  /process
    workflow.md, tag-vocabulary.md, increment-template.md, sequential-increments.md
    /learnings/<skill>.md
  /phases
    INDEX.md
    /NN-<slug>/
      /intake/raw/, /intake/processed/
      intake-review.md, intake-amendment-NN.md (if any), scope.md, direction.md, roadmap.md
      standards-observations.md, phase-log.md, retrospective.md
  /increments
    INDEX.md
    /NNN-<slug>/scope.md, plan.md, step-log.md, changelog.md, review.md
/design
  INDEX.md, /prototypes/<name>.md, /<name>-artifacts/
/features
  INDEX.md, <capability>.feature
/src, /tests/unit, /tests/ui
```

## 5. Per-Document Contents (summary; see templates for full structure)

- **`business/domain/glossary.md`** — ubiquitous language. Authored by `phase-intake` and `business-analyst` as they create capabilities/aggregates (§7 glossary-authoring carve-out).
- **`business/domain/<context>/<aggregate>.md`** — purpose, entities, value objects, invariants, behaviors, **Data classification** (public/internal/confidential/restricted), relationships.
- **`business/capabilities/<capability>.md`** — intent, actors, AC with IDs (`AC-1`, `AC-2`, …), NFRs, **Data classification**, **Authn required**, **Authz model**, **Threat considerations** (questions for the human when classification > public or trust boundary crossed), out-of-scope.
- **`technical/architecture/ADR-NNNN-*.md`** — Nygard format; cross-cutting NFRs tagged `@nfr`; ADRs introducing dependencies include a `Supply chain notes` section referencing SCA output.
- **`technical/guidelines/coding-standards.md`** — language/stack rules; seeded with secrets-handling and logging-hygiene baseline items.
- **`technical/guidelines/testing-standards.md`** — ≥80% baseline; `@security-critical` paths (derived from capability data classification ≥ confidential) require 100% line + branch coverage on input-validation and error paths.
- **`process/tag-vocabulary.md`** — controlled tag list including `@security-critical`.
- **`process/sequential-increments.md`** — decision record on the strictly-sequential policy.
- **`phases/NN-<slug>/standards-observations.md`** — rolling per-phase log; `technical-reviewer` appends. `phase-close` synthesizes into retrospective.
- **`phases/NN-<slug>/phase-log.md`** — consolidated step-log narrative; written by `phase-close`.
- **`increments/NNN-<slug>/scope.md`** — `code-changes: <yes|none>` flag; `@corrects:inc-NNN` if corrective; declared dependencies.
- **`increments/NNN-<slug>/plan.md`** — **Developer Context Manifest** is the explicit doc list the developer loads.

## 6. Workflow Phases

Phases are strictly sequential (§10). **[GATE]** = human approval required regardless of handover mode.

### Phase −1 — Session Resume (every session start)

- **Skill:** `session-resume`.
- **Does:** scans git state since last `delivered` increment; reconciles INDEX statuses; halts on undocumented main-branch commits (require corrective-increment backfill per §10); validates pinned skill versions (§13); routes to next step.
- **Possible routes:** `project-init` (no project), `phase-intake` (raw input present, no active phase), `increment-start` (phase active, no in-progress increment), resume in-progress skill, `phase-close` (last increment merged), or wait (paused).

### Phase 0 — Project Initialization (one-time)

- **Skill:** `project-init`.
- **Produces:** git repo; CI with unit tests, UI tests, **SCA**, and **secret scanner** unless explicitly overruled; full doc structure with INDEX stubs; seeded `workflow.md`, `tag-vocabulary.md`, `sequential-increments.md`, `increment-template.md`; baseline `coding-standards.md`, `testing-standards.md`, `naming-conventions.md`; verified dotfiles access with pinned versions.
- **Handover:** awaits raw input → `phase-intake` (via `session-resume`).

### Phase 1 — Phase Intake

- **Skill:** `phase-intake`.
- **Loads:** raw input + product-level indices (never re-reads prior phases' raw input).
- **Pass 1 produces:** `intake-review.md` with itemized gaps, conflicts, suggested defaults, **proposed initial area tags**. Each item requires individual approval.
- **[GATE 0]** Intake review approval. Approved defaults logged as CDRs/FDRs.
- **Pass 2 produces:** capability + aggregate updates with glossary authoring (§7 carve-out); proposed phase-level ADRs **numbered at this skill's Gate 1 approval** (§7 registering-skill rule); design direction; `scope.md`, `direction.md`, `roadmap.md`. Triggers Threat Considerations elaboration on capabilities classified > public or crossing trust boundaries.
- **[GATE 1]** Phase setup output review.
- **Amendment mode:** during an active phase, `phase-intake` can be re-invoked to process new/corrected raw input. Produces `intake-amendment-NN.md` reviewed at a new Gate 0'. Once `phase-close` runs, the phase is locked.
- **Handover:** → `increment-start` (via `session-resume`).

### Phase 2 — Increment Start

- **Skill:** `increment-start`.
- **Produces:** local branch refresh, prune merged local branches; dependency check; halt-trigger backstop on undocumented main-branch commits; new increment branch; `scope.md` draft incl. `code-changes` flag and `@corrects` if corrective; initialized `step-log.md`.
- **[GATE 2]** Increment scope approval.
- **Handover:** → `business-analyst` (or directly to `technical-reviewer` in doc-only mode).

### Phase 3 — Business Refinement

- **Skill:** `business-analyst`.
- **Produces:** refined capability specs; updated aggregates; glossary entries (§7 carve-out); DDRs/CDRs as needed; threat-question prompts surfaced on capabilities classified > public.
- **Handover:** → `functional-specifier`.

### Phase 4 — Functional Specification

- **Skill:** `functional-specifier`.
- **Produces:** new/updated `.feature` files tagged `@inc-NNN @phase-NN @<criticality>`; scenarios reference specific AC IDs via `# AC: AC-N` comments; flow + UI specs; FDRs as needed. UI gaps halted, not invented.
- **[GATE 3]** BDD scenario review.
- **Handover:** → `implementation-planner`.

### Phase 5 — Implementation Planning

- **Skill:** `implementation-planner`.
- **Produces:** `plan.md` with task list, components affected, ADRs to honor / proposed (dep-introducing ADRs include `Supply chain notes`), test plan with coverage strategy + exemptions, **Developer Context Manifest**.
- **Plan-size check:** soft cap of 8 tasks. Beyond it, halts and requires splitting.
- **[GATE 4]** Plan approval with plain-language ADR digest.
- **Handover:** → `developer`.

### Phase 6 — Development

- **Skill:** `developer`.
- **Loads:** ONLY the Developer Context Manifest plus the meta-skill always-allowed list (meta-skill §1).
- **Produces:** code, unit tests (≥80% on code paths; 100% line+branch on `@security-critical`-tagged paths' input-validation and error handling), updated component docs, ADR transitions (`proposed` → `accepted-pending-review`, or → `withdrawn` if the decision wasn't actually required — terminal). Commits to increment branch.
- **Glossary discipline:** new domain terms surfaced during implementation halt back upstream; developer does not author glossary entries.
- **Handover:** → `ui-test-engineer` (skipped in doc-only mode).

### Phase 7 — UI / Functional Testing

- **Skill:** `ui-test-engineer`.
- **Produces:** automated UI tests for `@inc-NNN`-tagged scenarios; full regression by tag. Security-critical scenarios include negative cases (input-validation failures, authz failures).
- **Handover:** → `technical-reviewer` (skipped in doc-only mode).

### Phase 8 — Technical Review

- **Skill:** `technical-reviewer`.
- **Produces:** `review.md` covering coding standards, plan alignment, coverage (incl. security-critical paths), ADR coherence, **security checklist** (secrets grep, logging-hygiene grep, input validation at trust boundaries, SCA results, AC coverage, dependency-trace against declared deps), and appends to `standards-observations.md`.
- **Retry budget:** 3 develop→review cycles. **On exhaustion: two paths only** — `abandon` (status → abandoned, no successor) or `revise scope` (open a corrective increment per §10).
- **Doc-only mode:** runs against doc diffs only; coverage and security-implementation checks skipped.
- **Handover:** on approval → `increment-close`.

### Phase 9 — Increment Close

- **Skill:** `increment-close`.
- **Produces:** invokes `doc-integrity` (utility carve-out, meta-skill §10) scoped to this increment; assigns final numbers to **increment-level** TBD decision records (§7 registering-skill rule); writes back-references on artifacts when `@corrects:inc-NNN` declared (`superseded-by-increment: inc-MMM`); consolidates `changelog.md`; updates INDEX files; pushes branch; prepares PR.
- **[GATE 5]** PR merge — **PR checklist explicitly separates "verified mechanically" from "needs human confirmation":**
  - *Mechanically verified:* coding standards pass, coverage targets met, CI green (tests + SCA + secret scan), regression clean, doc-integrity clean, cross-references resolved, AC coverage complete.
  - *Needs human confirmation:* threat-considerations answers reviewed, authn/authz declaration confirmed, security-critical classification correct, final merge action.
- **Handover:** human merges PR → next session's `session-resume` triggers either `increment-start` or `phase-close`.

### Phase 10 — Phase Close

- **Skill:** `phase-close`.
- **Trigger:** last increment of phase merged.
- **Produces:** `doc-integrity` full-sweep (utility carve-out); `phase-log.md` consolidation; archive per-increment step-logs (default) or delete (if `cleanup_step_logs: true`); `retrospective.md` including **workflow-defects synthesis** (from `learnings/`) and **standards-adequacy synthesis** (from `standards-observations.md`); updates `phases/INDEX.md`; triggers `skill-curator`.
- **Phase lock-in:** once `phase-close` runs, the phase is locked. Corrections route through corrective increments (§10), not re-running `phase-intake` on prior raw input.

### Phase 11 — Skill Curation (asynchronous)

- **Skill:** `skill-curator`.
- **Trigger:** `phase-close` or manual.
- **Produces:** `curator-report.md` classifying patterns, proposing skill updates. First-adopter rule: ≥3 occurrences in single project may promote with weaker recommendation.

## 7. Halt Triggers

Every skill halts and surfaces when any of these is true:

1. A required input doc is missing or empty.
2. Two docs make contradictory statements about the same subject.
3. A term used in an in-scope doc is not in `glossary.md` **and** the current skill does not have glossary-authoring permission. **Glossary-authoring carve-out:** any skill that creates an aggregate or capability spec (`phase-intake`, `business-analyst`) may author the corresponding glossary entry in the same step; the gate approving the artifact approves the entry. Other skills halt.
4. A technology, library, or framework is referenced without a justifying ADR (or the ADR is missing `Supply chain notes` when introducing a dependency).
5. A capability, scenario, flow, or screen references a component, aggregate, or artifact that doesn't exist, is `deprecated`, `superseded-by-increment`, or `withdrawn`.
6. A test fails in a way that contradicts a scenario's stated outcome.
7. The plan calls for work not justified by any in-scope capability or scenario.
8. A tag is used that isn't in `tag-vocabulary.md`.
9. **Decision-record numbering** — final numbers are assigned by the skill that **registers** the decision into its INDEX. Phase-level decisions (proposed in `phase-intake`) are numbered at Gate 1 approval by `phase-intake`. Increment-level decisions are numbered by `increment-close`. Any other skill needing a final number halts.
10. Coverage cannot reach the relevant target (80% baseline, or 100% line+branch on `@security-critical` paths' input validation/error paths) for non-trivial reasons.
11. The skill is asked to perform an action outside its declared scope. **Utility sub-skill exception:** `doc-integrity` is the only currently-declared utility sub-skill and may be invoked from `increment-close` and `phase-close` per meta-skill §10.
12. Pinned skill version not reachable in dotfiles (§13). Override available via recorded ADR.
13. Undocumented commits on main since last `delivered` increment (require corrective-increment backfill per §10).
14. Capability with data classification > public lacks completed Threat Considerations, Authn required, or Authz model fields.

## 8. Human Gates and Handover Modes

| # | Gate | Where |
|---|------|-------|
| 0 | Intake review | After `phase-intake` Pass 1 (or amendment) |
| 1 | Phase setup output | After `phase-intake` Pass 2 |
| 2 | Increment scope | After `increment-start` |
| 3 | BDD scenarios | After `functional-specifier` |
| 4 | Implementation plan | After `implementation-planner` |
| 5 | Increment close | After `technical-reviewer` approval — checklist separates mechanical vs. human-only confirmations |

**Handover toggle:** `auto | gated` per skill; project default in §15. Required gates and halt-trigger surfaces apply regardless of toggle.

## 9. Step Summary Protocol

Per meta-skill §5, including the `Grounded in:` field. `doc-integrity` lints existence/scope/currency of cited sources.

## 10. Sequential Increments (plus exceptions)

Increments run strictly sequentially. `increment-start` enforces by checking declared dependencies. Rationale: `/docs/process/sequential-increments.md`.

### Corrective increment pattern

When a delivered increment is structurally wrong:

- Subsequent increment declares `@corrects:inc-NNN` in `scope.md`.
- Includes a CDR or ADR identifying the defect explicitly.
- `increment-close` writes back-references on corrected artifacts: `superseded-by-increment: inc-MMM`.
- `doc-integrity` validates bidirectional supersession.
- Original increment files are preserved untouched.

### Hotfix exception (explicitly out-of-workflow)

Emergency production fixes may bypass the agentic workflow:

- Direct commit to main via traditional means.
- Mandatory back-fill as a corrective increment within the same week — enforced by `session-resume` halting on undocumented main-branch commits.

**CVE-triggered dependency upgrades:** route through the hotfix exception only when severity is high/critical **and** the affected code path is in use. Lower-severity CVEs route through a regular maintenance increment (often a small `code-changes: yes` increment). Decision recorded in the corrective increment's CDR.

### Doc-only increments

When `scope.md` declares `code-changes: none`, the chain runs:

`increment-start` → `business-analyst` (and/or other doc skills) → `technical-reviewer` (doc-review mode) → `increment-close`.

`developer` and `ui-test-engineer` are skipped. Coverage and security-implementation checks skipped; standards observations and doc-integrity still run. Typical uses: ADR supersession, glossary cleanup, tag-vocabulary refactor, naming-conventions revision, capability re-scoping without code, doc-integrity backlog burn-down.

## 11. Skills

Skills live in dotfiles. All inherit shared behavior from the **meta-skill** (`skills/_meta/SKILL.md`).

| Skill | Scope | Triggers from |
|-------|-------|---------------|
| `session-resume` | Reconcile state at session start, route to next step, enforce hotfix-backfill, validate pins | Every session start |
| `project-init` | Scaffold repo, doc structure, CI (tests + SCA + secret scan), verify dotfiles access | Manual (new project) |
| `phase-intake` | Raw input → intake review (or amendment) → phase-level outputs; numbers phase-level decisions | `session-resume` (raw input present) or after `phase-close` |
| `business-analyst` | Refines capabilities + domain + glossary; surfaces threat questions | `increment-start` |
| `functional-specifier` | BDD scenarios with AC references + UI specs; handles prototype gaps | `business-analyst` |
| `implementation-planner` | Plan with explicit context manifest, supply-chain notes, plan-size cap | `functional-specifier` |
| `developer` | Code + unit tests; runs tests locally; commits; ADR transitions incl. `withdrawn` | `implementation-planner` |
| `ui-test-engineer` | Automated UI tests; regression by tag; security-critical negative cases | `developer` |
| `technical-reviewer` | Code review, security checklist, AC coverage, dep-trace, standards observations | `ui-test-engineer` |
| `increment-start` | Open increment: branch refresh, dep check, main-commit halt-trigger, scope draft | `session-resume` (after a `delivered`) |
| `increment-close` | Numbers increment-level decisions, corrective back-refs, changelog, indices, PR with separated checklist | `technical-reviewer` |
| `phase-close` | Doc-integrity full sweep, phase-log consolidation, retro incl. workflow-defects + standards-adequacy | Last increment merged |
| `project-pause` | Clean pause state across indices + `pause-summary.md` | Manual |
| `skill-curator` | Cross-project + first-adopter learning curation | `phase-close` or manual |
| `doc-integrity` | Utility sub-skill: indices, cross-refs, tags, glossary, ADR + corrective bidirectional supersession, withdrawn-reference checks, Grounded-in: lint | `increment-close` (scoped), `phase-close` (full), manual |

## 12. Learnings and the Skill Curator

Two-tier: per-project (`/docs/process/learnings/<skill>.md`) and skill-level registry in dotfiles. First-adopter rule applies.

## 13. Skill Versioning and Pin Re-validation

- Semantic versioning. Projects pin in §15. Upgrades happen between phases, never mid-increment.
- **Pin re-validation** at every session start (via `session-resume` + meta-skill bootstrap check). Mismatch halts with structured surface.
- **Override path:** mid-phase pin failures are exceptional; require an explicit ADR recording the substitute version chosen, rationale, and forward-pin to nearest available newer version. Override logged for curator review.
- Phase-rollback-and-restart reserved for cases where forward-pin override isn't workable.

## 14. Deprecation and Lifecycle Patterns

Never physically deleted unless cleanup is explicitly requested.

- **Capabilities / components / aggregates:** status → `deprecated`, or `superseded-by-increment: inc-MMM` for corrective supersession. Files retained. CDR/DDR/ADR explains.
- **Scenarios:** moved to `/features/archived/<capability>.feature` with forward-link comment.
- **Decision records:**
  - `superseded` — replaced; bidirectional links.
  - `withdrawn` — terminal: a proposed decision the work didn't require. Future re-proposals get a *new* number, optionally linked via `previously-considered: ADR-NNNN`.
  - `rejected` — considered and not chosen.
- **Increments:**
  - `abandoned` — closed without delivering, no successor.
  - `delivered` and then `superseded-by-increment: inc-MMM` — corrected.

## 15. Pinned Skill Versions and Project Settings

| Skill | Version |
|-------|---------|
| session-resume | 1.0.0 |
| project-init | 1.0.0 |
| phase-intake | 1.0.0 |
| business-analyst | 1.0.0 |
| functional-specifier | 1.0.0 |
| implementation-planner | 1.0.0 |
| developer | 1.0.0 |
| ui-test-engineer | 1.0.0 |
| technical-reviewer | 1.0.0 |
| increment-start | 1.0.0 |
| increment-close | 1.0.0 |
| phase-close | 1.0.0 |
| project-pause | 1.0.0 |
| skill-curator | 1.0.0 |
| doc-integrity | 1.0.0 |

**Project-wide settings:**
- Default handover mode: `auto`
- Retry budget: 3 cycles, then abandon|revise-scope
- Test execution: local + CI (unit + UI + SCA + secret scan)
- Increment parallelism: sequential only (§10)

## 16. Security Posture (and known limitations)

Security is built into specific artifacts and checks, not into a dedicated security-reviewer skill (a generic agent without security expertise produces false confidence).

**Where security is built in:**

- **Capability spec:** `Data classification`, `Authn required`, `Authz model`, `Threat considerations` (questions for the human when classification > public or trust boundary crossed) as discrete fields. NFR `Security:` subsection for additional requirements.
- **Aggregate spec:** `Data classification`.
- **Tag vocabulary:** `@security-critical`, deterministically derived from data classification ≥ confidential.
- **Testing standards:** `@security-critical` paths require 100% line + branch coverage on input-validation and error paths.
- **Coding standards (seeded):** secrets-handling baseline; logging hygiene baseline (no PII fields matching known patterns, no authz tokens — grep-able).
- **CI defaults:** SCA + secret scanner alongside unit + UI tests, unless explicitly overruled.
- **ADRs introducing dependencies:** `Supply chain notes` section referencing SCA output.
- **Technical-reviewer checklist:** secrets-in-code grep, logging-hygiene grep, input validation at trust boundaries, SCA results, dep-trace check against declared `scope.md` deps.
- **Gate 5 PR checklist:** human-only confirmations for threat answers, authn/authz, security-critical classification, CI status.

**Known v1 limitations:**

- **Skills supply chain (signing / provenance):** pin re-validation protects against "pinned version disappeared" but not against "pinned version was modified in dotfiles by compromise." Skill signing is out of scope for v1.
- **Threat modeling depth:** the workflow surfaces questions for the human; it does not produce expert threat analysis.
- **Operational security:** incident response, vulnerability disclosure, penetration testing, formal audits are separate engagements.

**Floor, not ceiling.** This posture is defensible for solo agentic SDLC on pre-production or non-public-facing code. Anything landing in front of real users with real data should have an external security pass before go-live.
