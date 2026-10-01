# LAB-048-A: Joint Arcade - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-042-B](LAB-042-B.md).

Contract: [LAB-048](../experiments/LAB-048.md). Payoff: Connect2D bodies with pin/spring/groove joints and inspect limits and break policy.

## Acceptance

- Pin maintains declared pivot tolerance
- Spring response changes with profile
- Slider stays within allowed travel
- Reset restores baseline linkage
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
