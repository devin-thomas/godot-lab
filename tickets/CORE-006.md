# CORE-006: Source-bound evidence and gate registry

State: full contract specified; narrower implementations tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md).
Depends on: [CORE-003](CORE-003.md), [CORE-004](CORE-004.md).

Bind results/artifacts to source, fixture, toolchain, scenario, profile and declared limits.

## Acceptance

- Stale-build/fixture proof is rejected
- Missing audio/pixels/provider cannot masquerade as logic proof
- Public reports exclude secrets and private routes

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
