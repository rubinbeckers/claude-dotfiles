# Coding standards (placeholder)

This file is scaffolded by `project-init` so that the always-allowed-read set (`_meta` §1) resolves on day one. The first phase's `technical-design` agent populates it with project-specific standards, and subsequent phases append or supersede via `workflow-curator` synthesis at `phase-close`.

## Style

<Language-specific style rules go here — formatter config, lint rules, max line length, etc.>

## Structure

<File and module organisation conventions — folder layout, module size limits, public/private API conventions.>

## Error handling

<How errors are raised, propagated, logged. What "exceptional" means vs. expected failure modes returned as values.>

## Logging

<Levels, structure, what to log and what not to. Sensitive-data exclusions.>

## Secret handling

<Where secrets live (env vars, vaults), how they're consumed in code, how to test code that uses them without exposing them.>

## Comments

<When to comment, when not to. Justification-comment convention for deviations from these standards.>

## Performance considerations

<Hot-path conventions, allocation patterns to avoid, etc. — project-specific.>

## Security

<Input validation conventions at trust boundaries. Output encoding. Auth/authz conventions in code.>

## Discovery scope (per `_meta` §5)

For the purposes of the develop agent's "discovery scope" — what type/interface declarations it may read outside its manifest without halting — this project considers the following "declaration files":

<List language-specific declarations: e.g. `*.d.ts`; type-only sections of `*.ts` / `*.tsx`; Python `*.pyi`; Go interface declarations; etc.>

Behavioural code (function bodies, controllers, components, services) outside the manifest still requires expansion.
