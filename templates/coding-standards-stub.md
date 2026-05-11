# Coding Standards

Project-specific coding standards. Filled in during project setup or as standards observations accumulate.

The baseline items below are workflow-mandated (seeded by `project-init`). Language and stack-specific rules are added by the project.

## Baseline (workflow-mandated)

### Secrets handling

- **Never commit secrets** (API keys, passwords, tokens, credentials) to version control. This is enforced by the CI secret-scanner; commits with secrets are blocked.
- **Local development secrets** live in `.env` files (gitignored) or the project's chosen secret manager. Never in source code, never in checked-in config.
- **Production secrets** are sourced from the platform's secret manager (AWS Secrets Manager, Vault, etc.). The project's deployment ADR documents the choice.
- Code references secrets via env variables or secret-manager API calls, never literals. Even placeholder literals (`"REPLACE_ME"`) are forbidden — use clearly-named env vars.

### Logging hygiene

- **Never log sensitive fields.** The technical-reviewer runs grep checks for known patterns:
  - PII field names: `email`, `password`, `ssn`, `dob`, `phone`, `address` (project may extend this list)
  - Auth fields: `token`, `authorization`, `bearer`, `cookie`, `session_id`, `api_key`
- Log at appropriate levels: `error` for failures requiring action, `warn` for unusual conditions, `info` for significant events, `debug` for development. Avoid `info` floods.
- Include correlation IDs / request IDs for traceability.
- For security-relevant events (authn failures, authz denials, validation failures on capabilities classified ≥ confidential), log as `warn` or `info` with sufficient context for incident analysis — but without logging the offending input data itself.

### Input validation at trust boundaries

- Every entry point that accepts external data (HTTP handlers, message queue consumers, file uploads) validates inputs at the boundary before any business logic runs.
- Validation failures return clear errors without leaking internal state.
- For `@security-critical` paths, input validation is covered to 100% line + branch (testing-standards.md).

## Language / stack standards (project fills in)

*(Add language-specific style rules, module patterns, error-handling conventions, dependency conventions, etc.)*

### Style

- *(Indentation, line length, etc.)*

### Module and file structure

- *(Naming, organization, exports)*

### Error handling

- *(Exception/error patterns, when to throw vs. return, error types)*

### Dependencies

- *(How new deps are introduced; ADR requirement; preferred patterns)*

### Comments and docstrings

- *(When to comment, format)*

## Notes

- This file is added to or refined via doc-only increments triggered by the standards-adequacy synthesis at `phase-close`.
- Project-specific exceptions to baseline items must be documented as an ADR.
