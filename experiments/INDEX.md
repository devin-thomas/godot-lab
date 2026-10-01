# Capability catalog

The catalog is a map of useful interactions, not a claim that every Godot capability is shipped. Implementation and verification states belong in BUILD_STATUS; future rows below are `specified` only.

## First playable route

| ID | Lab | Player payoff | Scenario ID | Detail |
|---|---|---|---|---|
| LAB-001 | Motion atelier | Move/jump around solid stairs and an obstacle | `motion` | [Contract](LAB-001.md) |
| LAB-002 | Gravity foundry | Send a body through a resettable physics arrangement | `physics` | [Contract](LAB-002.md) |
| LAB-003 | Pathfinder garden | Dispatch a courier around a tower to a fixed gold pad | `navigation` | [Contract](LAB-003.md) |
| LAB-004 | Paint & light | Compare authored, lit, and pixel material treatments | `materials` | [Contract](LAB-004.md) |
| LAB-005 | Signal chamber | Move around an emitter and observe/hear spatial response | `audio` | [Contract](LAB-005.md) |
| LAB-006 | Memory archive | Save earned seals/settings and reload them from disk | `persistence` | [Contract](LAB-006.md) |

## Specified expansion opportunities

All entries in this section are future work. None has a shipped live portal, passed automation, or device support claim merely because it appears here.

| ID | Candidate | Interaction and capability | Gate |
|---|---|---|---|
| LAB-007 | Tile Workshop | Paint a 2D tile room; terrain/autotile and collision change together | M2 |
| LAB-008 | Animation Loom | Blend locomotion and gesture states; inspect AnimationTree transitions | M2 |
| LAB-009 | Particle Weather | Tune GPU/CPU effects and compare bounded emitter costs | Renderer/performance evidence |
| LAB-010 | Light Archive | Compare baked, authored, and dynamic light on identical geometry | Renderer-specific modes |
| LAB-011 | Camera Rig | Try spring arm, occlusion, projection, and framing controls | Comfort evidence |
| LAB-012 | Input Atelier | Rebind actions and inspect last-device glyph switching | Real controller gates |
| LAB-013 | UI Workshop | Navigate a responsive Control layout entirely by keyboard | Focus and accessibility review |
| LAB-014 | Dialogue Machine | Choose branching local dialogue with undoable typed state | Original fixtures |
| LAB-015 | Skeleton Studio | Manipulate IK/skeletal animation and inspect deformation | Original rig |
| LAB-016 | Terrain Foundry | Sculpt/import terrain and observe collision/LOD boundaries | Asset pipeline/performance |
| LAB-017 | Crowd Balcony | Compare instancing and MultiMesh crowd layouts | Recorded profiler evidence |
| LAB-018 | Resource Cabinet | Save/load a custom Resource and inspect dependency behavior | Version/unknown-field policy |
| LAB-019 | Shader Bench | Change shader uniforms and inspect clean comparison views | Rendered assertions |
| LAB-020 | Acoustic Rooms | Compare buses, reverb, filters, and spatial falloff | Encoded audio analysis |
| LAB-021 | Time Laboratory | Compare physics tick, interpolation, slow motion, and pause | Bounded simulation scenarios |
| LAB-022 | Destruction Cell | Break an original modular arrangement with bounded fragments | Resource and collision budgets |
| LAB-023 | Procedural Garden | Seed generation and compare connectivity/playable routes | Seed, connectivity assertions |
| LAB-024 | Network Commons | Join two local processes and compare authority/replication | Two-process transport evidence |
| LAB-025 | Replay Observatory | Record operations and replay a versioned semantic timeline | Schema/compatibility evidence |
| LAB-026 | Editor Toolroom | Build a small tool plugin with undo/redo | Editor-only boundary |
| LAB-027 | Native Bridge | Compare a narrow GDExtension against GDScript | Reproducible native builds |
| LAB-028 | Thread Mill | Run a bounded cancellable background task | Main-thread safety evidence |
| LAB-029 | Streaming Depot | Load/unload scene chunks while preserving scoped state | Memory and transition evidence |
| LAB-030 | Large World | Inspect origin strategy and precision at meaningful distances | Specific precision/performance tests |
| LAB-031 | Renderer Gallery | Compare Compatibility, Mobile, and Forward+ behavior | Separate host/renderer evidence |
| LAB-032 | Web Portal | Export and play a bounded route in a browser | Browser/Web export evidence |
| LAB-033 | Mobile Field Kit | Touch controls and device sensor experiments | Physical-device gate |
| LAB-034 | XR Room | Interact through tracked input and spatial rendering | XR hardware gate |
| LAB-035 | Import Studio | Inspect mesh/material/animation import differences | Licensed original fixtures |
| LAB-036 | Profiling Booth | Compare a controlled expensive scene before/after optimization | Recorded profiler measurements |

Add a candidate only when its payoff and gate are concrete. Use [TEMPLATE](TEMPLATE.md) before implementation and [EXTENSION_CONTRACT](../docs/EXTENSION_CONTRACT.md) before promoting its status.
