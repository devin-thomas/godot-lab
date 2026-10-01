# LAB-040-B: Pause Vestibule - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-040-A](LAB-040-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-040](../experiments/LAB-040.md). Payoff: Pause, resume and leave an active lab while inspecting cleanup and focus handoff.

## Acceptance

- Inspector works while simulation paused
- Resume preserves intended state
- Exit releases audio/jobs/nodes
- Re-entry begins clean baseline
- Repeated exit is idempotent
- Cancellation race cannot mount late resources
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, audio. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
