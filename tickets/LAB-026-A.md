# LAB-026-A: Editor Toolroom - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-008](CORE-008.md), [CORE-013](CORE-013.md), [LAB-018-B](LAB-018-B.md).

Contract: [LAB-026](../experiments/LAB-026.md). Payoff: Build a small editor panel that changes scene data with working undo/redo.

## Acceptance

- Edit affects selected node only
- Undo restores previous value
- Redo reapplies exact value
- Plugin disable releases docks/hooks
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, editor, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
