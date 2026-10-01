# CORE-013: Original asset recipes and interchange pipeline

State: full contract specified; narrower implementations tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md).
Depends on: [CORE-005](CORE-005.md), [CORE-006](CORE-006.md), [CORE-012](CORE-012.md).

Automate Blender authoring/import and validate meshes, UVs, colors, materials, rigs and clips.

## Acceptance

- Round trips preserve declared semantic structure
- Broken rig/missing clip/license rejected
- Hash manifest and extraction scene reproduce recipe

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
