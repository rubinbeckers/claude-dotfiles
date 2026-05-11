# skill-curator

- **Name:** skill-curator
- **Version:** 1.0.0
- **Purpose:** Process project-level learnings and propose skill updates for human approval. Cross-project pattern detection with first-adopter rule.
- **Triggers from:** `phase-close` (automatic) or manual invocation.
- **Inputs:**
  - All `/docs/process/learnings/<skill>.md` files from the just-closed phase.
  - `/docs/phases/NN-<slug>/retrospective.md` (especially workflow-defects synthesis section).
  - Curator's registry in dotfiles: cross-project occurrence counts for each pattern.
  - Plus meta-skill §1 always-allowed.
- **Outputs:**
  - `/docs/phases/NN-<slug>/curator-report.md` — classified patterns with proposed skill updates and rationale, each tagged with confidence level.
  - Updated registry in dotfiles (occurrence counts incremented).
  - Surfaced for human approval; approved updates become new skill versions in dotfiles.
- **Hands off to:** Human (for approval of proposed updates).
- **Inherits:** Meta-skill.
- **Utility sub-skill:** no.

## Skill-specific halt triggers

- T-SC-1: Learnings files unreadable.
- T-SC-2: Dotfiles registry unreachable (degraded mode: project-level only, flag in report).
- T-SC-3: Proposed update would create conflict with another approved-but-not-yet-released update.

## Process

1. **Ingest learnings.** Read each `learnings/<skill>.md` file from this phase. Each entry has: observation, trigger, resolution, generalizable flag.

2. **Pattern detection.** Group entries by:
   - Same skill, similar trigger → potential skill clarification.
   - Cross-skill, same root cause → potential workflow update.
   - Same artifact type, repeated halt → potential template update.

3. **Cross-reference with registry.** For each pattern detected, look up occurrence count in dotfiles registry.

4. **Apply promotion rules:**

   | Signal | Recommendation strength |
   |--------|-------------------------|
   | ≥2 projects, ≥3 occurrences each | **Strong:** propose codification |
   | 1 project, ≥3 occurrences (**first-adopter rule**) | **Moderate:** propose with weaker recommendation flag |
   | <3 occurrences in this project | **Track-only:** increment registry, no proposal yet |

   The first-adopter rule recognizes that a pattern repeatedly seen in one project may still be worth codifying — the project is the canary. But the proposal is flagged as "first-adopter" so the human knows the evidence base is single-project.

5. **Generate proposals.** For each pattern reaching propose threshold:
   - Identify target (which skill or template).
   - Draft specific change (the actual proposed text).
   - Cite evidence (project entries referenced).
   - Confidence level: strong / moderate (first-adopter) / track-only.

6. **Write `curator-report.md`.** Sections:
   - Patterns detected this phase.
   - Proposed updates (each with target, change, evidence, confidence).
   - Track-only patterns (incremented but not proposed).
   - Registry diff (what was incremented).

7. **Surface for human approval.** Approved proposals become skill version bumps in dotfiles. Human decides timing of pin update in `workflow.md` §15.

8. **Step summary.**

## Notes

- The skill never auto-modifies a skill in dotfiles. Human approval is mandatory.
- The first-adopter rule is a deliberate trade-off: it accepts the risk of project-specific noise being codified for the benefit of acting on signal rather than waiting indefinitely for a second project.
- The registry in dotfiles is the cross-project memory. A learning from one project bumps the count for that pattern, contributing to future strong-promotion thresholds.
- "Skill version bumps" produce new pinned versions; existing projects keep their pins until they explicitly bump (between phases per workflow.md §13).
