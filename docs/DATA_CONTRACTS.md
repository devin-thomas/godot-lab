# Shared data contracts

These are proposed expansion types. The bootstrap has a schema-1 progress save and bounded scenario reports; it does not implement this entire model. Wire schemas will be versioned/probed during CORE-003/CORE-008.

| Contract | Required information | Invariant |
|---|---|---|
| LabDescriptor | Stable ID/version, wing, source/component, profiles, operations, scenarios | Specifications do not automatically register playable rooms |
| CapabilityProbe | Engine/build, renderer, OS, assets/provider/extension/device, path/reason | Fallback and unavailable adapter remain distinct |
| FixtureManifest | ID/version, source/license, hash, seed, limits, namespace | No private dependencies in public first run |
| OperationRequest | Schema, session, lab, request ID, name, typed args, expected revision | No arbitrary evaluation or dictionary mutation |
| OperationReceipt | Request ID, accepted/rejected/completed, reason, revisions, tick, events | Retry cannot apply a durable effect twice |
| LabObservation | Semantic entities, bounded state, revision, readiness, jobs | Presentation cannot fabricate simulation outcomes |
| SimulationRecord | Build/fixtures, seed, tick rate, ordered commands/events, checkpoints, tolerances | Incompatible versions are not silently reinterpreted |
| PresentationTrack | Camera/effect/audio cues, simulation anchors, output rate/look | Viewer framing leaves simulation history intact |
| ExperimentDocument | IDs, schema, parameters, resources, attachment hashes | Stage, validate, round-trip, atomically publish |
| LabJob | Source/request identity, phase, progress, owner, budget, checkpoint, output | Terminal result immutable; ownerless job marked interrupted |
| EvidenceManifest | Source, tools, host/profile, operation route, artifacts/results/limits | Another commit's report cannot qualify this build |
| JourneyCheckpoint | Schema, handoff document, receipts, progress namespace | Reset/retry cannot consume another route's progress |

## IDs, revisions and retry

Use semantic IDs rather than incidental node paths. Reject unknown operations and invalid arguments before mutation. A request ID names one logical request in a session/namespace; identical retries return the earlier receipt, conflicting reuse fails. State-sensitive durable mutations compare expected revision. Streaming samples may be replaceable; durable commands may not disappear silently.

Commands record the tick where they apply. Accepted means queued, not completed. Event cursors report gaps and retention limits. Cancellation records request and outcome; completed publication cannot retrospectively become cancelled.

## Fixtures and imports

Imports enter a lab-owned staging directory and receive format/version, byte/count, attachment, path and resource checks before activation. Reject traversal, executable/native payloads, malformed resources and oversized expansions. Preserve a good document when validation fails. Arbitrary native code loading is outside the public import contract.

Necessary original fixture sources may be committed. Generated meshes, renders, captures, binaries and scratch remain ignored. Manifests identify authoring recipes and hashes. Workers cannot assume another checkout's private paths.

## Recovery and separation

Progress/settings, scenario state, records, staging, scratch and encoded output use separate namespaces. Reset names owned files. Migrations stage/validate, preserve recovery, then publish atomically. Unknown newer schemas are visible errors, not destructive defaults.

Jobs enforce admission and runtime limits. Checkpoints bind source/fixture/recipe identity. Resume refuses incompatible inputs. Cancellation/capacity failures preserve prior good output; partial files cannot receive success manifests. Relaunch marks ownerless jobs interrupted.

## Evidence identity

A manifest binds source commit or explicit dirty-tree hash, optional private pack commit, installed tools/providers, host/OS/renderer/profile, scenario/version, fixture hashes, seed, actual operation route/timing, assertions/tolerances, errors, media metrics and artifact hashes. Sensitive routing/auth stays outside publishable manifests. Evidence does not automatically promote a lab's implementation state.
