# LAB-091-A: Golden Assertions - Implementation/deepening

Full-contract state: specified. Planned wave: M4 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-011](CORE-011.md), [CORE-014](CORE-014.md), [LAB-088-B](LAB-088-B.md), [LAB-073-B](LAB-073-B.md), [LAB-019-B](LAB-019-B.md).

Contract: [LAB-091](../experiments/LAB-091.md). Payoff: Compare declared image/audio/state regions and inspect why a regression passes or fails.

## Acceptance

- Semantic mismatch fails
- Rendered region threshold detects controlled change
- Audio gate catches muted/wrong tone fixture
- Reference update requires explicit review
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, audio, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
