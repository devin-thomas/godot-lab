# LAB-039-A: Fixture Pantry - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-016](CORE-016.md), [LAB-018-B](LAB-018-B.md), [LAB-035-B](LAB-035-B.md).

Contract: [LAB-039](../experiments/LAB-039.md). Payoff: Choose safe original fixtures and preview their bounds before committing them to a lab.

## Acceptance

- Hashes identify exact fixture
- Size limits checked before adoption
- Cancel leaves current scene unchanged
- Commit preserves source identity in receipt
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
