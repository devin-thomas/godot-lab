# LAB-059-B: LOD Walk - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-059-A](LAB-059-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-059](../experiments/LAB-059.md). Payoff: Walk an identical camera route and inspect mesh detail transitions, culling and visual discontinuity.

## Acceptance

- LOD threshold matches declared distance
- Visible object IDs stay semantically stable
- Culling preserves required landmarks
- Timing/triangle metrics tied to renderer
- Missing detail variant reports unavailable
- Invalid thresholds reject
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
