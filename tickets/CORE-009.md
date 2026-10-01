# CORE-009: Simulation clocks, records and replay

State: specified.
Depends on: [CORE-003](CORE-003.md), [CORE-005](CORE-005.md), [CORE-006](CORE-006.md).

Order fixed-tick commands, checkpoints and semantic events separately from presentation time.

## Acceptance

- Same-tick ordering and pause/time-scale boundaries tested
- Incompatible/tampered record rejected
- Replay uses declared per-system tolerance

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
