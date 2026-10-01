# CORE-010: Viewer cameras and presentation tracks

State: full contract specified; narrower implementations tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md).
Depends on: [CORE-009](CORE-009.md).

Author independent framing/look/effect tracks anchored to simulation events.

## Acceptance

- Changing viewer camera leaves simulation result intact
- Invalid tracks/cameras fail visibly
- Output rates and event timing verified in actual frames

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
