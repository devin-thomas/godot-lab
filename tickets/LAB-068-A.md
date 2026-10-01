# LAB-068-A: Display Laboratory - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [CORE-018](CORE-018.md), [LAB-004-B](LAB-004-B.md), [LAB-019-B](LAB-019-B.md), [LAB-013-B](LAB-013-B.md).

Contract: [LAB-068](../experiments/LAB-068.md). Payoff: Compare clean, pixel-scaled, palette and optional CRT output without weakening controls.

## Acceptance

- Profile visibly changes intended pixels
- Essential text remains legible in declared minimum viewport
- Simulation/input rate unchanged
- Disable returns clean reference
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
