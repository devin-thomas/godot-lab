# LAB-031-A: Renderer Gallery - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [CORE-018](CORE-018.md), [LAB-004-B](LAB-004-B.md), [LAB-036-B](LAB-036-B.md).

Contract: [LAB-031](../experiments/LAB-031.md). Payoff: Compare the same fixture across Compatibility, Mobile and Forward+ with explicit support gates.

## Acceptance

- Each run records actual renderer
- Unsupported features are labeled
- Reference camera/assets match
- Timing/appearance reports remain per-host
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: render, export, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
