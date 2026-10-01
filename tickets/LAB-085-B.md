# LAB-085-B: RPC Gatehouse - Qualification

State: specified. Planned wave: M4 (future lab).
Depends on: [LAB-085-A](LAB-085-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-085](../experiments/LAB-085.md). Payoff: Send allowed and invalid RPC requests and inspect authority, payload limits and version checks.

## Acceptance

- Allowed request mutates once
- Unauthorized peer cannot mutate
- Oversized payload rejected before domain processing
- Session survives invalid request
- Unknown operation rejects
- Duplicate request does not repeat effect
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, transport, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
