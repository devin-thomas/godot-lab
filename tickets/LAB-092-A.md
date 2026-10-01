# LAB-092-A: Memory Observatory - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-012](CORE-012.md), [CORE-018](CORE-018.md), [LAB-029-B](LAB-029-B.md), [LAB-017-B](LAB-017-B.md), [LAB-040-B](LAB-040-B.md), [LAB-036-B](LAB-036-B.md).

Contract: [LAB-092](../experiments/LAB-092.md). Payoff: Repeat entry/reset/exit and inspect resource growth, leaks and bounded caches.

## Acceptance

- Node count returns within declared baseline tolerance
- Cache cap enforced
- Repeated cycles show bounded trend
- Missing counters remain unavailable
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
