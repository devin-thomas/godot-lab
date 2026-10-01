# LAB-033-A: Mobile Field Kit - Implementation/deepening

Full-contract state: specified. Planned wave: M5 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-018](CORE-018.md), [LAB-012-B](LAB-012-B.md), [LAB-032-B](LAB-032-B.md).

Contract: [LAB-033](../experiments/LAB-033.md). Payoff: Try touch controls and sensor adapters with visible simulated/real distinction.

## Acceptance

- Touch action reaches same domain operation
- Multitouch release leaves no held input
- Fixture replay labeled simulated
- Real adapter records device/permission provenance
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, export, physical. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
