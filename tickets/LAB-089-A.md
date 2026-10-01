# LAB-089-A: Parameter Sweeps - Implementation/deepening

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-011](CORE-011.md), [CORE-014](CORE-014.md), [LAB-028-B](LAB-028-B.md), [LAB-088-B](LAB-088-B.md), [LAB-036-B](LAB-036-B.md).

Contract: [LAB-089](../experiments/LAB-089.md). Payoff: Schedule bounded scenario variations and compare their actual outcomes with resumable jobs.

## Acceptance

- Each accepted row records actual parameters/result
- Cancelled row never marked passed
- Resume skips only proven rows
- Concurrency/memory cap enforced
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
