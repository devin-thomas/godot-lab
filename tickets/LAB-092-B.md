# LAB-092-B: Memory Observatory - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-092-A](LAB-092-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-092](../experiments/LAB-092.md). Payoff: Repeat entry/reset/exit and inspect resource growth, leaks and bounded caches.

## Acceptance

- Node count returns within declared baseline tolerance
- Cache cap enforced
- Repeated cycles show bounded trend
- Missing counters remain unavailable
- Cancelled cycle still cleans owned state
- Intentional leaking negative fixture is detected
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
