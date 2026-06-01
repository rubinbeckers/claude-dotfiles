# Design-deviations template

Scaffolded by `project-init` as an empty header file at `docs/permanent/design/design-deviations.md`. **Append-only and permanent** — every departure from `design.md` is recorded here regardless of its debt disposition, so a reader can answer "where, and why, have we diverged from the design system?" in one place.

The deviation log is the **index**; the fix/accept choice is held in the existing debt files: a deviation classed as phase debt is an ordinary `phase-debt.md` entry (`category: design-deviation`) that the solidifying increment drains; one classed as accepted is an ordinary `accepted-debt.md` entry. No new debt machinery — this reuses what already exists.

A deviation arises in four ways (`_meta` §17):
1. A needed **component** is absent and the human chose "design from guidelines" (provisional component authored into the design-spec).
2. A needed **foundation token** is absent and the human accepted the gap (tokens are never agent-improvised).
3. A **prototype** diverges from `design.md` (the design system wins; the divergence is logged).
4. The human supplied an updated `design.md` — recorded with `resolution: human-updated-design-md`, `debt_class: none` (no debt, but the deviation event is still logged for history).

```markdown
# Design deviations: <project-slug>

(Append-only. Every divergence from design.md, with its resolution and debt routing.)

## Entries

### dev-001 — <one-line: what diverged / was improvised>

- logged_at: <ISO>
- source: <skill or agent that surfaced it>
- increment: <phase-slug>/<inc-slug>
- kind: component | token | prototype
- use_case: <what design was needed / where the prototype diverged>
- resolution: human-updated-design-md | designed-from-guidelines | accepted-gap
- debt_class: phase-debt | accepted | none        # none only when human updated design.md
- provisional_component: <name + design-spec path>   # if designed-from-guidelines
- guidelines_basis: <which design.md rules/tokens the improvisation followed>
- debt_ref: <link to phase-debt.md or accepted-debt.md entry, if any>
- reconciled_at: null                              # set when the solidifying increment or human closes it
- reconciled_in: null                              # increment/DR that reconciled it

### dev-002 — <one-line>

...
```

## Discipline

- **Append-only.** Entries are never edited or deleted. When a phase-debt deviation is reconciled (e.g., the human folds the provisional component into `design.md` and the solidifying increment refactors usage), append `reconciled_at:` / `reconciled_in:` rather than removing the entry.
- **No `pending` survives a drain.** `doc-integrity` flags any deviation whose `debt_class: phase-debt` entry is still `pending` past the solidifying-increment-design drain step, mirroring the phase-debt rule.
- **Permanent and always-readable.** Part of `docs/permanent/design/`; in the `_meta` §1 always-allowed set so review and integrity can consult it without a manifest entry.
