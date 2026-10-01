# LAB-073-A: Voice & Captions - Implementation/deepening

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [LAB-014-B](LAB-014-B.md), [LAB-071-B](LAB-071-B.md).

Contract: [LAB-073](../experiments/LAB-073.md). Payoff: Play original speech with timed captions and compare transcript, timing and audible evidence.

## Acceptance

- Cue appears within timing tolerance
- Seek selects correct cue
- Muted route retains captions
- Transcript/corrections preserve exact fixture wording
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, audio, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
