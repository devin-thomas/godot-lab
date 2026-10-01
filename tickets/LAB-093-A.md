# LAB-093-A: Import Plugin - Implementation/deepening

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-008](CORE-008.md), [CORE-013](CORE-013.md), [LAB-026-B](LAB-026-B.md), [LAB-018-B](LAB-018-B.md), [LAB-039-B](LAB-039-B.md).

Contract: [LAB-093](../experiments/LAB-093.md). Payoff: Import an original custom data format through editor tooling with reimport and diagnostics.

## Acceptance

- Valid source yields expected Resource
- Reimport updates versioned content
- Diagnostics point to offending field
- Failed import preserves last-good usable fixture
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, editor, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
