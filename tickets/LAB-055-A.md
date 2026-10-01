# LAB-055-A: Grid Tactics - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [CORE-012](CORE-012.md), [LAB-007-B](LAB-007-B.md), [LAB-038-B](LAB-038-B.md).

Contract: [LAB-055](../experiments/LAB-055.md). Payoff: Plan and execute a turn on a2D grid with cost, occupancy and undoable commands.

## Acceptance

- Preview respects blocked/occupied cells
- Committed cost matches preview
- One unit occupies one cell
- Undo restores previous turn and positions
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
