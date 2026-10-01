# LAB-063-B: Stepped Animation - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-063-A](LAB-063-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-063](../experiments/LAB-063.md). Payoff: Compare stepped pose sampling with smooth simulation/camera response.

## Acceptance

- Pose changes follow selected cadence
- Physics remains at declared tick
- Camera input remains responsive
- Same clip duration retained
- Non-positive cadence rejects
- Missing clip refuses playback
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
