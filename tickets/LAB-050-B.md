# LAB-050-B: Field Chamber - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-050-A](LAB-050-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-050](../experiments/LAB-050.md). Payoff: Move bodies through gravity, damping and trigger zones and inspect overlap policy.

## Acceptance

- Entering zone changes measured acceleration/damping
- Exit restores outside behavior
- Overlap priority matches declared policy
- One enter/exit receipt per transition
- Unsupported dimensional profile refuses apply
- Invalid shape/budget rejects
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
