# Capability matrix

Generated from planning/catalog.json by scripts/plan.py. 96 full laboratory contracts; six bounded baseline routes and 90 expanded targets. First-six depth is separately specified. Narrower playable code/evidence is tracked in [implementation waves](IMPLEMENTATION_WAVES.md); API leads require installed-engine probes.

## Coverage

| Wing | Labs |
|---|---|
| core | 6 |
| motion | 10 |
| simulation | 10 |
| world | 10 |
| art | 6 |
| rendering | 10 |
| audio | 5 |
| narrative | 5 |
| interfaces | 6 |
| networking | 6 |
| automation | 6 |
| tooling | 4 |
| performance | 5 |
| interchange | 3 |
| platforms | 2 |
| xr | 2 |

| Wave | Lab assignments |
|---|---|
| M0 | 6 |
| M1 | 13 |
| M2 | 34 |
| M3 | 29 |
| M4 | 10 |
| M5 | 4 |

## Contracts

| Lab | Wing / wave | Mechanisms | Required evidence | Lab prerequisites |
|---|---|---|---|---|
| [LAB-001: Motion atelier](../experiments/LAB-001.md) | motion / M0 | CharacterBody3D; InputMap; CollisionShape3D | logic, render, provider, export | None |
| [LAB-002: Gravity foundry](../experiments/LAB-002.md) | simulation / M0 | RigidBody3D; StaticBody3D; CollisionShape3D | logic, render, provider, export | None |
| [LAB-003: Pathfinder garden](../experiments/LAB-003.md) | world / M0 | NavigationAgent3D; NavigationMesh; NavigationRegion3D | logic, render, provider, export | None |
| [LAB-004: Paint & light](../experiments/LAB-004.md) | art / M0 | ShaderMaterial; SurfaceTool; ArrayMesh; ImageTexture | logic, render, provider, export | None |
| [LAB-005: Signal chamber](../experiments/LAB-005.md) | audio / M0 | AudioStreamPlayer3D; AudioListener3D; AudioStreamWAV | logic, render, audio, provider, export | None |
| [LAB-006: Memory archive](../experiments/LAB-006.md) | core / M0 | FileAccess; JSON; DirAccess | logic, interchange, export | None |
| [LAB-007: Tile Workshop](../experiments/LAB-007.md) | world / M1 | TileMapLayer; TileSet; TileSetAtlasSource | logic, render, provider | LAB-001, LAB-006 |
| [LAB-008: Animation Loom](../experiments/LAB-008.md) | motion / M1 | AnimationTree; AnimationPlayer; AnimationNodeStateMachine | logic, render, provider | LAB-001 |
| [LAB-009: Particle Weather](../experiments/LAB-009.md) | rendering / M2 | GPUParticles3D; CPUParticles3D; ParticleProcessMaterial; GPUParticles2D; CPUParticles2D | logic, render, profiling, provider | LAB-004, LAB-036 |
| [LAB-010: Light Archive](../experiments/LAB-010.md) | rendering / M2 | LightmapGI; DirectionalLight3D; WorldEnvironment; PointLight2D; LightOccluder2D; CanvasModulate | render, profiling, editor, provider | LAB-004, LAB-031 |
| [LAB-011: Camera Rig](../experiments/LAB-011.md) | motion / M1 | Camera3D; SpringArm3D; RayCast3D | logic, render, provider | LAB-001 |
| [LAB-012: Input Atelier](../experiments/LAB-012.md) | interfaces / M1 | InputMap; InputEventKey; InputEventJoypadButton | logic, render, physical | LAB-001, LAB-013 |
| [LAB-013: UI Workshop](../experiments/LAB-013.md) | interfaces / M1 | Control; Container; Theme; Focus neighbors | logic, render, export | LAB-006 |
| [LAB-014: Dialogue Machine](../experiments/LAB-014.md) | narrative / M1 | Resource; RichTextLabel; proposed DialogueGraph contract | logic, render, interchange | LAB-006, LAB-013 |
| [LAB-015: Skeleton Studio](../experiments/LAB-015.md) | motion / M2 | Skeleton3D; SkeletonModifier3D; AnimationMixer | logic, render, interchange | LAB-008, LAB-035 |
| [LAB-016: Terrain Foundry](../experiments/LAB-016.md) | world / M2 | ArrayMesh; HeightMapShape3D; proposed TerrainPatch contract | logic, render, profiling | LAB-001, LAB-035 |
| [LAB-017: Crowd Balcony](../experiments/LAB-017.md) | performance / M2 | MultiMesh; MultiMeshInstance3D; Performance | logic, render, profiling, provider | LAB-036 |
| [LAB-018: Resource Cabinet](../experiments/LAB-018.md) | interchange / M1 | Resource; ResourceSaver; ResourceLoader | logic, interchange, editor | LAB-006 |
| [LAB-019: Shader Bench](../experiments/LAB-019.md) | rendering / M2 | Shader; ShaderMaterial; SubViewport | logic, render, provider | LAB-004 |
| [LAB-020: Acoustic Rooms](../experiments/LAB-020.md) | audio / M2 | AudioServer; AudioEffectReverb; AudioEffectLowPassFilter | logic, audio, provider | LAB-005 |
| [LAB-021: Time Laboratory](../experiments/LAB-021.md) | simulation / M2 | Engine; SceneTree; Node.process_mode | logic, render, profiling | LAB-001, LAB-002 |
| [LAB-022: Destruction Cell](../experiments/LAB-022.md) | simulation / M2 | RigidBody3D; Joint3D; proposed FractureRecipe contract | logic, render, profiling, provider | LAB-002, LAB-049 |
| [LAB-023: Procedural Garden](../experiments/LAB-023.md) | world / M2 | RandomNumberGenerator; AStarGrid2D; proposed LayoutRecipe contract | logic, render, interchange | LAB-007, LAB-006 |
| [LAB-024: Network Commons](../experiments/LAB-024.md) | networking / M3 | ENetMultiplayerPeer; MultiplayerAPI; MultiplayerSpawner; MultiplayerSynchronizer | logic, transport, render, provider | LAB-006 |
| [LAB-025: Replay Observatory](../experiments/LAB-025.md) | automation / M1 | InputEvent; FileAccess; proposed OperationTimeline contract | logic, render, provider, interchange | LAB-001, LAB-004, LAB-006 |
| [LAB-026: Editor Toolroom](../experiments/LAB-026.md) | tooling / M3 | EditorPlugin; EditorUndoRedoManager; EditorInterface; EditorInspectorPlugin | logic, editor, interchange | LAB-018 |
| [LAB-027: Native Bridge](../experiments/LAB-027.md) | tooling / M4 | GDExtension; ClassDB; proposed NativeKernel contract | logic, profiling, export | LAB-036, LAB-018 |
| [LAB-028: Thread Mill](../experiments/LAB-028.md) | performance / M3 | WorkerThreadPool; Mutex; proposed JobReceipt contract | logic, profiling | LAB-023, LAB-036 |
| [LAB-029: Streaming Depot](../experiments/LAB-029.md) | world / M3 | ResourceLoader; PackedScene; proposed ChunkLedger contract | logic, render, profiling | LAB-006, LAB-028 |
| [LAB-030: Large World](../experiments/LAB-030.md) | world / M4 | Node3D; Transform3D; proposed OriginLedger contract | logic, render, profiling | LAB-029, LAB-002 |
| [LAB-031: Renderer Gallery](../experiments/LAB-031.md) | rendering / M2 | RenderingServer; ProjectSettings; WorldEnvironment | render, export, profiling | LAB-004, LAB-036 |
| [LAB-032: Web Portal](../experiments/LAB-032.md) | platforms / M4 | EditorExportPlatformWeb; Input; FileAccess | logic, render, export, interchange | LAB-013, LAB-006, LAB-094 |
| [LAB-033: Mobile Field Kit](../experiments/LAB-033.md) | platforms / M5 | InputEventScreenTouch; InputEventScreenDrag; Input | logic, render, export, physical | LAB-012, LAB-032 |
| [LAB-034: XR Room](../experiments/LAB-034.md) | xr / M5 | XRServer; XROrigin3D; XRController3D; OpenXRInterface | logic, render, physical, export | LAB-001, LAB-049, LAB-012 |
| [LAB-035: Import Studio](../experiments/LAB-035.md) | interchange / M2 | GLTFDocument; GLTFState; ResourceImporterScene | logic, render, editor, interchange | LAB-018, LAB-004 |
| [LAB-036: Profiling Booth](../experiments/LAB-036.md) | performance / M2 | Performance; Engine; RenderingServer | logic, render, profiling | LAB-004 |
| [LAB-037: Capability Compass](../experiments/LAB-037.md) | core / M1 | Resource; Control; proposed CapabilityManifest contract | logic, render, interchange | LAB-013, LAB-018 |
| [LAB-038: Operation Desk](../experiments/LAB-038.md) | core / M1 | Callable; Signal; proposed OperationEnvelope contract | logic, render, interchange | LAB-006, LAB-025 |
| [LAB-039: Fixture Pantry](../experiments/LAB-039.md) | core / M2 | ResourceLoader; JSON; proposed FixtureEnvelope contract | logic, render, interchange | LAB-018, LAB-035 |
| [LAB-040: Pause Vestibule](../experiments/LAB-040.md) | core / M3 | SceneTree; Node.process_mode; Control | logic, render, audio | LAB-021, LAB-028, LAB-013 |
| [LAB-041: Signal Switchboard](../experiments/LAB-041.md) | core / M1 | Signal; Callable; SceneTree groups | logic, render | LAB-038 |
| [LAB-042: 2D Movement](../experiments/LAB-042.md) | motion / M1 | CharacterBody2D; ShapeCast2D; InputMap | logic, render, provider | LAB-007, LAB-012 |
| [LAB-043: Combat Clock](../experiments/LAB-043.md) | motion / M2 | Area3D; AnimationPlayer; Engine; proposed CombatTimeline contract | logic, render, audio, provider | LAB-008, LAB-021, LAB-052 |
| [LAB-044: Ledge Course](../experiments/LAB-044.md) | motion / M2 | CharacterBody3D; ShapeCast3D; RayCast3D | logic, render, provider | LAB-001, LAB-008, LAB-011 |
| [LAB-045: Platform Ferry](../experiments/LAB-045.md) | motion / M2 | AnimatableBody3D; CharacterBody3D; PhysicsServer3D | logic, render, provider | LAB-001, LAB-021 |
| [LAB-046: Aim Range](../experiments/LAB-046.md) | motion / M3 | RayCast3D; ShapeCast3D; PhysicsDirectSpaceState3D | logic, render, provider | LAB-052, LAB-053 |
| [LAB-047: Navigation Traffic](../experiments/LAB-047.md) | motion / M3 | NavigationAgent3D; NavigationServer3D | logic, render, profiling, provider | LAB-003, LAB-024 |
| [LAB-048: Joint Arcade](../experiments/LAB-048.md) | simulation / M2 | RigidBody2D; PinJoint2D; DampedSpringJoint2D; GrooveJoint2D | logic, render, provider | LAB-042 |
| [LAB-049: Constraint Foundry](../experiments/LAB-049.md) | simulation / M2 | RigidBody3D; HingeJoint3D; SliderJoint3D; Generic6DOFJoint3D | logic, render, provider | LAB-002 |
| [LAB-050: Field Chamber](../experiments/LAB-050.md) | simulation / M2 | Area2D; Area3D; RigidBody3D; PhysicsServer3D | logic, render, provider | LAB-002, LAB-052 |
| [LAB-051: Cloth Sail](../experiments/LAB-051.md) | simulation / M3 | SoftBody3D; MeshInstance3D | logic, render, profiling, provider | LAB-002, LAB-035 |
| [LAB-052: Collision Switchyard](../experiments/LAB-052.md) | simulation / M1 | CollisionObject2D; CollisionObject3D; Area3D | logic, render | LAB-001, LAB-002 |
| [LAB-053: Ballistics Tunnel](../experiments/LAB-053.md) | simulation / M3 | RigidBody3D; PhysicsDirectSpaceState3D; proposed SweepPolicy contract | logic, render, profiling, provider | LAB-002, LAB-052 |
| [LAB-054: Ragdoll Recovery](../experiments/LAB-054.md) | simulation / M3 | Skeleton3D; PhysicalBoneSimulator3D; AnimationTree | logic, render, profiling, provider | LAB-015, LAB-049, LAB-008 |
| [LAB-055: Grid Tactics](../experiments/LAB-055.md) | world / M2 | AStarGrid2D; Resource; proposed TurnCommand contract | logic, render, interchange | LAB-007, LAB-038 |
| [LAB-056: Voxel Quarry](../experiments/LAB-056.md) | world / M3 | ArrayMesh; SurfaceTool; StaticBody3D; proposed VoxelChunk contract | logic, render, profiling | LAB-016, LAB-028, LAB-029 |
| [LAB-057: Navmesh Workshop](../experiments/LAB-057.md) | world / M3 | NavigationMesh; NavigationRegion3D; NavigationServer3D | logic, render, editor, profiling | LAB-003, LAB-028 |
| [LAB-058: World Clock](../experiments/LAB-058.md) | world / M2 | AnimationPlayer; WorldEnvironment; proposed WorldClock contract | logic, render, provider | LAB-021, LAB-041 |
| [LAB-059: LOD Walk](../experiments/LAB-059.md) | performance / M3 | GeometryInstance3D; MeshInstance3D; MultiMeshInstance3D | logic, render, profiling, provider | LAB-017, LAB-036, LAB-011 |
| [LAB-060: Atlas Author](../experiments/LAB-060.md) | art / M2 | Image; ImageTexture; ArrayMesh; ShaderMaterial | logic, render, interchange | LAB-004, LAB-035 |
| [LAB-061: Vertex Shade](../experiments/LAB-061.md) | art / M2 | SurfaceTool; ArrayMesh; MeshDataTool | logic, render, interchange | LAB-004, LAB-035 |
| [LAB-062: Silhouette Studio](../experiments/LAB-062.md) | art / M2 | MeshInstance3D; Camera3D; SubViewport | logic, render, provider | LAB-011, LAB-035 |
| [LAB-063: Stepped Animation](../experiments/LAB-063.md) | art / M2 | AnimationPlayer; AnimationMixer; proposed PoseSampling contract | logic, render, provider | LAB-008, LAB-021 |
| [LAB-064: Shadow Cards](../experiments/LAB-064.md) | art / M2 | MeshInstance3D; StandardMaterial3D; Camera3D | logic, render, profiling, provider | LAB-010, LAB-060 |
| [LAB-065: Fog Theater](../experiments/LAB-065.md) | rendering / M3 | WorldEnvironment; Environment; FogVolume | render, profiling, provider | LAB-010, LAB-031 |
| [LAB-066: Viewport Mirrors](../experiments/LAB-066.md) | rendering / M3 | SubViewport; SubViewportContainer; ViewportTexture; Camera3D | logic, render, profiling | LAB-011, LAB-013 |
| [LAB-067: Decal Printing](../experiments/LAB-067.md) | rendering / M3 | Decal; MeshInstance3D; StandardMaterial3D | logic, render, profiling | LAB-031, LAB-060 |
| [LAB-068: Display Laboratory](../experiments/LAB-068.md) | rendering / M2 | SubViewport; ShaderMaterial; CanvasLayer | logic, render, provider | LAB-004, LAB-019, LAB-013 |
| [LAB-069: Compute Garden](../experiments/LAB-069.md) | rendering / M4 | RenderingDevice; RDShaderFile; RDComputePipeline; proposed ComputeKernel contract | logic, profiling, render | LAB-027, LAB-031, LAB-028 |
| [LAB-070: Tone Observatory](../experiments/LAB-070.md) | rendering / M3 | Environment; WorldEnvironment; Image | render, profiling, interchange | LAB-010, LAB-031, LAB-019 |
| [LAB-071: Mixer Desk](../experiments/LAB-071.md) | audio / M2 | AudioServer; AudioStreamPlayer; AudioEffectLimiter | logic, audio, provider | LAB-005, LAB-020 |
| [LAB-072: Music Conductor](../experiments/LAB-072.md) | audio / M3 | AudioStreamPlayer; AudioStreamInteractive; AudioStreamSynchronized | logic, audio, provider | LAB-071, LAB-021 |
| [LAB-073: Voice & Captions](../experiments/LAB-073.md) | audio / M3 | AudioStreamPlayer; RichTextLabel; proposed CaptionTrack contract | logic, audio, render, interchange | LAB-014, LAB-071 |
| [LAB-074: Statechart Playhouse](../experiments/LAB-074.md) | narrative / M2 | Resource; Signal; proposed Statechart contract | logic, render, interchange | LAB-038, LAB-041, LAB-021 |
| [LAB-075: Quest Weave](../experiments/LAB-075.md) | narrative / M2 | Resource; JSON; proposed ObjectiveGraph contract | logic, render, interchange | LAB-074, LAB-038, LAB-006 |
| [LAB-076: Cinematic Rails](../experiments/LAB-076.md) | narrative / M3 | AnimationPlayer; Path3D; PathFollow3D; Camera3D | logic, render, audio, provider | LAB-011, LAB-008, LAB-025 |
| [LAB-077: Inventory Alchemy](../experiments/LAB-077.md) | narrative / M2 | Resource; Dictionary; proposed InventoryTransaction contract | logic, render, interchange | LAB-018, LAB-038, LAB-006 |
| [LAB-078: Locale Pavilion](../experiments/LAB-078.md) | interfaces / M3 | TranslationServer; Translation; RichTextLabel | logic, render, interchange, export | LAB-013, LAB-006 |
| [LAB-079: Focus Labyrinth](../experiments/LAB-079.md) | interfaces / M3 | Control; SubViewportContainer; proposed AccessibilityProbe contract | logic, render, physical, export | LAB-013, LAB-066 |
| [LAB-080: Comfort Controls](../experiments/LAB-080.md) | interfaces / M2 | Control; InputMap; ShaderMaterial; proposed ComfortProfile contract | logic, render, interchange | LAB-012, LAB-013, LAB-006, LAB-068 |
| [LAB-081: Drag & Inspect](../experiments/LAB-081.md) | interfaces / M2 | Control; Resource; Tree | logic, render, interchange | LAB-013, LAB-018, LAB-038 |
| [LAB-082: Prediction Track](../experiments/LAB-082.md) | networking / M4 | MultiplayerAPI; ENetMultiplayerPeer; proposed SnapshotProtocol contract | logic, transport, render, profiling | LAB-024, LAB-025, LAB-001 |
| [LAB-083: Reconnect Harbor](../experiments/LAB-083.md) | networking / M4 | MultiplayerAPI; ENetMultiplayerPeer; proposed ResumeToken contract | logic, transport, interchange, render | LAB-024, LAB-082, LAB-006 |
| [LAB-084: Network Chaos](../experiments/LAB-084.md) | networking / M4 | PacketPeer; MultiplayerAPI; proposed ChaosProfile contract | logic, transport, profiling | LAB-024, LAB-082, LAB-083 |
| [LAB-085: RPC Gatehouse](../experiments/LAB-085.md) | networking / M4 | MultiplayerAPI; rpc annotations; proposed RPCEnvelope contract | logic, transport, interchange | LAB-024, LAB-038 |
| [LAB-086: WebRTC Bridge](../experiments/LAB-086.md) | networking / M5 | WebRTCPeerConnection; WebRTCDataChannel; WebRTCMultiplayerPeer | logic, transport, export | LAB-024, LAB-032, LAB-085 |
| [LAB-087: Live Control](../experiments/LAB-087.md) | automation / M3 | WebSocketPeer; Cappy released addon; proposed LiveCommandEnvelope contract | logic, transport, provider | LAB-038, LAB-025, LAB-040 |
| [LAB-088: Source-bound Capture](../experiments/LAB-088.md) | automation / M3 | Official @uppercut-labs/cappy package; OBS WebSocket; proposed CaptureSourceReceipt contract | logic, render, audio, provider | LAB-025, LAB-087, LAB-039 |
| [LAB-089: Parameter Sweeps](../experiments/LAB-089.md) | automation / M3 | WorkerThreadPool; FileAccess; Official Cappy package; proposed SweepPlan contract | logic, render, provider, profiling | LAB-028, LAB-088, LAB-036 |
| [LAB-090: Camera Takes](../experiments/LAB-090.md) | automation / M3 | Path3D; PathFollow3D; Camera3D; Official Cappy package | logic, render, provider | LAB-011, LAB-076, LAB-088 |
| [LAB-091: Golden Assertions](../experiments/LAB-091.md) | automation / M4 | Image; AudioStreamWAV; proposed EvidenceComparator contract | logic, render, audio, provider | LAB-088, LAB-073, LAB-019 |
| [LAB-092: Memory Observatory](../experiments/LAB-092.md) | performance / M3 | Performance; Object; ResourceLoader; proposed ResourceLedger contract | logic, profiling | LAB-029, LAB-017, LAB-040, LAB-036 |
| [LAB-093: Import Plugin](../experiments/LAB-093.md) | tooling / M3 | EditorImportPlugin; ResourceImporter; Resource | logic, editor, interchange | LAB-026, LAB-018, LAB-039 |
| [LAB-094: Export Profiles](../experiments/LAB-094.md) | tooling / M4 | EditorExportPlugin; EditorExportPreset; EditorExportPlatform | logic, export, interchange | LAB-026, LAB-088 |
| [LAB-095: Blender Round Trip](../experiments/LAB-095.md) | interchange / M3 | GLTFDocument; GLTFState; Skeleton3D; Blender glTF exporter probe | logic, render, editor, interchange | LAB-035, LAB-015, LAB-060, LAB-061 |
| [LAB-096: XR Hands](../experiments/LAB-096.md) | xr / M5 | XRHandTracker; XRHandModifier3D; XRServer; proposed HandPoseSource contract | logic, render, physical, export | LAB-034, LAB-015, LAB-012 |
