# LAB-021-A: Time Laboratory - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-001-B](LAB-001-B.md), [LAB-002-B](LAB-002-B.md).

Contract: [LAB-021](../experiments/LAB-021.md). Payoff: See pause, time scaling and interpolation affect simulation without freezing the inspector.

## Acceptance

- Paused simulation position stays stable
- Inspector still accepts resume
- Scale changes elapsed simulation rate
- Reset restores timing settings
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
