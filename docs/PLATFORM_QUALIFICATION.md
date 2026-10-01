# Platform qualification plan

Current automated proof is an unsigned Windows export and Windows source launch. Other rows are planned gates.

| Route | Automatic work | Deferred physical/human gate |
|---|---|---|
| Windows | Import, headless/rendered, executable, source-bound Cappy video/audio | Controllers, displays and comfort |
| macOS | Import, renderer probes, export, permission/capture paths | Devices and distribution signing/notarization when needed |
| Linux | Import/export, process/audio/provider and renderer | Real display/input |
| Web | Browser export, focus/input/resize, storage/bridge errors and actual media | Device browser/touch/display behavior |
| Android/iOS | Installed SDK build/export, simulator/emulator lifecycle/input/readiness | Sensors, touch, thermals, battery and capture |
| XR | Installed plugin/runtime, spatial fixture and available simulator | Headset/controllers/hands, tracking, comfort/performance |
| Native | ABI/toolchain matrix and extraction host | Untested architectures unqualified |

Source launch does not qualify export; browser emulation does not qualify a phone; desktop stereo does not qualify XR. Hardware absence cannot hold back default-game automation or meaningful fallbacks.

Workers probe CPU/RAM, renderer/provider and scratch capacity before admission. Resource-heavy work uses available provisioned workers. Exact machines, disks, credentials and private scheduling belong in the internal repository.
