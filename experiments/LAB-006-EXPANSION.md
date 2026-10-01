# LAB-006: Memory archive deepening

Existing bounded proof: [LAB-006](LAB-006.md), [BUILD_STATUS](../docs/BUILD_STATUS.md).

## Expansion interaction contract

Wing: core. Planned wave: M1 baseline deepening; see dependency order.
**All operations and expanded assertions below are specified work.** The six bootstrap routes have separate historical proof; new depth has none yet.

### Player payoff

Write earned seals and comfort preferences then reload a real versioned file.

### Mechanisms and operations

Mechanism leads (verify installed APIs; lab-owned types/contracts are proposals):

- FileAccess
- JSON
- DirAccess

Proposed typed operations, shared by player UI and supported scenario/CLI/live/MCP adapters:

- `store.save_progress()->Error`
- `store.load_progress()->Error`
- `store.complete_lab(id:String)->Error`

Before A closes, specify each operation's bounded argument/result schema, readiness, revision/idempotency, event effects and cancellation behavior in source. Names alone are not an implementation.

### Interaction

1. Earn or inspect seals
2. Save a checkpoint
3. Read the fresh-reader receipt
4. Restart and inspect retained state

### Fixture, reset and unavailable path

Scenario: `persistence`. Fixture: Schema 1 demo file with six known IDs, CALM and MUTE.

Reset ownership: Room reset preserves progress. Automation uses its separate demo-owned file.

Limits and unavailable route: No arbitrary positions, cloud sync or save-slot system. Deep migration work is planned.

Use original bounded fixtures with hash/license/seed manifests. Readiness must name the actual missing adapter and a useful labeled fallback if possible. Fixture replay does not establish device/provider support.

### Positive acceptance

- Fresh reader recovers all six seals
- Fresh process recovers all six seals
- Unsupported/truncated input rejects
- Invalid original file remains until explicit checkpoint repair

### Failure and negative controls

- Unknown lab ID rejects load
- Malformed schema rejects without success-shaped replacement

Additionally exercise reset/exit during the longest operation, repeated entry and fixture isolation. Observe real mechanisms; never assign the expected final result to make the assertion pass.

### Evidence and reuse

Required channels: logic, interchange, export. See [evidence gates](../docs/TEST_STRATEGY.md). Before B closes, define precise assertions/tolerances, record actual source/profile/tool/fixture identity, and distinguish available automatic routes from deferred physical/human gates.

Reusable component: Versioned scoped progress store

Qualify this component in a minimal scene outside the museum with injected dependencies. The source and instructions must identify its actual extraction path.

### Delivery

Lab prerequisites: None.
Implementation/deepening: [LAB-006-A](../tickets/LAB-006-A.md). Qualification: [LAB-006-B](../tickets/LAB-006-B.md).
Shared prerequisites and topological order: [ROADMAP](../docs/ROADMAP.md).

Source leads: [Primary documentation](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html).
Implementation boundary: Delivered bounded M0 interaction; expansion requirements remain specified.


### Separate depth requirements

- Add explicit schema migration and unknown-field preservation policy.
- Demonstrate durable idempotent transactions, recovery and undo.
- Add export/import profiles and conflict/revision fixtures.
- Keep scope-limited reset, corrupt-file preservation and ordinary/automation isolation.
