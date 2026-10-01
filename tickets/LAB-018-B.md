# LAB-018-B: Resource Cabinet - Qualification

State: specified. Planned wave: M1 (future lab).
Depends on: [LAB-018-A](LAB-018-A.md), [CORE-006](CORE-006.md), [CORE-018](CORE-018.md).

Contract: [LAB-018](../experiments/LAB-018.md). Payoff: Save and reload a custom Resource while inspecting dependencies and stable identities.

## Acceptance

- Declared fields round-trip
- Stable IDs survive reload
- Dependency failures are visible
- Repeated load policy is explicit
- Unsupported resource type rejects
- Missing dependency does not silently replace with a passing fixture
- Run repeated lifecycle/reset and minimal extraction host
- Capture all required evidence at exact source/fixture/profile; disclose deferred physical gates

Required evidence: logic, interchange, editor. Document actual assertions/tolerances and artifacts. No status promotion from a generated ticket or another revision's proof.
