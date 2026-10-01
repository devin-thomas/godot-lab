# LAB-060-A: Atlas Author - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-013](CORE-013.md), [LAB-004-B](LAB-004-B.md), [LAB-035-B](LAB-035-B.md).

Contract: [LAB-060](../experiments/LAB-060.md). Payoff: Paint a tiny original motif atlas and inspect UV padding, sampling and repetition on modular geometry.

## Acceptance

- Pixel edits affect intended region only
- Padding prevents declared sample bleed
- Repeated trim stays in assigned region
- Undo restores atlas hash
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
