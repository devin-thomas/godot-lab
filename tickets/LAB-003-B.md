# LAB-003-B: Pathfinder garden - Qualification

Full-contract state: specified. Planned wave: M1 baseline deepening (separate depth, not historical completion). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-003-A](LAB-003-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-003](../experiments/LAB-003-EXPANSION.md). Payoff: Dispatch a courier around a tower to a fixed destination.

## Acceptance

- Qualify separate new depth: Add selectable destinations and explicitly unreachable targets.
- Qualify separate new depth: Compare authored, runtime-rebuilt and avoidance routes.
- Qualify separate new depth: Add multi-agent bottleneck and reset-during-travel checks.
- Qualify separate new depth: Verify map synchronization and obstacle/path correspondence.
- Define and run a depth-specific positive assertion and disabled/broken-path negative control for each new requirement; historical seals are regression only
- Actual path has multiple points
- Courier reaches within one unit of fixed destination
- Reset clears travel and arrival state
- Unavailable map must not invent arrival
- Leaving during travel cancels the room
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
