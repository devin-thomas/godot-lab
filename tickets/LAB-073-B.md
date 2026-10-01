# LAB-073-B: Voice & Captions - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-073-A](LAB-073-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-073](../experiments/LAB-073.md). Payoff: Play original speech with timed captions and compare transcript, timing and audible evidence.

## Acceptance

- Cue appears within timing tolerance
- Seek selects correct cue
- Muted route retains captions
- Transcript/corrections preserve exact fixture wording
- Malformed overlapping policy violation rejects track
- Missing audio gives labeled text-only fallback
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, audio, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
