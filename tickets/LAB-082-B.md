# LAB-082-B: Prediction Track - Qualification

Full-contract state: specified. Planned wave: M4 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-082-A](LAB-082-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-082](../experiments/LAB-082.md). Payoff: Compare authoritative motion with client prediction and reconciliation under controlled delay.

## Acceptance

- Acknowledged inputs removed exactly once
- Reconciliation converges within declared tolerance
- Stale snapshots ignored visibly
- Server remains authority
- Duplicate/out-of-order snapshot handled by policy
- Unknown actor snapshot refuses apply
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, transport, render, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
