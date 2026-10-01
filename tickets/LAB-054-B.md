# LAB-054-B: Ragdoll Recovery - Qualification

State: specified. Planned wave: M3 (future lab).
Depends on: [LAB-054-A](LAB-054-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-054](../experiments/LAB-054.md). Payoff: Switch an original rig between animation and physical bones and inspect recovery.

## Acceptance

- Physical mode changes actual bone transforms
- Fall remains within resource bounds
- Recovery ends in valid animation state
- Reset clears physics velocities
- Missing recovery pose rejects
- Unsettled timeout reports incomplete recovery
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
