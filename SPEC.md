# Product specification

Baseline: 2026-10-01. The authoritative implementation/evidence snapshot is [BUILD_STATUS](docs/BUILD_STATUS.md).

## Purpose and audience

Build a playable executable that teaches Godot capabilities through physical interactions and repeatable automation. Curious players should understand the effect without reading code. Developers should find the mechanism, source, test, and reusable boundary. Automation builders should discover how a real interaction becomes a recordable scenario.

## Product shape

An original third-person retro 3D hub connects six labs. A station introduces one concrete payoff, shows the important controls, and exposes the observed state. The player can reset a lab or leave it at any point. Information panels explain both the Godot mechanism and what automation can measure.

| ID | Requirement | Acceptance anchor |
|---|---|---|
| R-01 | A clean public checkout is independently runnable | No account, private dependency, or recording service in play path |
| R-02 | The executable supports ordinary interactive play | Player can reach, operate, reset, and leave all six labs |
| R-03 | Lab behavior and automation share real operations | Scenario changes the same nodes/state as the live route |
| R-04 | Each effect has a readable explanation | Player sees the capability, action, response, and reset |
| R-05 | State is resettable and isolated | Repeated run begins from documented baseline |
| R-06 | Evidence supports a bounded claim | Build, engine, renderer, scenario, result, and limits recorded |
| R-07 | Retro art is authored and usable | Clear silhouettes, quiet floor, strong station colors, readable text |
| R-08 | Capture is optional tooling | Official Cappy package integration cannot break offline play |
| R-09 | Persistence is local and explicit | Save survives restart; malformed data is handled visibly; reset stays scoped |
| R-10 | New labs have a stable extension contract | Catalog, implementation, instructions, scenario, and tests added together |
| R-11 | Export is verified separately from source launch | Executable opens and completes automated smoke route |
| R-12 | Human testing is not fabricated | Human/controller/physical-device gates stay pending until performed |

## First release

| Lab | Physical payoff | Mechanism | Automated acceptance |
|---|---|---|---|
| LAB-001 Motion atelier | Move/jump around solid stairs and an obstacle | CharacterBody3D, collisions, input, camera | Floor contact, blocked wall, jump movement, reset |
| LAB-002 Gravity foundry | Launch a body and watch a resettable arrangement react | RigidBody3D, impulse, contacts | Body displacement, collision/settling, reset baseline |
| LAB-003 Pathfinder garden | Dispatch a courier around a tower to a fixed gold pad | NavigationAgent3D, authored navigation mesh | Non-straight path and arrival within tolerance |
| LAB-004 Paint & light | Compare authored, lit, and pixel treatments | Shader/material parameters, sampling, viewport | Parameter route plus real rendered image comparison |
| LAB-005 Signal chamber | Move around a visible sound source | AudioStreamPlayer3D, attenuation, listener position | Source placement/state plus recorded audible energy/panning checks |
| LAB-006 Memory archive | Save earned lab seals and comfort settings; reload from disk | Local file format, validation, versioning | Round trip, restart, invalid input preserved |

The catalog also specifies advanced directions. A documented future capability is never represented as available in the hub. A first implementation may be compact; it must still provide the mechanism and interaction it names.

## Milestones

M1 establishes the hub, the six labs, automated checks, capture integration, and a tested local executable. M2 develops richer input/settings, animation, tile/world systems, and profiler-driven art iteration. M3 adds networking, tooling extensions, large-world investigations, and alternative renderer studies. M4 holds hardware-dependent XR, mobile sensor experiments, and external service integrations.

The current user is unavailable for manual testing. Complete all feasible automated work now; retain human comfort, real controller, and physical-device gates for later. Do not use that absence to replace the playable product with a video.

## States and completion

Use `specified`, `spiked`, `implemented`, `automated-verified`, `human-verified`, `release-ready`, or `blocked`. Record evidence separately for logic, rendered output, audio, capture provider, exported executable, and physical devices. Status is attached to a build and supported route, not assumed forever.

A lab is automated-verified when its ordinary play route exists, reset works, meaningful assertions pass, and the required rendered/audio checks pass on the named host. A release additionally needs an exported executable check, reproducible build instructions, license inventory, public-content review, and honest missing-gate disclosure. A lab may be automated-verified while controller comfort remains untested.

## Non-goals

The first release is not an engine replacement, a commercial full-length game, an exhaustive implementation of every Godot API, a benchmark suite, or a promise of every export platform. It does not ship copied game art or require cloud services. Multiplayer, mobile/XR, GDExtension, editor plugins, and production telemetry are future experiments until implemented and checked.
