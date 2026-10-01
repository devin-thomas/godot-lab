# LAB-001: Motion atelier deepening

Existing bounded proof: [LAB-001](LAB-001.md), [BUILD_STATUS](../docs/BUILD_STATUS.md).

## Expansion interaction contract

Wing: motion. Planned wave: M1 baseline deepening; see dependency order.
**This page specifies the full target contract.** Narrower playable prototypes and their actual APIs/evidence are recorded in [implementation waves](../docs/IMPLEMENTATION_WAVES.md) and [build status](../docs/BUILD_STATUS.md). The six bootstrap routes retain separate historical proof; prototype checks do not complete this expanded contract.

### Player payoff

Feel a real capsule move, jump and land against stairs and a solid block.

### Mechanisms and operations

Mechanism leads (verify installed APIs; lab-owned types/contracts are proposals):

- CharacterBody3D
- InputMap
- CollisionShape3D

Proposed typed operations, shared by player UI and supported scenario/CLI/live/MCP adapters:

- `host.command(kind:String,value:String)->void`
- `player.teleport(at:Vector3)->void`

Before A closes, specify each operation's bounded argument/result schema, readiness, revision/idempotency, event effects and cancellation behavior in source. Names alone are not an implementation.

### Interaction

1. Enter the motion room
2. Move with screen-relative input and jump
3. Read traveled distance and jump/landing state
4. Rebuild the room and return to the hub

### Fixture, reset and unavailable path

Scenario: `motion`. Fixture: Original five stairs, coral block and capsule player.

Reset ownership: Rebuild this room and restore player transform/velocity without deleting seals.

Limits and unavailable route: Baseline Windows proof only. Synthetic controller event is not physical-controller evidence.

Use original bounded fixtures with hash/license/seed manifests. Readiness must name the actual missing adapter and a useful labeled fallback if possible. Fixture replay does not establish device/provider support.

### Positive acceptance

- Actual travel exceeds two units and one jump occurs
- Character lands on the floor
- Solid obstacle blocks travel
- Room reset clears motion baseline

### Failure and negative controls

- Unknown lab ID rejects entry
- Falling below the room teleports to the start

Additionally exercise reset/exit during the longest operation, repeated entry and fixture isolation. Observe real mechanisms; never assign the expected final result to make the assertion pass.

### Evidence and reuse

Required channels: logic, render, provider, export. See [evidence gates](../docs/TEST_STRATEGY.md). Before B closes, define precise assertions/tolerances, record actual source/profile/tool/fixture identity, and distinguish available automatic routes from deferred physical/human gates.

Reusable component: Character movement and observation adapter

Qualify this component in a minimal scene outside the museum with injected dependencies. The source and instructions must identify its actual extraction path.

### Delivery

Lab prerequisites: None.
Implementation/deepening: [LAB-001-A](../tickets/LAB-001-A.md). Qualification: [LAB-001-B](../tickets/LAB-001-B.md).
Shared prerequisites and topological order: [ROADMAP](../docs/ROADMAP.md).

Source leads: [Primary documentation](https://docs.godotengine.org/en/stable/tutorials/physics/index.html).
Implementation boundary: Delivered bounded M0 interaction; expansion requirements remain specified.


### Separate depth requirements

- Separate reusable player/controller modules from host assembly.
- Add input buffering, coyote time and analog profiles with boundary assertions.
- Add slope, moving-platform and camera-occlusion comparisons.
- Keep actual-controller and human-comfort gates separate from synthetic events.
