# Tag Vocabulary

The controlled tag vocabulary used across all documentation. Every doc carries tags from this list. Tags drive selective context loading (filter by tag, load only matching docs).

Unknown tags trigger a halt (workflow.md §7 trigger 8). To add a tag, a skill halts with: proposed tag, definition, rationale (why no existing tag fits). The human approves; the approval updates this file.

## Tag categories

### Area tags (`@<domain-area>`)

Identify the business domain area or technical concern an artifact belongs to.

- **Onboarding note:** during the first `phase-intake` run, initial area tags are *proposed in Pass 1 alongside other approvals* so the first phase doesn't constantly halt on the first tag write. After that, new area tags follow the standard add-tag halt flow.

Examples (will vary per project):
- `@billing` — billing capabilities, aggregates, components
- `@auth` — authentication and authorization concerns
- `@reporting` — reporting and analytics
- `@admin` — admin/internal user functionality

### Criticality tags

Drive regression frequency, coverage targets, review depth.

- `@critical` — failure has major business impact; full regression every increment
- `@important` — failure has moderate impact; regression on related changes
- `@nice-to-have` — failure has minor impact; smoke regression

### Increment / phase tags

- `@inc-NNN` — applied to scenarios introduced or modified in increment NNN. Used by `ui-test-engineer` to filter the in-scope set.
- `@phase-NN` — applied to scenarios introduced or modified in phase NN. Used by `phase-close` for consolidation.

### Cross-cutting concern tags

- `@nfr` — applied to ADRs that address cross-cutting non-functional requirements (performance, reliability, observability, security in the broad sense).
- `@security-critical` — applied to components, scenarios, and tests touching data classified ≥ `confidential` per capability/aggregate Data classification fields, or crossing trust boundaries. **Deterministic from data classification, not ad-hoc.** Drives 100% line + branch coverage rule on input-validation and error paths per testing-standards.md.
- `@negative` — applied to negative-case scenarios (input-validation failures, authz failures). Required as a companion tag on negative scenarios paired with `@security-critical` happy-path scenarios.

### Lifecycle status tags (artifact metadata, not always tagged in the file body)

These are statuses on artifact rows in INDEX files rather than tags applied to content, but recorded here for completeness:

- `active`, `proposed`, `accepted`, `accepted-pending-review`, `delivered`, `in-progress`
- `deprecated`, `superseded`, `superseded-by-increment: inc-MMM`, `withdrawn` (terminal), `rejected`, `abandoned`

## Process for adding tags

1. Skill encounters need for a tag not in this list → halts (trigger 8).
2. Skill surfaces: proposed tag, one-line definition, why no existing tag fits.
3. Human approves; this file is updated.
4. Skill resumes.

Exception: during `phase-intake` Pass 1, multiple area-tag proposals can be approved as a batch alongside other intake items. This avoids the first-phase halt loop.

## Curated cross-project tags

Tags promoted to cross-project standard live in the curator registry. They appear in this list at project-init time. Project-specific tags added later are local until the curator promotes them (at which point new projects will get them seeded).
