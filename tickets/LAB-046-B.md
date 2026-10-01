# LAB-046-B: Aim Range - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-046-A](LAB-046-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-046](../experiments/LAB-046.md). Payoff: Compare ray, shape and projectile targeting with readable occlusion and collision masks.

## Acceptance

- Occluder prevents hidden target hit
- Ray/shape outcomes match documented geometry
- Mask excludes declared targets
- Hit receipt identifies stable object and position
- Zero-length query rejects
- Invalid mask/profile returns explicit error
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
