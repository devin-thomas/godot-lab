# LAB-002-B: Gravity foundry - Qualification

Full-contract state: specified. Planned wave: M1 baseline deepening (separate depth, not historical completion). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-002-A](LAB-002-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-002](../experiments/LAB-002-EXPANSION.md). Payoff: Launch a weighted cube and inspect actual impulse, contacts and settling.

## Acceptance

- Qualify separate new depth: Add mass/friction/restitution sweeps with recorded tolerances.
- Qualify separate new depth: Compare jointed mechanisms and high-speed collision.
- Qualify separate new depth: Expose contact/impulse diagnostics and meaningful reset receipts.
- Qualify separate new depth: Measure solver/resource costs across recorded engine/backend profiles.
- Define and run a depth-specific positive assertion and disabled/broken-path negative control for each new requirement; historical seals are regression only
- Launch adds one real body
- Body travels from launch position and settles within tolerance
- Reset restores six bodies
- Twenty-four body budget refuses further spawning
- Leaving releases the arrangement
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
