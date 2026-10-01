# LAB-084-B: Network Chaos - Qualification

State: specified. Planned wave: M4 (future lab).
Depends on: [LAB-084-A](LAB-084-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-084](../experiments/LAB-084.md). Payoff: Inject loss, jitter, duplication and reordering and inspect recovery instead of hiding transport failures.

## Acceptance

- Fault trace matches selected seed
- Reliable semantic operations do not duplicate
- Timeout becomes explicit failure
- After recovery replicas converge
- Impossible/unbounded delay profile rejects
- Proxy exit reports broken transport
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, transport, profiling. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
