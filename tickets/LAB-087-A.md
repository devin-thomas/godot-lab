# LAB-087-A: Live Control - Implementation/deepening

State: specified. Planned wave: M3 (future lab).
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-011](CORE-011.md), [CORE-014](CORE-014.md), [LAB-038-B](LAB-038-B.md), [LAB-025-B](LAB-025-B.md), [LAB-040-B](LAB-040-B.md).

Contract: [LAB-087](../experiments/LAB-087.md). Payoff: Drive a running lab through a narrow typed command channel and inspect cancellation and receipts.

## Acceptance

- Command uses same player operation
- Invalid target rejected
- Cancellation prevents late commit
- Tool disconnect leaves ordinary play usable
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, transport, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
