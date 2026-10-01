# LAB-004-B: Paint & light - Qualification

State: specified. Planned wave: M1 baseline deepening (separate depth, not historical completion).
Depends on: [LAB-004-A](LAB-004-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-004](../experiments/LAB-004-EXPANSION.md). Payoff: Separate painted shade, matte light and vertex shade on comparable geometry.

## Acceptance

- Qualify separate new depth: Develop original atlas/UV and vertex-color round-trip examples.
- Qualify separate new depth: Add identical-fixture renderer and shader-profile comparisons.
- Qualify separate new depth: Compare lighting/bake/gradient-card roles and optional display modes.
- Qualify separate new depth: Use regional visual assertions plus documented human art review limits.
- Define and run a depth-specific positive assertion and disabled/broken-path negative control for each new requirement; historical seals are regression only
- Active mode cycles and labels agree
- Middle/right references stay stable
- Rendered capture contains actual game pixels
- Reset returns authored mode
- Unknown lab identifier refuses entry
- Missing shader or texture fails resource loading rather than inventing a passing material result
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
