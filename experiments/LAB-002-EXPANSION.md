# LAB-002: Gravity foundry deepening

Existing bounded proof: [LAB-002](LAB-002.md), [BUILD_STATUS](../docs/BUILD_STATUS.md).

## Expansion interaction contract

Wing: simulation. Planned wave: M1 baseline deepening; see dependency order.
**All operations and expanded assertions below are specified work.** The six bootstrap routes have separate historical proof; new depth has none yet.

### Player payoff

Launch a weighted cube and inspect actual impulse, contacts and settling.

### Mechanisms and operations

Mechanism leads (verify installed APIs; lab-owned types/contracts are proposals):

- RigidBody3D
- StaticBody3D
- CollisionShape3D

Proposed typed operations, shared by player UI and supported scenario/CLI/live/MCP adapters:

- `host.command(kind:String,value:String)->void`
- `world.launch_body()->RigidBody3D`

Before A closes, specify each operation's bounded argument/result schema, readiness, revision/idempotency, event effects and cancellation behavior in source. Names alone are not an implementation.

### Interaction

1. Enter the six-body arrangement
2. Apply launch impulse
3. Observe cube displacement and settling
4. Reset before another take

### Fixture, reset and unavailable path

Scenario: `physics`. Fixture: Six original cubes, raised plinth and floor.

Reset ownership: Rebuild the six-body baseline and release transient bodies.

Limits and unavailable route: No bit-identical cross-host physics or full destruction claim.

Use original bounded fixtures with hash/license/seed manifests. Readiness must name the actual missing adapter and a useful labeled fallback if possible. Fixture replay does not establish device/provider support.

### Positive acceptance

- Launch adds one real body
- Body travels from launch position and settles within tolerance
- Reset restores six bodies

### Failure and negative controls

- Twenty-four body budget refuses further spawning
- Leaving releases the arrangement

Additionally exercise reset/exit during the longest operation, repeated entry and fixture isolation. Observe real mechanisms; never assign the expected final result to make the assertion pass.

### Evidence and reuse

Required channels: logic, render, provider, export. See [evidence gates](../docs/TEST_STRATEGY.md). Before B closes, define precise assertions/tolerances, record actual source/profile/tool/fixture identity, and distinguish available automatic routes from deferred physical/human gates.

Reusable component: Bounded rigid-body launch rig

Qualify this component in a minimal scene outside the museum with injected dependencies. The source and instructions must identify its actual extraction path.

### Delivery

Lab prerequisites: None.
Implementation/deepening: [LAB-002-A](../tickets/LAB-002-A.md). Qualification: [LAB-002-B](../tickets/LAB-002-B.md).
Shared prerequisites and topological order: [ROADMAP](../docs/ROADMAP.md).

Source leads: [Primary documentation](https://docs.godotengine.org/en/stable/tutorials/physics/index.html).
Implementation boundary: Delivered bounded M0 interaction; expansion requirements remain specified.


### Separate depth requirements

- Add mass/friction/restitution sweeps with recorded tolerances.
- Compare jointed mechanisms and high-speed collision.
- Expose contact/impulse diagnostics and meaningful reset receipts.
- Measure solver/resource costs across recorded engine/backend profiles.
