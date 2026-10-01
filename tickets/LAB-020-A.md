# LAB-020-A: Acoustic Rooms - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [LAB-005-B](LAB-005-B.md).

Contract: [LAB-020](../experiments/LAB-020.md). Payoff: Compare bus effects, reverb and filters while walking between simple acoustic spaces.

## Acceptance

- Reverb tail duration changes as specified
- Low-pass attenuates high-frequency fixture
- Master mute remains honored
- Exit leaves no active source/effect
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, audio, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
