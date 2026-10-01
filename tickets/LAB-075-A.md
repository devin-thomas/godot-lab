# LAB-075-A: Quest Weave - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-016](CORE-016.md), [LAB-074-B](LAB-074-B.md), [LAB-038-B](LAB-038-B.md), [LAB-006-B](LAB-006-B.md).

Contract: [LAB-075](../experiments/LAB-075.md). Payoff: Complete original objectives in different orders and inspect dependency and undo semantics.

## Acceptance

- Prerequisite guards hold
- Duplicate event awards once
- Alternate valid order yields same required completion
- Undo follows declared dependency policy
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
