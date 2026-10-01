# LAB-082-A: Prediction Track - Implementation/deepening

Full-contract state: specified. Planned wave: M4 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-015](CORE-015.md), [LAB-024-B](LAB-024-B.md), [LAB-025-B](LAB-025-B.md), [LAB-001-B](LAB-001-B.md).

Contract: [LAB-082](../experiments/LAB-082.md). Payoff: Compare authoritative motion with client prediction and reconciliation under controlled delay.

## Acceptance

- Acknowledged inputs removed exactly once
- Reconciliation converges within declared tolerance
- Stale snapshots ignored visibly
- Server remains authority
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, transport, render, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
