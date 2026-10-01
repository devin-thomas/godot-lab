# LAB-002-A: Gravity foundry - Implementation/deepening

State: specified. Planned wave: M1 baseline deepening (separate depth, not historical completion).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md).

Contract: [LAB-002](../experiments/LAB-002-EXPANSION.md). Payoff: Launch a weighted cube and inspect actual impulse, contacts and settling.

## Acceptance

- Add mass/friction/restitution sweeps with recorded tolerances.
- Compare jointed mechanisms and high-speed collision.
- Expose contact/impulse diagnostics and meaningful reset receipts.
- Measure solver/resource costs across recorded engine/backend profiles.
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
