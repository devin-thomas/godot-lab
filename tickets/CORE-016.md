# CORE-016: Documents, schema migration and recovery

State: specified.
Depends on: [CORE-003](CORE-003.md), [CORE-005](CORE-005.md).

Separate progress/documents/records; stage migrations and atomically publish portable experiments.

## Acceptance

- Current schema-1 save stays compatible
- Unknown/newer/truncated data preserves good state
- Restart/round-trip/scoped reset use real files

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
