# LAB-057-B: Navmesh Workshop - Qualification

State: specified. Planned wave: M3 (future lab).
Depends on: [LAB-057-A](LAB-057-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-057](../experiments/LAB-057.md). Payoff: Move an obstacle and inspect the difference between navigation rebake and runtime avoidance.

## Acceptance

- New committed path avoids moved obstacle
- Path switches only after map sync
- Failed bake preserves previous region
- Reset restores baseline path
- Invalid source geometry refuses bake
- Cancelled bake cannot mount late map
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, editor, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
