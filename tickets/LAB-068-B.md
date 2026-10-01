# LAB-068-B: Display Laboratory - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-068-A](LAB-068-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-068](../experiments/LAB-068.md). Payoff: Compare clean, pixel-scaled, palette and optional CRT output without weakening controls.

## Acceptance

- Profile visibly changes intended pixels
- Essential text remains legible in declared minimum viewport
- Simulation/input rate unchanged
- Disable returns clean reference
- Invalid dimensions reject
- Unsupported shader profile stays unavailable
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
