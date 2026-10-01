# LAB-013-A: UI Workshop - Implementation/deepening

Full-contract state: specified. Planned wave: M1 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [LAB-006-B](LAB-006-B.md).

Contract: [LAB-013](../experiments/LAB-013.md). Payoff: Operate a responsive control panel by keyboard and pointer with one predictable focus path.

## Acceptance

- Every essential control reachable by keyboard
- Disabled items skipped
- Resizing keeps actions inside viewport
- Dialog close restores originating focus
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, render, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
