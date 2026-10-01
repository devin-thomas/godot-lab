# LAB-004: Paint & light deepening

Existing bounded proof: [LAB-004](LAB-004.md), [BUILD_STATUS](../docs/BUILD_STATUS.md).

## Expansion interaction contract

Wing: art. Planned wave: M1 baseline deepening; see dependency order.
**All operations and expanded assertions below are specified work.** The six bootstrap routes have separate historical proof; new depth has none yet.

### Player payoff

Separate painted shade, matte light and vertex shade on comparable geometry.

### Mechanisms and operations

Mechanism leads (verify installed APIs; lab-owned types/contracts are proposals):

- ShaderMaterial
- SurfaceTool
- ArrayMesh
- ImageTexture

Proposed typed operations, shared by player UI and supported scenario/CLI/live/MCP adapters:

- `host.command(kind:String,value:String)->void`
- `world.cycle_material()->void`

Before A closes, specify each operation's bounded argument/result schema, readiness, revision/idempotency, event effects and cancellation behavior in source. Names alone are not an implementation.

### Interaction

1. Inspect the three sample cubes
2. Cycle the left active sample
3. Compare with unchanged middle/right references
4. Reset to authored mode

### Fixture, reset and unavailable path

Scenario: `materials`. Fixture: Original 32 x 32 masonry texture and vertex-colored cubes.

Reset ownership: Rebuild mode 0 and its labels with reference samples unchanged.

Limits and unavailable route: Baseline uses Compatibility. Global post-effects and all-renderer parity remain planned.

Use original bounded fixtures with hash/license/seed manifests. Readiness must name the actual missing adapter and a useful labeled fallback if possible. Fixture replay does not establish device/provider support.

### Positive acceptance

- Active mode cycles and labels agree
- Middle/right references stay stable
- Rendered capture contains actual game pixels
- Reset returns authored mode

### Failure and negative controls

- Unknown lab identifier refuses entry
- Missing shader or texture fails resource loading rather than inventing a passing material result

Additionally exercise reset/exit during the longest operation, repeated entry and fixture isolation. Observe real mechanisms; never assign the expected final result to make the assertion pass.

### Evidence and reuse

Required channels: logic, render, provider, export. See [evidence gates](../docs/TEST_STRATEGY.md). Before B closes, define precise assertions/tolerances, record actual source/profile/tool/fixture identity, and distinguish available automatic routes from deferred physical/human gates.

Reusable component: Original painted-surface comparison rig

Qualify this component in a minimal scene outside the museum with injected dependencies. The source and instructions must identify its actual extraction path.

### Delivery

Lab prerequisites: None.
Implementation/deepening: [LAB-004-A](../tickets/LAB-004-A.md). Qualification: [LAB-004-B](../tickets/LAB-004-B.md).
Shared prerequisites and topological order: [ROADMAP](../docs/ROADMAP.md).

Source leads: [Primary documentation](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/index.html), [Primary documentation](https://docs.godotengine.org/en/stable/tutorials/shaders/index.html).
Implementation boundary: Delivered bounded M0 interaction; expansion requirements remain specified.


### Separate depth requirements

- Develop original atlas/UV and vertex-color round-trip examples.
- Add identical-fixture renderer and shader-profile comparisons.
- Compare lighting/bake/gradient-card roles and optional display modes.
- Use regional visual assertions plus documented human art review limits.
