# LAB-045-A: Platform Ferry - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-001-B](LAB-001-B.md), [LAB-021-B](LAB-021-B.md).

Contract: [LAB-045](../experiments/LAB-045.md). Payoff: Ride translating/rotating platforms and compare inherited velocity on departure.

## Acceptance

- Player tracks deck during ride
- Departure policy changes measured velocity
- Collision stays aligned during turn
- Reset removes accumulated platform motion
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
