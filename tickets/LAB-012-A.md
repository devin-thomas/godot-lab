# LAB-012-A: Input Atelier - Implementation/deepening

Full-contract state: specified. Planned wave: M1 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [LAB-001-B](LAB-001-B.md), [LAB-013-B](LAB-013-B.md).

Contract: [LAB-012](../experiments/LAB-012.md). Payoff: Rebind actions and see prompts follow actual input events without losing essential controls.

## Acceptance

- New key invokes the same operation
- Conflicting essential binding is rejected
- Prompt family follows last event
- Cancel exits capture without changes
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, physical. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
