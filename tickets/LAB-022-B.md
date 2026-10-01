# LAB-022-B: Destruction Cell - Qualification

State: specified. Planned wave: M2 (future lab).
Depends on: [LAB-022-A](LAB-022-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-022](../experiments/LAB-022.md). Payoff: Break an original assembly into bounded physical fragments and rebuild it.

## Acceptance

- Only threshold-crossed joints detach
- Fragment count remains capped
- Detached pieces collide/settle
- Reset restores all connections
- Unknown part rejects
- Repeated break request is idempotent
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
