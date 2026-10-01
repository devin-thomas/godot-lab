# LAB-005-A: Signal chamber - Implementation/deepening

Full-contract state: specified. Planned wave: M1 baseline deepening (separate depth, not historical completion). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-010](CORE-010.md).

Contract: [LAB-005](../experiments/LAB-005-EXPANSION.md). Payoff: Hear distance and stereo change around a visible original tone emitter.

## Acceptance

- Add buses, effects, synchronized music and reviewed speech/captions.
- Exercise muted/missing-device/unsupported-output paths.
- Add actual channel/timing analysis for new fixtures rather than playing flags.
- Separate encoded proof from later speaker/headphone comfort.
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, audio, provider, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
