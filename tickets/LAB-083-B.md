# LAB-083-B: Reconnect Harbor - Qualification

State: specified. Planned wave: M4 (future lab).
Depends on: [LAB-083-A](LAB-083-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-083](../experiments/LAB-083.md). Payoff: Drop and rejoin a local session without duplicating owned entities or losing committed state.

## Acceptance

- Rejoin recovers declared committed state
- One actor exists per resumed identity
- Unacked actions follow explicit policy
- Expired request rejects cleanly
- Invalid resume token refuses
- Version mismatch provides restart route
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, transport, interchange, render. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
