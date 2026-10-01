# LAB-035-A: Import Studio - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-013](CORE-013.md), [CORE-016](CORE-016.md), [LAB-018-B](LAB-018-B.md), [LAB-004-B](LAB-004-B.md).

Contract: [LAB-035](../experiments/LAB-035.md). Payoff: Inspect imported meshes, materials and animation against original source fixtures.

## Acceptance

- Scale/orientation match markers
- UV/color attributes survive expected path
- Animation duration/bones match fixture
- Missing material is visible
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, editor, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
