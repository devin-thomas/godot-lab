# LAB-049-B: Constraint Foundry - Qualification

State: specified. Planned wave: M2 (future lab).
Depends on: [LAB-049-A](LAB-049-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-049](../experiments/LAB-049.md). Payoff: Manipulate3D mechanical joints and inspect angular limits and solver stability.

## Acceptance

- Hinge stays within configured angular tolerance
- Slider stays on intended axis
- Force response is observable
- Reset yields stable initial system
- Invalid body reference rejects
- Extreme unsupported config returns failed probe
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, render, provider. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
