# Composed public journeys

Generated from planning/journeys.json. Eight specified executable experiences; the existing bootstrap tour is the only current route. These contracts require qualified lab components and real handoffs, not badge aggregation.

## JOURNEY-001: Courier Circuit

State: specified. Wave: M1.

Paint a small route, move through it, dispatch a courier and keep a portable record of the delivery.

Prerequisites (qualified B tickets): [LAB-001](../experiments/LAB-001.md), [LAB-003](../experiments/LAB-003.md), [LAB-007](../experiments/LAB-007.md), [LAB-011](../experiments/LAB-011.md), [LAB-012](../experiments/LAB-012.md), [LAB-018](../experiments/LAB-018.md), [LAB-025](../experiments/LAB-025.md).

Cross-lab handoff: An original route document carries cell IDs, courier target, seed and semantic events into the navigation scene and replay viewer.

### Player sequence

1. Edit a bounded tile route and inspect collisions
2. Traverse with ordinary input and dispatch the courier
3. Compare the courier path with the player route
4. Select a viewer camera, export the route and replay its receipt sequence

### Integrated acceptance

- Edited cells affect actual collision/navigation
- Courier arrival follows the allowed route
- Player and scenario share operations
- Document round-trip preserves semantic IDs
- Replay resets and reproduces arrival within tolerance

### Failure and recovery

- Blocked destination yields explicit unreachable result
- Malformed route never replaces the good fixture
- Exit/reset cancels dispatch and preserves ordinary seals

Qualify normal input and the shared automation route through the entire experience, reset mid-route, restart where durability is claimed, and record actual source/fixture/profile/capture identity. No physical/human claims without a session.

## JOURNEY-002: Clockwork Duel

State: specified. Wave: M2.

Play a readable timed duel against an original mechanical actor and compare its animation, impact and sound treatments.

Prerequisites (qualified B tickets): [LAB-001](../experiments/LAB-001.md), [LAB-008](../experiments/LAB-008.md), [LAB-011](../experiments/LAB-011.md), [LAB-015](../experiments/LAB-015.md), [LAB-021](../experiments/LAB-021.md), [LAB-022](../experiments/LAB-022.md), [LAB-043](../experiments/LAB-043.md), [LAB-063](../experiments/LAB-063.md), [LAB-071](../experiments/LAB-071.md).

Cross-lab handoff: Combat events identify attack windows, contacts and impact ticks; the rig, effects, camera and mixer subscribe to those same events.

### Player sequence

1. Choose original actor and stepped/smooth presentation
2. Move, guard and trigger attacks with ordinary controls
3. Inspect windup/contact/recovery, hit-stop and impact cues
4. Replay a bounded duel at alternate presentation rates without changing its outcome

### Integrated acceptance

- Hits occur only in declared contact windows
- Animation blends/layers preserve the actor root contract
- Hit-stop and mixer cues align with contact events
- Viewer changes do not alter duel simulation
- Reduced motion keeps combat state readable

### Failure and recovery

- Missing clip/rig marker prevents activation visibly
- Invalid attack during recovery is rejected
- Reset during impact clears actors, effects and audio

Qualify normal input and the shared automation route through the entire experience, reset mid-route, restart where durability is claimed, and record actual source/fixture/profile/capture identity. No physical/human claims without a session.

## JOURNEY-003: Weather Postcard

State: specified. Wave: M3.

Grow an original island, shift its weather and light, and take a framed moving postcard with honest renderer comparisons.

Prerequisites (qualified B tickets): [LAB-009](../experiments/LAB-009.md), [LAB-010](../experiments/LAB-010.md), [LAB-016](../experiments/LAB-016.md), [LAB-019](../experiments/LAB-019.md), [LAB-023](../experiments/LAB-023.md), [LAB-031](../experiments/LAB-031.md), [LAB-058](../experiments/LAB-058.md), [LAB-060](../experiments/LAB-060.md), [LAB-061](../experiments/LAB-061.md), [LAB-065](../experiments/LAB-065.md), [LAB-090](../experiments/LAB-090.md).

Cross-lab handoff: A seed and scene recipe bind terrain, placement, atlas/vertex shade, world clock, weather and camera cues to one source-bound take.

### Player sequence

1. Select a bounded seed and paint the island palette
2. Grow terrain/props and explore their silhouettes
3. Move the clock, light and weather through comparison presets
4. Capture an independent viewer take and inspect pixels/metrics

### Integrated acceptance

- Seed reproduces declared terrain/placement
- Weather/light changes are visible in temporal frames
- Authored shading is distinguishable from live lighting
- Renderer fallback identifies unavailable mechanisms
- Camera take does not move the playable actor

### Failure and recovery

- Oversized generation rejects before memory growth
- Unsupported fog/shader path reports fallback
- Cancelled take leaves prior postcard intact

Qualify normal input and the shared automation route through the entire experience, reset mid-route, restart where durability is claimed, and record actual source/fixture/profile/capture identity. No physical/human claims without a session.

## JOURNEY-004: Story Caravan

State: specified. Wave: M3.

Collect an original item, resolve a branching task, change language and resume the same story after restart.

Prerequisites (qualified B tickets): [LAB-006](../experiments/LAB-006.md), [LAB-013](../experiments/LAB-013.md), [LAB-014](../experiments/LAB-014.md), [LAB-018](../experiments/LAB-018.md), [LAB-074](../experiments/LAB-074.md), [LAB-075](../experiments/LAB-075.md), [LAB-077](../experiments/LAB-077.md), [LAB-078](../experiments/LAB-078.md), [LAB-079](../experiments/LAB-079.md), [LAB-080](../experiments/LAB-080.md).

Cross-lab handoff: Stable quest/item/dialogue IDs and versioned state survive localization, document export and a process restart.

### Player sequence

1. Navigate the caravan with keyboard/focus and comfortable text
2. Choose dialogue and inspect a quest transition
3. Craft/collect an item that fulfills the task
4. Change locale, save/export and resume after restart

### Integrated acceptance

- Only valid state transitions consume items
- Dialogue/quest state survives real files and restart
- Locale changes labels without changing semantic IDs
- Focus recovery preserves the active action
- Malformed imports preserve the existing story

### Failure and recovery

- Unknown quest edge rejects visibly
- Duplicate request cannot consume an item twice
- Unsupported/newer schema does not reset user progress

Qualify normal input and the shared automation route through the entire experience, reset mid-route, restart where durability is claimed, and record actual source/fixture/profile/capture identity. No physical/human claims without a session.

## JOURNEY-005: Signal Orchestra

State: specified. Wave: M3.

Walk through acoustic spaces and conduct original timed music/voice cues while inspecting captured sound and captions.

Prerequisites (qualified B tickets): [LAB-005](../experiments/LAB-005.md), [LAB-020](../experiments/LAB-020.md), [LAB-021](../experiments/LAB-021.md), [LAB-071](../experiments/LAB-071.md), [LAB-072](../experiments/LAB-072.md), [LAB-073](../experiments/LAB-073.md), [LAB-088](../experiments/LAB-088.md).

Cross-lab handoff: One cue timeline links simulation events, audio buses, source positions, original speech fixtures and caption timestamps.

### Player sequence

1. Move near/far and left/right of audible sources
2. Switch acoustic and bus-routing presets
3. Conduct a bounded synchronized cue sequence
4. Capture and compare decoded sound/caption timing

### Integrated acceptance

- Encoded channels show expected positional changes
- Bus effects have measurable differences without clipping
- Music cues align within declared timing tolerance
- Original speech captions match authored fixture timing
- Mute and reset stop owned sound without losing progress

### Failure and recovery

- Missing device/provider reports unavailable capture
- Late cue is handled according to clock policy
- Silent/corrupt recording fails the media gate

Qualify normal input and the shared automation route through the entire experience, reset mid-route, restart where durability is claimed, and record actual source/fixture/profile/capture identity. No physical/human claims without a session.

## JOURNEY-006: Two Worlds Together

State: specified. Wave: M4.

Play a shared delivery with two local processes, then inspect prediction, network loss and reconnection.

Prerequisites (qualified B tickets): [LAB-006](../experiments/LAB-006.md), [LAB-012](../experiments/LAB-012.md), [LAB-024](../experiments/LAB-024.md), [LAB-025](../experiments/LAB-025.md), [LAB-082](../experiments/LAB-082.md), [LAB-083](../experiments/LAB-083.md), [LAB-084](../experiments/LAB-084.md), [LAB-085](../experiments/LAB-085.md).

Cross-lab handoff: An explicit paired session owns authoritative entity IDs, ordered commands, replaceable samples and reconnection checkpoints.

### Player sequence

1. Start separate local host/client and pair explicitly
2. Move and deliver an object in the shared world
3. Inject bounded delay/loss and inspect prediction correction
4. Disconnect/reconnect and replay the authoritative result

### Integrated acceptance

- Real separate peers share authoritative state
- Unauthorized clients cannot apply durable operations
- Duplicate/late messages follow the declared policy
- Reconnect converges within tolerance
- Offline fixture is labeled as simulation

### Failure and recovery

- Protocol mismatch rejects pairing
- Packet storm is rate/budget bounded
- Reset/session exit releases listeners and peer state

Qualify normal input and the shared automation route through the entire experience, reset mid-route, restart where durability is claimed, and record actual source/fixture/profile/capture identity. No physical/human claims without a session.

## JOURNEY-007: Maker to Movie

State: specified. Wave: M4.

Author an original rigged prop, play with it, direct it live while recording and compare a bounded revision sweep.

Prerequisites (qualified B tickets): [LAB-008](../experiments/LAB-008.md), [LAB-015](../experiments/LAB-015.md), [LAB-026](../experiments/LAB-026.md), [LAB-035](../experiments/LAB-035.md), [LAB-060](../experiments/LAB-060.md), [LAB-061](../experiments/LAB-061.md), [LAB-087](../experiments/LAB-087.md), [LAB-088](../experiments/LAB-088.md), [LAB-089](../experiments/LAB-089.md), [LAB-090](../experiments/LAB-090.md), [LAB-091](../experiments/LAB-091.md), [LAB-095](../experiments/LAB-095.md).

Cross-lab handoff: Recipe, imported attribute manifest, live operation receipts, simulation record and viewer track become one source-bound capture/evidence package.

### Player sequence

1. Run a bounded original Blender recipe and validate interchange
2. Explore the imported rig/clip/material in ordinary play
3. Use CLI/MCP/live controls in the same Cappy-recorded session
4. Produce event-anchored takes and compare approved parameter variants

### Integrated acceptance

- UV/color/rig/clip/unit markers survive declared round trip
- One session serves live control and real Cappy capture
- Operations and movie events align
- Comparison binds exact source/fixture/look/profile
- Cancelled worker preserves prior good output

### Failure and recovery

- Missing attribute/license or corrupt asset rejects activation
- Stale build evidence cannot qualify current source
- Provider loss/worker capacity failure produces no success artifact

Qualify normal input and the shared automation route through the entire experience, reset mid-route, restart where durability is claimed, and record actual source/fixture/profile/capture identity. No physical/human claims without a session.

## JOURNEY-008: Device Expedition

State: specified. Wave: M5.

Carry a small original interaction across available exports and spatial/input adapters, seeing readiness and limits honestly.

Prerequisites (qualified B tickets): [LAB-012](../experiments/LAB-012.md), [LAB-013](../experiments/LAB-013.md), [LAB-027](../experiments/LAB-027.md), [LAB-032](../experiments/LAB-032.md), [LAB-033](../experiments/LAB-033.md), [LAB-034](../experiments/LAB-034.md), [LAB-080](../experiments/LAB-080.md), [LAB-094](../experiments/LAB-094.md), [LAB-096](../experiments/LAB-096.md).

Cross-lab handoff: A portable interaction fixture and operation record retain semantic IDs while each target owns its input/presentation adapter and evidence.

### Player sequence

1. Select a probed target/profile and inspect missing gates
2. Operate the fixture with available native/browser/spatial input
3. Compare input receipts and comfort modes
4. Export/test the available route and inspect deferred device gates

### Integrated acceptance

- Default desktop remains independently playable
- Actual target build/export is tested separately
- Unavailable adapter has a meaningful labeled fixture route
- Input maps to equivalent semantic operations
- Physical sensor/XR/comfort claims remain pending without devices

### Failure and recovery

- Missing SDK/plugin/permission reports exact readiness reason
- Unsupported native ABI is not loaded
- Lifecycle interruption resets owned input/session state

Qualify normal input and the shared automation route through the entire experience, reset mid-route, restart where durability is claimed, and record actual source/fixture/profile/capture identity. No physical/human claims without a session.
