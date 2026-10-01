# LAB-010-A: Light Archive - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [CORE-018](CORE-018.md), [LAB-004-B](LAB-004-B.md), [LAB-031-B](LAB-031-B.md).

Contract: [LAB-010](../experiments/LAB-010.md). Payoff: Inspect how baked, authored and dynamic light change the same original room.

## Acceptance

- Dynamic occluder changes dynamic mode
- Baked mode explains its static limits
- Authored mode remains stable
- Capture labels and selected profile agree
- 2D light/occluder masks and 3D light/bake profiles have separate assertions
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: render, profiling, editor, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
