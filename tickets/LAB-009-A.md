# LAB-009-A: Particle Weather - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [CORE-018](CORE-018.md), [LAB-004-B](LAB-004-B.md), [LAB-036-B](LAB-036-B.md).

Contract: [LAB-009](../experiments/LAB-009.md). Payoff: Tune a storm and compare CPU/GPU particle behavior under a bounded budget.

## Acceptance

- Particle count stays within cap
- Lifetime changes visible persistence
- Backend comparison records actual renderer and timing
- Reset leaves no active emitter
- 2D/3D comparison records the actual dimensional fixture and supported backend
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
