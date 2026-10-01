# LAB-011-A: Camera Rig - Implementation/deepening

Full-contract state: specified. Planned wave: M1 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-001-B](LAB-001-B.md).

Contract: [LAB-011](../experiments/LAB-011.md). Payoff: Try camera projection and occlusion behavior while moving through a readable course.

## Acceptance

- Camera avoids clipping in supported preset
- Projection label matches actual mode
- Player remains in declared safe frame
- Reset restores reference composition
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
