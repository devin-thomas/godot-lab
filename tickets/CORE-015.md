# CORE-015: Session authority and transport harness

State: full contract specified; narrower implementations tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md).
Depends on: [CORE-003](CORE-003.md), [CORE-005](CORE-005.md), [CORE-006](CORE-006.md), [CORE-009](CORE-009.md).

Define real peer roles, authority, ordered commands/replaceable samples and loss/reconnect harness.

## Acceptance

- Unauthorized peer cannot mutate world
- Late/duplicate/lost messages follow contract
- Real separate peers resync with declared tolerance

Resolve installed APIs, bound resources, expose errors/cancellation and record source-bound checks. Keep optional adapters outside ordinary play. Read [SPEC](../SPEC.md), [architecture](../docs/ARCHITECTURE.md), [data contracts](../docs/DATA_CONTRACTS.md), [profiles](../docs/CAPABILITY_PROFILES.md) and [test strategy](../docs/TEST_STRATEGY.md).
