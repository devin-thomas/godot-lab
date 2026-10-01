# LAB-028-A: Thread Mill - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-012](CORE-012.md), [CORE-018](CORE-018.md), [LAB-023-B](LAB-023-B.md), [LAB-036-B](LAB-036-B.md).

Contract: [LAB-028](../experiments/LAB-028.md). Payoff: Run a bounded cancellable data job without mutating the scene from worker threads.

## Acceptance

- Controls remain responsive during job
- Cancelled job cannot commit
- Worker result matches single-thread reference
- Scene mutation occurs on main thread
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
