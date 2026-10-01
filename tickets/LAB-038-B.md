# LAB-038-B: Operation Desk - Qualification

Full-contract state: specified. Planned wave: M1 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-038-A](LAB-038-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-038](../experiments/LAB-038.md). Payoff: Invoke one typed operation from UI and automation and compare receipts and undo.

## Acceptance

- UI/scenario yield equivalent state
- Duplicate request mutates once
- Undo restores exact prior state
- Failed validation emits error receipt
- Ambiguous target refuses mutation
- Stale revision rejects with current revision
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
