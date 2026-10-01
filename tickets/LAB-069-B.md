# LAB-069-B: Compute Garden - Qualification

State: specified. Planned wave: M4 (future lab).
Depends on: [LAB-069-A](LAB-069-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-069](../experiments/LAB-069.md). Payoff: Run a small compute fixture and compare output against a CPU reference with honest availability.

## Acceptance

- GPU/reference outputs match defined tolerance
- Readback identifies actual backend
- Unsupported route reports unavailable
- Repeated runs release allocated resources
- Oversized dispatch rejects
- Shader failure preserves reference result without claiming GPU success
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, profiling, render. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
