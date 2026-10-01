# LAB-090-A: Camera Takes - Implementation/deepening

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-011](CORE-011.md), [CORE-014](CORE-014.md), [LAB-011-B](LAB-011-B.md), [LAB-076-B](LAB-076-B.md), [LAB-088-B](LAB-088-B.md).

Contract: [LAB-090](../experiments/LAB-090.md). Payoff: Author reusable camera routes and record them without disabling ordinary playable scenes.

## Acceptance

- Camera follows timed markers
- Semantic scene action matches declared take
- Abort restores player controls
- Replay uses same fixture/build
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
