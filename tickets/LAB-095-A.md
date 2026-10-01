# LAB-095-A: Blender Round Trip - Implementation/deepening

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-013](CORE-013.md), [CORE-016](CORE-016.md), [LAB-035-B](LAB-035-B.md), [LAB-015-B](LAB-015-B.md), [LAB-060-B](LAB-060-B.md), [LAB-061-B](LAB-061-B.md).

Contract: [LAB-095](../experiments/LAB-095.md). Payoff: Carry an original rigged, vertex-painted modular asset from source to Godot and back through a bounded interchange path.

## Acceptance

- Axes/scale match markers
- UV/color attribute counts/hash policy hold
- Bone names and reference pose preserved
- Unsupported attributes reported explicitly
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, editor, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
