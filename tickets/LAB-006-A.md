# LAB-006-A: Memory archive - Implementation/deepening

State: specified. Planned wave: M1 baseline deepening (separate depth, not historical completion).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-016](CORE-016.md).

Contract: [LAB-006](../experiments/LAB-006-EXPANSION.md). Payoff: Write earned seals and comfort preferences then reload a real versioned file.

## Acceptance

- Add explicit schema migration and unknown-field preservation policy.
- Demonstrate durable idempotent transactions, recovery and undo.
- Add export/import profiles and conflict/revision fixtures.
- Keep scope-limited reset, corrupt-file preservation and ordinary/automation isolation.
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, interchange, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
