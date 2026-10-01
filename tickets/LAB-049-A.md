# LAB-049-A: Constraint Foundry - Implementation/deepening

State: specified. Planned wave: M2 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-002-B](LAB-002-B.md).

Contract: [LAB-049](../experiments/LAB-049.md). Payoff: Manipulate3D mechanical joints and inspect angular limits and solver stability.

## Acceptance

- Hinge stays within configured angular tolerance
- Slider stays on intended axis
- Force response is observable
- Reset yields stable initial system
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
