# LAB-023-A: Procedural Garden - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [CORE-012](CORE-012.md), [LAB-007-B](LAB-007-B.md), [LAB-006-B](LAB-006-B.md).

Contract: [LAB-023](../experiments/LAB-023.md). Payoff: Generate a seeded playable layout and inspect connectivity before entering it.

## Acceptance

- Same seed/config yields same topology hash
- Every required room connects
- Budget caps hold
- Failed proposal leaves current world unchanged
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
