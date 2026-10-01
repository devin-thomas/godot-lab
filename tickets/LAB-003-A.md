# LAB-003-A: Pathfinder garden - Implementation/deepening

Full-contract state: specified. Planned wave: M1 baseline deepening (separate depth, not historical completion). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [CORE-012](CORE-012.md).

Contract: [LAB-003](../experiments/LAB-003-EXPANSION.md). Payoff: Dispatch a courier around a tower to a fixed destination.

## Acceptance

- Add selectable destinations and explicitly unreachable targets.
- Compare authored, runtime-rebuilt and avoidance routes.
- Add multi-agent bottleneck and reset-during-travel checks.
- Verify map synchronization and obstacle/path correspondence.
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
