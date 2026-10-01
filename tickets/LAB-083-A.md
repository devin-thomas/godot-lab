# LAB-083-A: Reconnect Harbor - Implementation/deepening

State: specified. Planned wave: M4 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-015](CORE-015.md), [LAB-024-B](LAB-024-B.md), [LAB-082-B](LAB-082-B.md), [LAB-006-B](LAB-006-B.md).

Contract: [LAB-083](../experiments/LAB-083.md). Payoff: Drop and rejoin a local session without duplicating owned entities or losing committed state.

## Acceptance

- Rejoin recovers declared committed state
- One actor exists per resumed identity
- Unacked actions follow explicit policy
- Expired request rejects cleanly
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, transport, interchange, render. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
