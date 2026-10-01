# LAB-009-B: Particle Weather - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-009-A](LAB-009-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-009](../experiments/LAB-009.md). Payoff: Tune a storm and compare CPU/GPU particle behavior under a bounded budget.

## Acceptance

- Particle count stays within cap
- Lifetime changes visible persistence
- Backend comparison records actual renderer and timing
- Reset leaves no active emitter
- 2D/3D comparison records the actual dimensional fixture and supported backend
- Unsupported GPU path reports unavailable
- Excess count rejects before allocation
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
