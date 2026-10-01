# LAB-061-B: Vertex Shade - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-061-A](LAB-061-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-061](../experiments/LAB-061.md). Payoff: Paint broad shade on geometry and inspect interpolation and triangulation before adding lights.

## Acceptance

- Color data reaches shader
- Ramp follows intended vertices
- Triangulation artifact is visible/labeled
- Reset restores attribute hash
- Unknown vertex rejects
- Wrong color count refuses mutation
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
