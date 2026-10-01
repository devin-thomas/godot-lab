# LAB-045-B: Platform Ferry - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-045-A](LAB-045-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-045](../experiments/LAB-045.md). Payoff: Ride translating/rotating platforms and compare inherited velocity on departure.

## Acceptance

- Player tracks deck during ride
- Departure policy changes measured velocity
- Collision stays aligned during turn
- Reset removes accumulated platform motion
- Unknown route rejects
- Blocked deck follows declared stop policy
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
