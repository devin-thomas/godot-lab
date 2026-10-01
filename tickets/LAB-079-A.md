# LAB-079-A: Focus Labyrinth - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [LAB-013-B](LAB-013-B.md), [LAB-066-B](LAB-066-B.md).

Contract: [LAB-079](../experiments/LAB-079.md). Payoff: Navigate menus, dialogs and a3D panel with keyboard focus and inspect accessibility probes.

## Acceptance

- Essential path is reachable without pointer
- Hidden controls never focus
- Closing dialog restores origin
- Unavailable assistive API is reported honestly
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, physical, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
