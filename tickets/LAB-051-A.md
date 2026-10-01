# LAB-051-A: Cloth Sail - Implementation/deepening

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-002-B](LAB-002-B.md), [LAB-035-B](LAB-035-B.md).

Contract: [LAB-051](../experiments/LAB-051.md). Payoff: Pin and release a small soft-body sail and inspect deformation and collision cost.

## Acceptance

- Pinned point follows target
- Released corner deforms visibly
- Supported collider prevents declared intersection tolerance
- Reset restores undeformed mesh
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
