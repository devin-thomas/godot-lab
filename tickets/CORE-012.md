# CORE-012: Budgeted jobs, checkpoints and worker admission

State: full contract specified; narrower implementations tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md).
Depends on: [CORE-005](CORE-005.md), [CORE-006](CORE-006.md).

Bound and cancel authoring/render/analysis jobs with capacity checks and source/recipe identity.

## Acceptance

- Cancellation preserves previous good output
- Resume rejects incompatible source/fixture
- Unavailable or full worker yields truthful failure without local overload

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
