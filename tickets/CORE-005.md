# CORE-005: Fixtures, namespaces and reset ownership

State: specified.
Depends on: [CORE-003](CORE-003.md).

Register original hashed fixtures and stage bounded hostile imports; reset cancels only owned work.

## Acceptance

- Cross-lab progress survives reset
- Oversize/traversal/malformed fixtures reject safely
- Exit during work leaves no ownerless actor or partial success

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
