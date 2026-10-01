# LAB-085-A: RPC Gatehouse - Implementation/deepening

Full-contract state: specified. Planned wave: M4 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-015](CORE-015.md), [LAB-024-B](LAB-024-B.md), [LAB-038-B](LAB-038-B.md).

Contract: [LAB-085](../experiments/LAB-085.md). Payoff: Send allowed and invalid RPC requests and inspect authority, payload limits and version checks.

## Acceptance

- Allowed request mutates once
- Unauthorized peer cannot mutate
- Oversized payload rejected before domain processing
- Session survives invalid request
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, transport, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
