# LAB-023-B: Procedural Garden - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-023-A](LAB-023-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-023](../experiments/LAB-023.md). Payoff: Generate a seeded playable layout and inspect connectivity before entering it.

## Acceptance

- Same seed/config yields same topology hash
- Every required room connects
- Budget caps hold
- Failed proposal leaves current world unchanged
- Impossible connectivity rejects proposal
- Cancel prevents later completion from committing
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
