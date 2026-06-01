# Design-system template (`design.md`)

`project-init` scaffolds this as `docs/permanent/design/design.md` — a **placeholder** the human replaces with the project's real design system before any UI work begins (the same discipline as the placeholder standards docs). The filename is always exactly `design.md`.

This file is **human-owned**: agents read it (it is in the `_meta` §1 always-allowed set), agents never edit it. When a needed component or token is missing, agents surface a design-gap to the human per `_meta` §17 rather than writing here.

The expected shape: YAML frontmatter carrying the authoritative token blocks (`colors`, `typography`, `rounded`, `spacing`, `motion`, `state`) plus a `components:` inventory, followed by human/agent-readable prose guidance. The frontmatter is the source of truth; where prose and frontmatter disagree, frontmatter wins.

```markdown
---
version: "0.1"                 # bump on every human change; significant changes also get an ADR
name: <project>-design-system
description: <one-paragraph identity statement — brand colors, type, shape language, layout frame>

# ── Foundation (brand-level, use-case agnostic; human-only — never agent-improvised) ──
colors:
  # <token>: "#rrggbb"
typography:
  # <token>: { fontFamily: <family>, fontSize: <px>, fontWeight: <n>, lineHeight: <n>, letterSpacing: <px> }
rounded:
  # <token>: <px | 9999px>
spacing:
  # <token>: <px>
motion:
  # duration-*/easing-* tokens
state:
  # hover/focus/overlay tokens

# ── Components (use-case layer; new use cases ADD components, not foundations) ──
components:
  # <component-name>:
  #   <property>: "{colors.*}" | "{typography.*}" | "{rounded.*}" | "{spacing.*}" | <literal>
---

> **Source of truth:** the YAML frontmatter above is authoritative for all tokens and components.
> The prose below is explanatory guidance. When prose and frontmatter disagree, frontmatter wins.
> Never hard-code a value that exists as a token.

## Overview
<identity, key characteristics>

## Colors / Typography / Layout / Elevation / Motion / Shapes
<guidance per block>

## Components
<per-component documentation: states, accessibility, composition notes>

## Do's and Don'ts
<usage rules>

## Implementation Rules
1. Focus on ONE component at a time; reference component names and tokens directly.
2. Never hard-code a hex, size, or radius — always reference a token.
3. Add new variants as separate `components:` entries rather than overloading existing ones.
4. Keep the foundation brand-level and use-case agnostic — new use cases add components, not foundations.
8. For any new status/level encoding, add a token mapping AND a legend — never color alone.

## Known Gaps
<what the system does not yet cover — read by agents when assessing whether a use case is in scope>
```

## How the workflow uses this file

- **`domain-design` (increment scope)** resolves every component/token a design-spec needs against this file. Direct match → reference it. Ambiguous or absent → halt with a `design-gap` return (`_meta` §4, §17); the orchestrator surfaces a design-decision prompt at Gate 2.
- **`increment-develop`** is a backstop: if implementation needs a component/token not here (and not an accepted provisional component), it halts with `design-gap`.
- **`increment-review`** checks design-system conformance: referenced components/tokens must exist here, or be an accepted provisional component logged in `design-deviations.md` with a non-`pending` debt disposition. Hard-coded values that duplicate a token fail.
- **`doc-integrity`** mechanically validates that every design-spec reference resolves to this file or to a logged provisional.
- **Foundation tokens are human-only.** Agents never improvise a new color/type/spacing value; a token gap always routes to the human (supply an updated `design.md` or accept the gap as debt).
- **Prototypes follow this spec.** The design system is the source of truth; a prototype that diverges from it is itself a design-gap and is surfaced as a design deviation — the prototype does not override the design system.
