# LAB-058-A: World Clock - Implementation/deepening

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-009](CORE-009.md), [CORE-012](CORE-012.md), [LAB-021-B](LAB-021-B.md), [LAB-041-B](LAB-041-B.md).

Contract: [LAB-058](../experiments/LAB-058.md). Payoff: Advance a scoped day/weather clock and inspect gameplay triggers and visual change separately.

## Acceptance

- Seek sets expected environment state
- Event fires once at threshold
- Pause freezes world schedule
- Replay yields same semantic event order
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
