# LAB-041-A: Signal Switchboard - Implementation/deepening

State: specified. Planned wave: M1 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-016](CORE-016.md), [LAB-038-B](LAB-038-B.md).

Contract: [LAB-041](../experiments/LAB-041.md). Payoff: Wire events between scene objects and inspect ordering, disconnection and duplicate subscription.

## Acceptance

- One emit invokes one registered receiver
- Duplicate connect does not multiply effects
- Freed receiver is removed safely
- Event trace order matches declared ordering
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
