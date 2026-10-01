# CORE-014: Media regressions and event derivatives

State: specified.
Depends on: [CORE-006](CORE-006.md), [CORE-009](CORE-009.md), [CORE-011](CORE-011.md), [CORE-012](CORE-012.md).

Analyze actual video/audio, compare source-bound runs and produce event-anchored clips.

## Acceptance

- Black/frozen/silent/misaligned negative controls fail
- Comparison aligns fixture/look/renderer and declares tolerance
- Voice transcription used only when speech is actually present

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
