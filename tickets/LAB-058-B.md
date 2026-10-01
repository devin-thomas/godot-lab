# LAB-058-B: World Clock - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-058-A](LAB-058-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-058](../experiments/LAB-058.md). Payoff: Advance a scoped day/weather clock and inspect gameplay triggers and visual change separately.

## Acceptance

- Seek sets expected environment state
- Event fires once at threshold
- Pause freezes world schedule
- Replay yields same semantic event order
- Negative/out-of-range tick rejects
- Duplicate event ID refuses schedule
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
