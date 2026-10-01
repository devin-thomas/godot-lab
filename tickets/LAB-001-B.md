# LAB-001-B: Motion atelier - Qualification

Full-contract state: specified. Planned wave: M1 baseline deepening (separate depth, not historical completion). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-001-A](LAB-001-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-001](../experiments/LAB-001-EXPANSION.md). Payoff: Feel a real capsule move, jump and land against stairs and a solid block.

## Acceptance

- Qualify separate new depth: Separate reusable player/controller modules from host assembly.
- Qualify separate new depth: Add input buffering, coyote time and analog profiles with boundary assertions.
- Qualify separate new depth: Add slope, moving-platform and camera-occlusion comparisons.
- Qualify separate new depth: Keep actual-controller and human-comfort gates separate from synthetic events.
- Define and run a depth-specific positive assertion and disabled/broken-path negative control for each new requirement; historical seals are regression only
- Actual travel exceeds two units and one jump occurs
- Character lands on the floor
- Solid obstacle blocks travel
- Room reset clears motion baseline
- Unknown lab ID rejects entry
- Falling below the room teleports to the start
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
