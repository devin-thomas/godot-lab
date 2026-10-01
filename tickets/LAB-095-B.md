# LAB-095-B: Blender Round Trip - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-095-A](LAB-095-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-095](../experiments/LAB-095.md). Payoff: Carry an original rigged, vertex-painted modular asset from source to Godot and back through a bounded interchange path.

## Acceptance

- Axes/scale match markers
- UV/color attribute counts/hash policy hold
- Bone names and reference pose preserved
- Unsupported attributes reported explicitly
- Missing external texture rejects or labeled unresolved
- Malformed/unknown extension cannot silently lose data
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, editor, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
