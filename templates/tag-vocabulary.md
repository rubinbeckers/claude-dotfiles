# Tag vocabulary template

Project-wide tag definitions. Lives at `docs/permanent/process/tag-vocabulary.md`. Per workflow.md §15.9, every tag used on any record must be defined here. `doc-integrity` validates tag usage against this vocabulary.

```markdown
# Tag vocabulary

Owner: project-wide; changes proposed at improvement-review or appended at the gate where the first record using a new tag is approved.

## Criticality tags
| Tag | Meaning | Applied to |
|-----|---------|------------|
| `@critical` | System-critical path; failure has outsized impact | Scenarios, items, ADRs, NFRs |
| `@high` | High-priority behavior | Scenarios, items |
| `@medium` | Normal priority | Scenarios, items |
| `@low` | Low priority / nice-to-have | Scenarios, items |

## Security tags
| Tag | Meaning | Applied to |
|-----|---------|------------|
| `@security-critical` | Path covered by capability data_classification ≥ confidential, or touches auth/authz | Scenarios, items, ADRs |
| `@nfr` | Cross-cutting non-functional concern | ADRs |

## Test-suite tags
| Tag | Meaning | Applied to |
|-----|---------|------------|
| `@smoke` | Part of the smoke regression suite per testing-standards.md | Tests |
| `@error-path` | Tests an error or recovery scenario | Scenarios, tests |

## Domain-area tags (project-specific)

Define one entry per domain area in the project. New entries added at the gate that first introduces them.

| Tag | Meaning | Examples |
|-----|---------|----------|
| `@<domain-area>` | <description> | <capabilities or flows that exemplify> |

## Lifecycle tags
| Tag | Meaning | Applied to |
|-----|---------|------------|
| `@phase-NN` | Tags work associated with phase NN | Records, ADRs |
| `@inc-NNN` | Tags work associated with increment NNN | Records, items |

## Status tags (rarely used as tags — usually carried in the `status:` field)
| Tag | Meaning |
|-----|---------|
| `@proposed` | Reserved for ambiguous boundary cases where the status field doesn't apply |
| `@deprecated` | Same |

## Conventions

- Tags are lowercase with hyphens. Multi-word tags are kebab-cased (`@security-critical`, not `@securityCritical`).
- Every tag used on any record must be defined here. Halt and add the definition before the record's gate.
- New domain-area tags need a short description and ≥1 example.
- Tags are append-only — old tags don't get deleted even when no longer used (avoids breaking historical records).
```
