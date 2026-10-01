# LAB-041-B: Signal Switchboard - Qualification

Full-contract state: specified. Planned wave: M1 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-041-A](LAB-041-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-041](../experiments/LAB-041.md). Payoff: Wire events between scene objects and inspect ordering, disconnection and duplicate subscription.

## Acceptance

- One emit invokes one registered receiver
- Duplicate connect does not multiply effects
- Freed receiver is removed safely
- Event trace order matches declared ordering
- Invalid payload rejects
- Missing receiver reports unavailable route
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
