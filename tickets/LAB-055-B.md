# LAB-055-B: Grid Tactics - Qualification

State: specified. Planned wave: M2 (future lab).
Depends on: [LAB-055-A](LAB-055-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-055](../experiments/LAB-055.md). Payoff: Plan and execute a turn on a2D grid with cost, occupancy and undoable commands.

## Acceptance

- Preview respects blocked/occupied cells
- Committed cost matches preview
- One unit occupies one cell
- Undo restores previous turn and positions
- Stale preview rejects
- Insufficient movement budget refuses commit
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
