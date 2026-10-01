# LAB-074-A: Statechart Playhouse - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-016](CORE-016.md), [LAB-038-B](LAB-038-B.md), [LAB-041-B](LAB-041-B.md), [LAB-021-B](LAB-021-B.md).

Contract: [LAB-074](../experiments/LAB-074.md). Payoff: Manipulate a small character state machine and inspect guards, entry/exit and interrupted actions.

## Acceptance

- Allowed event reaches expected state
- Rejected guard leaves state unchanged
- Entry/exit hooks run once
- Interrupt cancels prior owned action
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
