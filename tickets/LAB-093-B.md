# LAB-093-B: Import Plugin - Qualification

Full-contract state: specified. Planned wave: M3 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-093-A](LAB-093-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-093](../experiments/LAB-093.md). Payoff: Import an original custom data format through editor tooling with reimport and diagnostics.

## Acceptance

- Valid source yields expected Resource
- Reimport updates versioned content
- Diagnostics point to offending field
- Failed import preserves last-good usable fixture
- Unknown version refuses import
- External path traversal rejects
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, editor, interchange. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
