# LAB-077-A: Inventory Alchemy - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-016](CORE-016.md), [LAB-018-B](LAB-018-B.md), [LAB-038-B](LAB-038-B.md), [LAB-006-B](LAB-006-B.md).

Contract: [LAB-077](../experiments/LAB-077.md). Payoff: Combine original items and inspect transactional recipes, limits and undo.

## Acceptance

- Recipe consumes/produces exact quantities
- Duplicate request crafts once
- Capacity failure leaves inventory unchanged
- Undo restores prior counts
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
