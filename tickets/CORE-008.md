# CORE-008: Authenticated live transport, CLI and MCP

State: full contract specified; narrower implementations tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md).
Depends on: [CORE-003](CORE-003.md), [CORE-005](CORE-005.md), [CORE-006](CORE-006.md).

Expose bounded loopback operations, observations/events and clients through the shared spine.

## Acceptance

- Unauthenticated mutations, unknown ops and oversized requests fail
- Disconnect/retry/cursor gap has explicit behavior
- UI/CLI/MCP/live routes have semantic parity

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
