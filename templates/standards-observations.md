# Standards Observations — Phase NN: <slug>

Rolling log appended to by `technical-reviewer` (and occasionally `developer` when self-flagging) whenever a standards-related issue is surfaced, whether blocking or not.

Synthesized into the retrospective's standards-adequacy section at `phase-close`.

## Format

One line per observation:

```
[ISO timestamp] [skill] [inc-NNN] [category] one-line description
```

**Categories:** `coding` | `testing` | `naming` | `security` | `other`

## Examples

```
2026-05-11T14:23:00Z [technical-reviewer] [inc-007] [naming] PascalCase used for module file; convention is snake_case
2026-05-11T14:24:00Z [technical-reviewer] [inc-007] [coding] Function exceeds suggested length (60 lines) — no project rule yet
2026-05-11T15:01:00Z [technical-reviewer] [inc-008] [security] Input validation missing on /api/orders POST body — added in cycle 2
2026-05-11T15:01:30Z [technical-reviewer] [inc-008] [testing] Coverage exemption for retry-helper.ts — pattern not in exemption taxonomy
2026-05-11T16:30:00Z [developer] [inc-008] [coding] Worked around eslint rule with disable-next-line — rule may need revisit
```

## Synthesis at phase-close

`phase-close` reads this file and groups by category. For each cluster of observations suggesting a standards-update opportunity, it proposes specific text changes to `coding-standards.md`, `testing-standards.md`, `naming-conventions.md`, or the security baseline in `coding-standards.md`.

Proposed updates surface in the retrospective; approved updates become a doc-only increment in the next phase.
