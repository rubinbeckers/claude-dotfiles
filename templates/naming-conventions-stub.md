# Naming Conventions

Project-specific naming conventions. Filled in by project setup or refined via standards-adequacy synthesis.

The workflow itself doesn't mandate naming conventions (those are language- and team-specific), but the file is required so naming-related observations during phase have somewhere to consolidate.

## Files and directories

*(File case conventions, directory structures, special filename patterns)*

## Source code identifiers

- **Modules / files:** *(snake_case, kebab-case, etc.)*
- **Classes / types:** *(PascalCase, etc.)*
- **Functions / methods:** *(camelCase, snake_case)*
- **Constants:** *(SCREAMING_SNAKE_CASE)*
- **Variables:** *(camelCase, snake_case)*
- **Test files:** *(naming pattern)*

## Documentation

- **Markdown filenames:** kebab-case (workflow default; project may override).
- **Headings:** Title Case for top-level, Sentence case for sub-headings (workflow default).
- **Decision records:** `<TYPE>-NNNN-<slug>.md` where NNNN is zero-padded 4-digit.

## Domain language

- Names of aggregates, entities, value objects, and behaviors match the ubiquitous language in `/docs/business/domain/glossary.md`.
- Capabilities are named in `<verb>-<noun>` or `<noun>-<verb>` form (project chooses convention).

## Increments and phases

- Increments: `inc-NNN` where NNN is zero-padded 3-digit.
- Phases: `NN-<slug>` where NN is zero-padded 2-digit (phase number).
- Branches: `increment/NNN-<slug>` for increment branches.

## Notes

- Naming conventions here are enforced by code review and the technical-reviewer's standards check.
- Mismatches are surfaced to `standards-observations.md`; recurring patterns may motivate adding explicit rules here via a doc-only increment.
