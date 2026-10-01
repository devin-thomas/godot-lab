# LAB-018-A: Resource Cabinet - Implementation/deepening

Full-contract state: specified. Planned wave: M1 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-013](CORE-013.md), [CORE-016](CORE-016.md), [LAB-006-B](LAB-006-B.md).

Contract: [LAB-018](../experiments/LAB-018.md). Payoff: Save and reload a custom Resource while inspecting dependencies and stable identities.

## Acceptance

- Declared fields round-trip
- Stable IDs survive reload
- Dependency failures are visible
- Repeated load policy is explicit
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, interchange, editor. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
