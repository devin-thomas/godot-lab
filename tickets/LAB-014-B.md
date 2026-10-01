# LAB-014-B: Dialogue Machine - Qualification

State: specified. Planned wave: M1 (future lab).
Depends on: [LAB-014-A](LAB-014-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-014](../experiments/LAB-014.md). Payoff: Choose branches in original dialogue and undo a choice without corrupting story state.

## Acceptance

- Choice reaches expected node
- Unavailable branch cannot mutate flags
- Undo restores preceding node/flags
- Same choices yield same ending
- Unknown choice rejects
- Cycle without progress trips bounded traversal guard
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
