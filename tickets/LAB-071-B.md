# LAB-071-B: Mixer Desk - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-071-A](LAB-071-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-071](../experiments/LAB-071.md). Payoff: Route original stems into lab-owned buses and inspect gain, solo and clipping safely.

## Acceptance

- Gain change follows measured RMS ratio
- Solo leaves selected stem only
- Clipping/limiter result reported
- Exit leaves user's unrelated audio untouched
- Unknown bus rejects
- Unsafe out-of-range gain refuses
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, audio, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
