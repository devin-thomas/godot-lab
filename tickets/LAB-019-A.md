# LAB-019-A: Shader Bench - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [CORE-018](CORE-018.md), [LAB-004-B](LAB-004-B.md).

Contract: [LAB-019](../experiments/LAB-019.md). Payoff: Adjust uniforms and see clean before/after output while inspecting shader diagnostics.

## Acceptance

- Uniform changes intended pixels
- Reference view stays unchanged
- Compile failure is shown
- Recovery restores valid output
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
