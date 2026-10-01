# LAB-037-A: Capability Compass - Implementation/deepening

Full-contract state: specified. Planned wave: M1 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-016](CORE-016.md), [LAB-013-B](LAB-013-B.md), [LAB-018-B](LAB-018-B.md).

Contract: [LAB-037](../experiments/LAB-037.md). Payoff: Find a capability by payoff and see exactly why its live route is available or gated.

## Acceptance

- Search returns stable relevant IDs
- Unavailable adapter names missing gate
- Opening ready card enters correct lab
- Specified card cannot masquerade as playable
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
