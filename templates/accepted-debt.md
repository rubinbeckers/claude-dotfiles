# Accepted technical debt (permanent record)

Scaffolded by `project-init` as an empty file. Append-only over the project's lifetime — every entry is debt the team consciously chose not to fix.

This record is permanent: a reader twelve phases later can answer "what did we know was broken and decided to live with?" by reading this file. The discipline is that nothing gets here silently — every entry is the result of a human disposition at a solidifying-increment drain step (`workflow.md` §9), so each accepted-debt entry carries the rationale chain.

```markdown
# Accepted technical debt

## Entries

### acc-debt-001 — <one-line description>

- accepted_at: <ISO>
- accepted_in_phase: <phase-slug>
- accepted_in_increment: <inc-NNN-<solidifying-slug>>
- originally_logged_at: <ISO>
- source: <skill or agent that originally logged it>
- category: discovered-defect | flaky-test | refactor | standards-observation | regression | design-deviation
- severity: low | medium | high
- size_estimate: S | M | L
- description: |
  <Multi-line description, copied from the original phase-debt entry.>
- affected_code: <path, if applicable>
- rationale: |
  <Why the human chose to accept rather than fix. Free text.>
- references:
  - <links to original phase-debt entry, observations, etc.>

### acc-debt-002 — <one-line>

...
```

## Discipline

- **Append-only.** Entries don't get edited or removed. If accepted debt is later fixed (e.g., as part of a normal feature increment that incidentally resolves it), append a `resolved_at:` and `resolved_in_increment:` to the entry rather than deleting it — the historical record survives.
- **No silent additions.** Entries arrive only via human disposition at a solidifying-increment drain. Skills and agents don't write here.
- **Permanent and always-readable.** Per `doc-structure.md` §1, this file is part of `docs/permanent/architecture/` and is referenced by `doc-integrity` at close gates. The reviewer at any future increment can check whether their work is unintentionally re-introducing accepted debt or unintentionally fixing it.
