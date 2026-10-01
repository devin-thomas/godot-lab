# LAB-001-A: Motion atelier - Implementation/deepening

Full-contract state: specified. Planned wave: M1 baseline deepening (separate depth, not historical completion). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md).

Contract: [LAB-001](../experiments/LAB-001-EXPANSION.md). Payoff: Feel a real capsule move, jump and land against stairs and a solid block.

## Acceptance

- Separate reusable player/controller modules from host assembly.
- Add input buffering, coyote time and analog profiles with boundary assertions.
- Add slope, moving-platform and camera-occlusion comparisons.
- Keep actual-controller and human-comfort gates separate from synthetic events.
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
