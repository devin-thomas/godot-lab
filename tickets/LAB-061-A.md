# LAB-061-A: Vertex Shade - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-013](CORE-013.md), [LAB-004-B](LAB-004-B.md), [LAB-035-B](LAB-035-B.md).

Contract: [LAB-061](../experiments/LAB-061.md). Payoff: Paint broad shade on geometry and inspect interpolation and triangulation before adding lights.

## Acceptance

- Color data reaches shader
- Ramp follows intended vertices
- Triangulation artifact is visible/labeled
- Reset restores attribute hash
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
