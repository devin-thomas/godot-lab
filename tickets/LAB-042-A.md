# LAB-042-A: 2D Movement - Implementation/deepening

Full-contract state: specified. Planned wave: M1 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-007-B](LAB-007-B.md), [LAB-012-B](LAB-012-B.md).

Contract: [LAB-042](../experiments/LAB-042.md). Payoff: Compare forgiving jump controls with exact collision in a compact2D platform course.

## Acceptance

- Wall remains solid
- Coyote jump succeeds only inside window
- Buffered jump fires once on landing
- Assist-off preserves strict collision
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
