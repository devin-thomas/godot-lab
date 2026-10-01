# LAB-048-B: Joint Arcade - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-048-A](LAB-048-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-048](../experiments/LAB-048.md). Payoff: Connect2D bodies with pin/spring/groove joints and inspect limits and break policy.

## Acceptance

- Pin maintains declared pivot tolerance
- Spring response changes with profile
- Slider stays within allowed travel
- Reset restores baseline linkage
- Missing body refuses joint
- Negative/invalid parameters reject before mutation
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
