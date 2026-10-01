# LAB-087-B: Live Control - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-087-A](LAB-087-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-087](../experiments/LAB-087.md). Payoff: Drive a running lab through a narrow typed command channel and inspect cancellation and receipts.

## Acceptance

- Command uses same player operation
- Invalid target rejected
- Cancellation prevents late commit
- Tool disconnect leaves ordinary play usable
- Unknown command rejects
- Oversized request closes/refuses according to policy
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, transport, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
