# LAB-003: Pathfinder garden deepening

Existing bounded proof: [LAB-003](LAB-003.md), [BUILD_STATUS](../docs/BUILD_STATUS.md).

## Expansion interaction contract

Wing: world. Planned wave: M1 baseline deepening; see dependency order.
**All operations and expanded assertions below are specified work.** The six bootstrap routes have separate historical proof; new depth has none yet.

### Player payoff

Dispatch a courier around a tower to a fixed destination.

### Mechanisms and operations

Mechanism leads (verify installed APIs; lab-owned types/contracts are proposals):

- NavigationAgent3D
- NavigationMesh
- NavigationRegion3D

Proposed typed operations, shared by player UI and supported scenario/CLI/live/MCP adapters:

- `host.command(kind:String,value:String)->void`
- `world.start_navigation()->void`

Before A closes, specify each operation's bounded argument/result schema, readiness, revision/idempotency, event effects and cancellation behavior in source. Names alone are not an implementation.

### Interaction

1. Enter the authored navigation island
2. Dispatch the courier from its mint origin
3. Watch its non-straight path to the gold pad
4. Reset and dispatch again

### Fixture, reset and unavailable path

Scenario: `navigation`. Fixture: Original tower, authored mesh hole, mint courier and gold pad.

Reset ownership: Rebuild actor/map baseline and clear arrival state.

Limits and unavailable route: No free destination selection, rebaking, crowd avoidance or broad navigation guarantee yet.

Use original bounded fixtures with hash/license/seed manifests. Readiness must name the actual missing adapter and a useful labeled fallback if possible. Fixture replay does not establish device/provider support.

### Positive acceptance

- Actual path has multiple points
- Courier reaches within one unit of fixed destination
- Reset clears travel and arrival state

### Failure and negative controls

- Unavailable map must not invent arrival
- Leaving during travel cancels the room

Additionally exercise reset/exit during the longest operation, repeated entry and fixture isolation. Observe real mechanisms; never assign the expected final result to make the assertion pass.

### Evidence and reuse

Required channels: logic, render, provider, export. See [evidence gates](../docs/TEST_STRATEGY.md). Before B closes, define precise assertions/tolerances, record actual source/profile/tool/fixture identity, and distinguish available automatic routes from deferred physical/human gates.

Reusable component: Authored obstacle-routing example

Qualify this component in a minimal scene outside the museum with injected dependencies. The source and instructions must identify its actual extraction path.

### Delivery

Lab prerequisites: None.
Implementation/deepening: [LAB-003-A](../tickets/LAB-003-A.md). Qualification: [LAB-003-B](../tickets/LAB-003-B.md).
Shared prerequisites and topological order: [ROADMAP](../docs/ROADMAP.md).

Source leads: [Primary documentation](https://docs.godotengine.org/en/stable/tutorials/3d/procedural_geometry/index.html), [Primary documentation](https://docs.godotengine.org/en/stable/classes/class_navigationagent3d.html).
Implementation boundary: Delivered bounded M0 interaction; expansion requirements remain specified.


### Separate depth requirements

- Add selectable destinations and explicitly unreachable targets.
- Compare authored, runtime-rebuilt and avoidance routes.
- Add multi-agent bottleneck and reset-during-travel checks.
- Verify map synchronization and obstacle/path correspondence.
