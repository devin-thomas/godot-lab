# LAB-071-A: Mixer Desk - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [LAB-005-B](LAB-005-B.md), [LAB-020-B](LAB-020-B.md).

Contract: [LAB-071](../experiments/LAB-071.md). Payoff: Route original stems into lab-owned buses and inspect gain, solo and clipping safely.

## Acceptance

- Gain change follows measured RMS ratio
- Solo leaves selected stem only
- Clipping/limiter result reported
- Exit leaves user's unrelated audio untouched
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, audio, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
