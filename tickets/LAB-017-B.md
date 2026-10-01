# LAB-017-B: Crowd Balcony - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-017-A](LAB-017-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-017](../experiments/LAB-017.md). Payoff: Compare individual meshes and instancing under the same crowd layout and camera.

## Acceptance

- Both modes show same declared count
- Transform distribution matches seed
- Profiler records actual draw/time metrics
- Reset releases allocated crowd
- Count over budget rejects
- Unavailable metric is marked missing rather than zero
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, profiling, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
