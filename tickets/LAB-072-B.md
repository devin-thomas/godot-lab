# LAB-072-B: Music Conductor - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-072-A](LAB-072-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-072](../experiments/LAB-072.md). Payoff: Change intensity on a beat boundary and inspect synchronized stems rather than abrupt restarts.

## Acceptance

- Transition occurs within declared beat tolerance
- Stem phases remain aligned
- Repeated same request causes no duplicate restart
- Reset clears pending switch
- Invalid beat metadata rejects fixture
- Unsupported interactive-stream API leaves explicit alternate path
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, audio, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
