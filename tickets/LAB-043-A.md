# LAB-043-A: Combat Clock - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-008-B](LAB-008-B.md), [LAB-021-B](LAB-021-B.md), [LAB-052-B](LAB-052-B.md).

Contract: [LAB-043](../experiments/LAB-043.md). Payoff: Land a readable attack and inspect hitboxes, invulnerability, hitstop and cancel timing.

## Acceptance

- One swing damages target once
- Hitstop pauses intended actors while UI remains active
- Cancel accepted only in window
- Invulnerability suppresses declared hits
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, audio, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
