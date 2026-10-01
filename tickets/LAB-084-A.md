# LAB-084-A: Network Chaos - Implementation/deepening

Full-contract state: specified. Planned wave: M4 (expanded lab). Narrower code/evidence is tracked in [implementation waves](../docs/IMPLEMENTATION_WAVES.md); it does not close this ticket.
Depends on: [CORE-007](CORE-007.md), [CORE-017](CORE-017.md), [CORE-015](CORE-015.md), [LAB-024-B](LAB-024-B.md), [LAB-082-B](LAB-082-B.md), [LAB-083-B](LAB-083-B.md).

Contract: [LAB-084](../experiments/LAB-084.md). Payoff: Inject loss, jitter, duplication and reordering and inspect recovery instead of hiding transport failures.

## Acceptance

- Fault trace matches selected seed
- Reliable semantic operations do not duplicate
- Timeout becomes explicit failure
- After recovery replicas converge
- Implement real operations, fixture/reset, readiness/fallback and reusable extraction scene
- Resolve exact installed API signatures and per-operation schemas; preserve existing default build

Required evidence: logic, transport, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
