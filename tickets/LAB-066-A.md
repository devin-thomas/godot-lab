# LAB-066-A: Viewport Mirrors - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [CORE-018](CORE-018.md), [LAB-011-B](LAB-011-B.md), [LAB-013-B](LAB-013-B.md).

Contract: [LAB-066](../experiments/LAB-066.md). Payoff: Look through a live portal/monitor and inspect camera, texture and input forwarding boundaries.

## Acceptance

- Displayed texture updates from intended camera
- Forwarded input affects correct panel
- Recursion cap holds
- Exit frees viewport resources
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
