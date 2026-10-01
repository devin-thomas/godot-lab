# LAB-038-A: Operation Desk - Implementation/deepening

State: specified. Planned wave: M1 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-016](CORE-016.md), [LAB-006-B](LAB-006-B.md), [LAB-025-B](LAB-025-B.md).

Contract: [LAB-038](../experiments/LAB-038.md). Payoff: Invoke one typed operation from UI and automation and compare receipts and undo.

## Acceptance

- UI/scenario yield equivalent state
- Duplicate request mutates once
- Undo restores exact prior state
- Failed validation emits error receipt
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
