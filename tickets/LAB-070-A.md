# LAB-070-A: Tone Observatory - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md), [CORE-018](CORE-018.md), [LAB-010-B](LAB-010-B.md), [LAB-031-B](LAB-031-B.md), [LAB-019-B](LAB-019-B.md).

Contract: [LAB-070](../experiments/LAB-070.md). Payoff: Compare exposure, tone mapping and color grading while preserving meaningful luminance roles.

## Acceptance

- Profile labels match actual environment
- Clipped highlights counted
- Dark silhouette contrast remains within declared range
- Captured images preserve provenance
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: render, profiling, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
