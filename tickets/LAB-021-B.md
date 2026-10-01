# LAB-021-B: Time Laboratory - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-021-A](LAB-021-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-021](../experiments/LAB-021.md). Payoff: See pause, time scaling and interpolation affect simulation without freezing the inspector.

## Acceptance

- Paused simulation position stays stable
- Inspector still accepts resume
- Scale changes elapsed simulation rate
- Reset restores timing settings
- Invalid scale rejects
- Exit during pause cannot leave hub frozen
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
