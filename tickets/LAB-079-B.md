# LAB-079-B: Focus Labyrinth - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-079-A](LAB-079-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-079](../experiments/LAB-079.md). Payoff: Navigate menus, dialogs and a3D panel with keyboard focus and inspect accessibility probes.

## Acceptance

- Essential path is reachable without pointer
- Hidden controls never focus
- Closing dialog restores origin
- Unavailable assistive API is reported honestly
- Removed focus target chooses declared safe successor
- Duplicate confirm invokes once
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, physical, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
