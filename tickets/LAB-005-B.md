# LAB-005-B: Signal chamber - Qualification

Full-contract state: specified. Planned wave: M1 baseline deepening (separate depth, not historical completion). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-005-A](LAB-005-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-005](../experiments/LAB-005-EXPANSION.md). Payoff: Hear distance and stereo change around a visible original tone emitter.

## Acceptance

- Qualify separate new depth: Add buses, effects, synchronized music and reviewed speech/captions.
- Qualify separate new depth: Exercise muted/missing-device/unsupported-output paths.
- Qualify separate new depth: Add actual channel/timing analysis for new fixtures rather than playing flags.
- Qualify separate new depth: Separate encoded proof from later speaker/headphone comfort.
- Define and run a depth-specific positive assertion and disabled/broken-path negative control for each new requirement; historical seals are regression only
- Encoded output is non-silent
- Near RMS exceeds far RMS
- Left/right phase channel dominance swaps
- Dominant recorded frequency is220 Hz
- Mute deliberately silences the master bus
- Exit/reset stops the source
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, audio, provider, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
