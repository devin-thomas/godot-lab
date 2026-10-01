# LAB-024-A: Network Commons - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-015](CORE-015.md), [LAB-006-B](LAB-006-B.md).

Contract: [LAB-024](../experiments/LAB-024.md). Payoff: Join two local processes and inspect server authority and replicated player state.

## Acceptance

- Two processes establish transport
- Authority-owned state reaches replica
- Unauthorized mutation rejects
- Clean disconnect removes owned actor
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, transport, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
