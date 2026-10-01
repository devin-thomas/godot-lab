# Automated testing and evidence

The user is unavailable for physical or human testing during this delivery. Automated verification is therefore a release-work requirement, while human/device gates remain explicitly deferred.

## Evidence ladder

| Evidence | What it can establish | What it cannot establish |
|---|---|---|
| Parse/import | Scripts/resources load under named engine | Playability or correct outcomes |
| Headless simulation | Real node/state outcomes, reset, bounded scenarios | Shader appearance or audible sound |
| Windowed replay | Rendered route boots and visible actions occur | Human comfort or physical controller behavior |
| Encoded movie/audio | Frames, temporal progression, audio channel energy/timing | Real display/speaker output |
| Cappy/OBS capture | Named provider connected and produced inspected recording | Behavior on another user's setup |
| Export smoke | Actual exported executable launches and runs scenario | Signed distribution or untested platforms |
| Human/device session | Named person/device/input experience | Automatic universal support |

Every report identifies commit/build, engine version, OS/renderer, command, scenario ID/version, fixture/seed, assertions, artifact paths, outcome, and limits. Raw artifacts remain local and ignored. Curated public summaries remove absolute machine paths, usernames, credentials, unrelated windows, and recording metadata.

## First-release checks

Collision checks should detect floor contact, wall blocking, jump movement, and reset. Physics checks should detect an impulse's meaningful displacement and settling/contact behavior. Navigation checks should verify arrival through the allowed region around an obstacle. Materials need rendered comparison, not only a parameter assertion. Audio needs encoded non-silent output and channel/position analysis where panning is claimed. Persistence needs save/load, process restart, invalid/truncated data, and scoped reset checks.

Run the integrated route through entry, action, reset, exit, and re-entry for every lab. Check that instructions and visible metrics match the actual result. Bound every scenario by time/frames so a broken target cannot hang the suite. Simulations use appropriate tolerances rather than claims of portable bit-identical physics.

## Analysis tools

Use FFmpeg/ffprobe for dimensions, duration, frame extraction, black-frame detection, freezes, and audio channels/energy. Listen or inspect spectrograms where channel statistics leave ambiguity. Transcription is useful only for spoken material; the baseline synthetic lab tones do not need transcription. State reports remain the primary truth for semantic outcomes, and screenshots/captures support visual assertions.

## Deferred gates

Human comfort, full controller hardware behavior, platform-specific input glyphs, speakers/headphones, mobile/XR hardware, physical-device performance, and unsupported export platforms remain deferred until they have evidence. An automated pass must name exactly the host and route it tested.
