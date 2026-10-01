# LAB-028-B: Thread Mill - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-028-A](LAB-028-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-028](../experiments/LAB-028.md). Payoff: Run a bounded cancellable data job without mutating the scene from worker threads.

## Acceptance

- Controls remain responsive during job
- Cancelled job cannot commit
- Worker result matches single-thread reference
- Scene mutation occurs on main thread
- Duplicate request joins or rejects explicitly
- Invalid budget rejects before scheduling
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
