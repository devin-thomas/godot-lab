# LAB-044-A: Ledge Course - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-001-B](LAB-001-B.md), [LAB-008-B](LAB-008-B.md), [LAB-011-B](LAB-011-B.md).

Contract: [LAB-044](../experiments/LAB-044.md). Payoff: Traverse slope, wall and ledge states while inspecting transition guards.

## Acceptance

- Allowed ledge transitions reach stable pose
- Overhang blocks climb
- Slope limit prevents invalid walking
- Reset clears grab constraints
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
