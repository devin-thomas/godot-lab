# LAB-040-A: Pause Vestibule - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-016](CORE-016.md), [LAB-021-B](LAB-021-B.md), [LAB-028-B](LAB-028-B.md), [LAB-013-B](LAB-013-B.md).

Contract: [LAB-040](../experiments/LAB-040.md). Payoff: Pause, resume and leave an active lab while inspecting cleanup and focus handoff.

## Acceptance

- Inspector works while simulation paused
- Resume preserves intended state
- Exit releases audio/jobs/nodes
- Re-entry begins clean baseline
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, audio. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
