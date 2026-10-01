# LAB-025-A: Replay Observatory - Implementation/deepening

State: specified. Planned wave: M1 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-011](CORE-011.md), [CORE-014](CORE-014.md), [LAB-001-B](LAB-001-B.md), [LAB-004-B](LAB-004-B.md), [LAB-006-B](LAB-006-B.md).

Contract: [LAB-025](../experiments/LAB-025.md). Payoff: Record meaningful operations and replay a versioned semantic timeline.

## Acceptance

- Event order retained
- Replay uses real operations
- Final semantic state matches declared comparison
- Unknown version rejects
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
