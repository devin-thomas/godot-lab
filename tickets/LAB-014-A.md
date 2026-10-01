# LAB-014-A: Dialogue Machine - Implementation/deepening

Full-contract state: specified. Planned wave: M1 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-016](CORE-016.md), [LAB-006-B](LAB-006-B.md), [LAB-013-B](LAB-013-B.md).

Contract: [LAB-014](../experiments/LAB-014.md). Payoff: Choose branches in original dialogue and undo a choice without corrupting story state.

## Acceptance

- Choice reaches expected node
- Unavailable branch cannot mutate flags
- Undo restores preceding node/flags
- Same choices yield same ending
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
