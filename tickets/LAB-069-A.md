# LAB-069-A: Compute Garden - Implementation/deepening

State: specified. Planned wave: M4 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [CORE-018](CORE-018.md), [LAB-027-B](LAB-027-B.md), [LAB-031-B](LAB-031-B.md), [LAB-028-B](LAB-028-B.md).

Contract: [LAB-069](../experiments/LAB-069.md). Payoff: Run a small compute fixture and compare output against a CPU reference with honest availability.

## Acceptance

- GPU/reference outputs match defined tolerance
- Readback identifies actual backend
- Unsupported route reports unavailable
- Repeated runs release allocated resources
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, profiling, render. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
