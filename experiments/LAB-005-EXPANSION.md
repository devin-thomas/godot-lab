# LAB-005: Signal chamber deepening

Existing bounded proof: [LAB-005](LAB-005.md), [BUILD_STATUS](../docs/BUILD_STATUS.md).

## Expansion interaction contract

Wing: audio. Planned wave: M1 baseline deepening; see dependency order.
**All operations and expanded assertions below are specified work.** The six bootstrap routes have separate historical proof; new depth has none yet.

### Player payoff

Hear distance and stereo change around a visible original tone emitter.

### Mechanisms and operations

Mechanism leads (verify installed APIs; lab-owned types/contracts are proposals):

- AudioStreamPlayer3D
- AudioListener3D
- AudioStreamWAV

Proposed typed operations, shared by player UI and supported scenario/CLI/live/MCP adapters:

- `host.command(kind:String,value:String)->void`
- `world.toggle_audio()->void`

Before A closes, specify each operation's bounded argument/result schema, readiness, revision/idempotency, event effects and cancellation behavior in source. Names alone are not an implementation.

### Interaction

1. Start the 220 Hz signal
2. Walk near and far
3. Move between lateral positions
4. Stop or reset the source

### Fixture, reset and unavailable path

Scenario: `audio`. Fixture: Original one-second looped mono220 Hz PCM tone and visible cabinet.

Reset ownership: Rebuild a stopped emitter and retain mute preference.

Limits and unavailable route: Encoded24 kHz stereo proof is not speaker, headphone, comfort or device qualification.

Use original bounded fixtures with hash/license/seed manifests. Readiness must name the actual missing adapter and a useful labeled fallback if possible. Fixture replay does not establish device/provider support.

### Positive acceptance

- Encoded output is non-silent
- Near RMS exceeds far RMS
- Left/right phase channel dominance swaps
- Dominant recorded frequency is220 Hz

### Failure and negative controls

- Mute deliberately silences the master bus
- Exit/reset stops the source

Additionally exercise reset/exit during the longest operation, repeated entry and fixture isolation. Observe real mechanisms; never assign the expected final result to make the assertion pass.

### Evidence and reuse

Required channels: logic, render, audio, provider, export. See [evidence gates](../docs/TEST_STRATEGY.md). Before B closes, define precise assertions/tolerances, record actual source/profile/tool/fixture identity, and distinguish available automatic routes from deferred physical/human gates.

Reusable component: Scoped spatial-tone emitter and PCM proof gate

Qualify this component in a minimal scene outside the museum with injected dependencies. The source and instructions must identify its actual extraction path.

### Delivery

Lab prerequisites: None.
Implementation/deepening: [LAB-005-A](../tickets/LAB-005-A.md). Qualification: [LAB-005-B](../tickets/LAB-005-B.md).
Shared prerequisites and topological order: [ROADMAP](../docs/ROADMAP.md).

Source leads: [Primary documentation](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html).
Implementation boundary: Delivered bounded M0 interaction; expansion requirements remain specified.


### Separate depth requirements

- Add buses, effects, synchronized music and reviewed speech/captions.
- Exercise muted/missing-device/unsupported-output paths.
- Add actual channel/timing analysis for new fixtures rather than playing flags.
- Separate encoded proof from later speaker/headphone comfort.
