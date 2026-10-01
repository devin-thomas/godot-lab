# LAB-050-A: Field Chamber - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-002-B](LAB-002-B.md), [LAB-052-B](LAB-052-B.md).

Contract: [LAB-050](../experiments/LAB-050.md). Payoff: Move bodies through gravity, damping and trigger zones and inspect overlap policy.

## Acceptance

- Entering zone changes measured acceleration/damping
- Exit restores outside behavior
- Overlap priority matches declared policy
- One enter/exit receipt per transition
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
