# LAB-008-B: Animation Loom - Qualification

State: specified. Planned wave: M1 (future lab).
Depends on: [LAB-008-A](LAB-008-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-008](../experiments/LAB-008.md). Payoff: Blend locomotion with a gesture and inspect transition timing rather than swapping clips blindly.

## Acceptance

- Speed changes weights continuously
- Gesture ends in intended state
- Repeated interruption never sticks
- Visible feet/pose match state trace
- Missing clip returns unavailable state
- Out-of-range blend input rejects
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
