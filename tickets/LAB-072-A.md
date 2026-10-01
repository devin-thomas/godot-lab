# LAB-072-A: Music Conductor - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [LAB-071-B](LAB-071-B.md), [LAB-021-B](LAB-021-B.md).

Contract: [LAB-072](../experiments/LAB-072.md). Payoff: Change intensity on a beat boundary and inspect synchronized stems rather than abrupt restarts.

## Acceptance

- Transition occurs within declared beat tolerance
- Stem phases remain aligned
- Repeated same request causes no duplicate restart
- Reset clears pending switch
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, audio, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
