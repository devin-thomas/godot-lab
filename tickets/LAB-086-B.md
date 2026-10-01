# LAB-086-B: WebRTC Bridge - Qualification

State: specified. Planned wave: M5 (future lab).
Depends on: [LAB-086-A](LAB-086-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-086](../experiments/LAB-086.md). Payoff: Connect two browser-capable peers through an explicit local signaling adapter and inspect failure modes.

## Acceptance

- Both peers establish actual channel
- Message order follows declared channel policy
- Disconnect reported
- Unsupported backend retains labeled fixture path
- Malformed signaling rejects
- Connection timeout is not promoted to success
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, transport, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
