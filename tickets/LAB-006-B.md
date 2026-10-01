# LAB-006-B: Memory archive - Qualification

Full-contract state: specified. Planned wave: M1 baseline deepening (separate depth, not historical completion). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [LAB-006-A](LAB-006-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-006](../experiments/LAB-006-EXPANSION.md). Payoff: Write earned seals and comfort preferences then reload a real versioned file.

## Acceptance

- Qualify separate new depth: Add explicit schema migration and unknown-field preservation policy.
- Qualify separate new depth: Demonstrate durable idempotent transactions, recovery and undo.
- Qualify separate new depth: Add export/import profiles and conflict/revision fixtures.
- Qualify separate new depth: Keep scope-limited reset, corrupt-file preservation and ordinary/automation isolation.
- Define and run a depth-specific positive assertion and disabled/broken-path negative control for each new requirement; historical seals are regression only
- Fresh reader recovers all six seals
- Fresh process recovers all six seals
- Unsupported/truncated input rejects
- Invalid original file remains until explicit checkpoint repair
- Unknown lab ID rejects load
- Malformed schema rejects without success-shaped replacement
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, interchange, export. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
