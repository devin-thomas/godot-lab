# CORE-011: One-session Cappy and live orchestration

State: full contract specified; narrower implementations tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md).
Depends on: [CORE-008](CORE-008.md), [CORE-009](CORE-009.md), [CORE-010](CORE-010.md).

Extend pinned official Cappy integration so live authoring, replay and capture coexist in one session.

## Acceptance

- Agent changes real scene during game-only capture
- Decoded video/audio aligns with recorded operations
- Provider loss/stop cleans up without fake success

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
