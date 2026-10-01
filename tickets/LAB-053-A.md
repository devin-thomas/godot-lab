# LAB-053-A: Ballistics Tunnel - Implementation/deepening

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-002-B](LAB-002-B.md), [LAB-052-B](LAB-052-B.md).

Contract: [LAB-053](../experiments/LAB-053.md). Payoff: Fire fast objects at thin obstacles and compare discrete/continuous collision behavior.

## Acceptance

- Continuous path detects declared plate under tested profile
- Discrete misses are recorded honestly
- Hit time/location bounded
- Projectile count never exceeds cap
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
