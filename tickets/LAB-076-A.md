# LAB-076-A: Cinematic Rails - Implementation/deepening

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-016](CORE-016.md), [LAB-011-B](LAB-011-B.md), [LAB-008-B](LAB-008-B.md), [LAB-025-B](LAB-025-B.md).

Contract: [LAB-076](../experiments/LAB-076.md). Payoff: Compose an interactive camera/animation sequence with skip, resume and bounded cancellation.

## Acceptance

- Camera follows declared path
- Skip commits only approved semantic events
- Exit returns controls
- Repeated start cannot overlap timelines
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, audio, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
