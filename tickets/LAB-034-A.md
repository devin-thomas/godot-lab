# LAB-034-A: XR Room - Implementation/deepening

Full-contract state: specified. Planned wave: M5 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-018](CORE-018.md), [LAB-001-B](LAB-001-B.md), [LAB-049-B](LAB-049-B.md), [LAB-012-B](LAB-012-B.md).

Contract: [LAB-034](../experiments/LAB-034.md). Payoff: Interact through tracked input while inspecting real versus fixture poses.

## Acceptance

- Fixture poses never labeled hardware
- Grab/release changes real object state
- Tracking loss safely releases or freezes by policy
- Runtime/device provenance recorded
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, physical, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
