# LAB-077-B: Inventory Alchemy - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-077-A](LAB-077-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-077](../experiments/LAB-077.md). Payoff: Combine original items and inspect transactional recipes, limits and undo.

## Acceptance

- Recipe consumes/produces exact quantities
- Duplicate request crafts once
- Capacity failure leaves inventory unchanged
- Undo restores prior counts
- Unknown ingredient rejects
- Stale proposal refuses commit
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
