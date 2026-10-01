# LAB-035-B: Import Studio - Qualification

Full-contract state: specified. Planned wave: M2 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-035-A](LAB-035-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-035](../experiments/LAB-035.md). Payoff: Inspect imported meshes, materials and animation against original source fixtures.

## Acceptance

- Scale/orientation match markers
- UV/color attributes survive expected path
- Animation duration/bones match fixture
- Missing material is visible
- Malformed asset refuses import
- Unexpected external URI is not fetched silently
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, editor, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
