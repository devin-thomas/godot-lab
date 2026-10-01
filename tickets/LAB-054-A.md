# LAB-054-A: Ragdoll Recovery - Implementation/deepening

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [LAB-015-B](LAB-015-B.md), [LAB-049-B](LAB-049-B.md), [LAB-008-B](LAB-008-B.md).

Contract: [LAB-054](../experiments/LAB-054.md). Payoff: Switch an original rig between animation and physical bones and inspect recovery.

## Acceptance

- Physical mode changes actual bone transforms
- Fall remains within resource bounds
- Recovery ends in valid animation state
- Reset clears physics velocities
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
