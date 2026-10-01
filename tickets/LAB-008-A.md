# LAB-008-A: Animation Loom - Implementation/deepening

State: specified. Planned wave: M1 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-001-B](LAB-001-B.md).

Contract: [LAB-008](../experiments/LAB-008.md). Payoff: Blend locomotion with a gesture and inspect transition timing rather than swapping clips blindly.

## Acceptance

- Speed changes weights continuously
- Gesture ends in intended state
- Repeated interruption never sticks
- Visible feet/pose match state trace
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
