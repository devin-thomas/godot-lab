# LAB-088-A: Source-bound Capture - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-011](CORE-011.md), [CORE-014](CORE-014.md), [LAB-025-B](LAB-025-B.md), [LAB-087-B](LAB-087-B.md), [LAB-039-B](LAB-039-B.md).

Contract: [LAB-088](../experiments/LAB-088.md). Payoff: Capture only the declared game window/process and verify the source identity before accepting media.

## Acceptance

- Declared source matches build/window identity
- Black/flat output rejects proof
- Artifact includes scenario/build provenance
- Stop finalizes on failure
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, audio, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
