# LAB-029-B: Streaming Depot - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-029-A](LAB-029-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-029](../experiments/LAB-029.md). Payoff: Walk across scene boundaries while loading chunks and preserving local changes.

## Acceptance

- Boundary activates requested chunk
- Changed object returns with correct state
- Cancelled load never mounts late
- Resident chunk cap holds
- Missing chunk displays error barrier
- Corrupt resource preserves current playable chunk
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
