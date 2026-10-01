# CORE-002: Static modules and lifecycle

State: full contract specified; narrower implementations tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md).
Depends on: [RELEASE-001](RELEASE-001.md).

Migrate the six scenes to injected modules without changing seals, controls or scenario semantics.

## Acceptance

- Extraction scene boots without museum paths
- Repeated entry/reset/exit releases owned nodes, signals and audio
- Existing six-room assertions remain passing

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
