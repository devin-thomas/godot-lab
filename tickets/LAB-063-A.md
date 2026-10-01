# LAB-063-A: Stepped Animation - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-013](CORE-013.md), [LAB-008-B](LAB-008-B.md), [LAB-021-B](LAB-021-B.md).

Contract: [LAB-063](../experiments/LAB-063.md). Payoff: Compare stepped pose sampling with smooth simulation/camera response.

## Acceptance

- Pose changes follow selected cadence
- Physics remains at declared tick
- Camera input remains responsive
- Same clip duration retained
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
