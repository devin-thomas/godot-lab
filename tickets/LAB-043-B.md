# LAB-043-B: Combat Clock - Qualification

State: specified. Planned wave: M2 (future lab).
Depends on: [LAB-043-A](LAB-043-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-043](../experiments/LAB-043.md). Payoff: Land a readable attack and inspect hitboxes, invulnerability, hitstop and cancel timing.

## Acceptance

- One swing damages target once
- Hitstop pauses intended actors while UI remains active
- Cancel accepted only in window
- Invulnerability suppresses declared hits
- Unknown attack rejects
- Repeated overlap cannot double damage same swing
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, audio, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
