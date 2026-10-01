# LAB-074-B: Statechart Playhouse - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-074-A](LAB-074-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-074](../experiments/LAB-074.md). Payoff: Manipulate a small character state machine and inspect guards, entry/exit and interrupted actions.

## Acceptance

- Allowed event reaches expected state
- Rejected guard leaves state unchanged
- Entry/exit hooks run once
- Interrupt cancels prior owned action
- Unknown event rejects
- Recursive transition budget catches loops
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
