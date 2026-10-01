# CORE-003: Typed operations, receipts and revisions

State: full contract specified; narrower implementations tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md).
Depends on: [CORE-002](CORE-002.md).

One validated operation bus drives UI and scenarios; receipts distinguish queued and completed effects.

## Acceptance

- Equivalent UI/scenario results
- Invalid args and conflicting duplicate request IDs reject before mutation
- Retry/stale revision tests preserve durable state

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
