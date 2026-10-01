# Art direction: the kinetic observatory

An original coastal-machine observatory houses working engine experiments. Its personality comes from angular architecture, pixel-painted surface motifs, brass machinery, luminous sea-glass panels, and oversized experiment silhouettes. The space should feel like a place worth exploring even before a player reads the explanation.

## Visual rules

| Element | Rule |
|---|---|
| Shape | Large planar masses, deliberate chamfers, stepped silhouettes; spend geometry on profile and motion |
| Surfaces | Pixel-authored patterns with nearest sampling; start with compact motifs/atlases and quiet repeated floors |
| Shade | Broad authored gradients and vertex/face color establish form before live lights are added |
| Palette | Deep marine structural shade, teal stone, warm ivory, ochre brass, coral interaction accents |
| Depth | Restrained fog and clear foreground/background values; never hide a collision edge in atmosphere |
| Effects | Large brief shapes with readable timing; optional CRT, wobble, flashing, and shake |
| Camera | Stable third-person view, clear player-ground relationship, predictable motion |
| UI | Crisp readable panels, one strong focus treatment, short instructions, clear result and reset |

These are original production rules. No triangle count, texture size, palette count, or animation cadence here is asserted as a measured rule of a reference game.

## Texture-first production

1. Establish the gameplay camera and player height on screen.
2. Paint a compact motif sheet: broad wall surface, quiet floor, trim, panel, accent, and padded solid-color swatches.
3. Test motifs on a tall wall and doorway before producing a full modular kit.
4. Model silhouettes and intentional shade boundaries. Paint details that need no parallax.
5. Add authored face/vertex shade, contact gradients, and restrained fog.
6. Inspect moving captures at gameplay distance. Remove texture noise that competes with the action.

The first foundation may use procedural original textures and deliberately simple meshes. Record that limitation rather than presenting primitives as finished character production. The next art pass should increase silhouette identity and atlas craftsmanship before adding generic post-processing.

## Reference synthesis

The creator's [ABYSS X ZERO environment walkthrough](https://www.youtube.com/watch?v=T8Uh1rAOk60) motivates texture-first modular production and authored broad shade. We use those principles to build a new observatory, with original compositions and surfaces. Filters remain optional presentation experiments.

The supplied retro-game research motivates predictable menu focus, a coherent set of feedback sounds, restrained palettes, expressive poses, and clear input prompts. Its community-code observations and unverified items are leads, not release facts. The official [Celeste 64 source](https://github.com/EXOK/Celeste64) is a useful open example to inspect for compact 3D menu/control behavior. [Minecraft's texture interview](https://www.minecraft.net/en-us/article/try-new-minecraft-textures) reinforces consistent rules and crisp low-resolution texture decisions.

## Comfort and legibility

Retro appearance must not require small unreadable text, unstable controls, or compulsory flashing. Essential state uses labels/shapes as well as color. Optional effects need a clean disable path. New controller glyphs must follow actual input support and tested mappings. Do not promise complete rebinding, screen-reader access, or hardware glyph qualification until implemented and verified.

## Expanded identity: a rose-tinted observatory

Keep deliberate pixel density, angular silhouettes, broad hue-shifted shade, expressive key poses and economical modular surfaces. Drop involuntary flicker, unreadable text, mandatory low frame rates, imprecise controls and repeated menu delays. Stepped character presentation is an adjustable experiment; simulation/input stay responsive. The clean default has no compulsory CRT, geometry wobble or flashing.

Make the observatory stranger and more authored: oversized brass courier creatures, ceramic masks, articulated tide machinery, folding paper gardens, harbor lanterns, crooked towers and instruments with recognizable silhouettes. Wings share a material language while each has a distinct dominant shape, accent and sound. Decorative motion belongs to a system the player can operate or inspect, not background noise over the lesson.

The supplied retro research informs these project choices: predictable focus/back behavior, an intentional fixed set of UI sound hooks, last-input prompts, readable ground/depth cues, quiet floors, palette discipline, expressive action poses, original atlas surfaces and opt-in effects. Its community-code observations, exact timings and unverified game claims are research leads, not measured facts of this project. Private source copies and another project's staffing rules are not imported into this public asset pipeline.

## Original authoring pipeline and comparison labs

| Stage | Source and deliverable | Automatic qualification |
|---|---|---|
| Silhouette lineup | Original orthographic shapes, scale/unit markers and gameplay-distance camera | Project triangle/material budget, bounds and readability fixture |
| Atlas/vertex shade | Original source palette, padded atlas islands, quiet repeated surfaces, broad gradients | Dimensions/color budget, UV density/seams, nearest-sampling policy and vertex-color import |
| Rig/action grid | Named bones, original rest pose, windup/contact/recovery, locomotion and optional look/feet layers | Bone/clip markers, root-motion policy, event order and blend transitions |
| Scene/effects | Modular kit, particles, contact shapes, lights/fog and comparison preset | Unsupported renderer route, temporal frames and effect cleanup |
| Interchange | Bounded scripted Blender recipe -> glTF/GLB -> Godot scene/component | Unit/axis/UV/color/rig/clip round trips with content/recipe hashes |
| Production take | Playable scene plus independent viewer camera and look profile | Source-bound Cappy capture, decoded media and event alignment |

LAB-060..064 investigate atlas authoring, vertex shade, silhouettes, stepped animation and shadow cards; LAB-035/LAB-095 own import/round-trip boundaries. LAB-008/LAB-015/LAB-043 combine animation, skeleton and combat. LAB-090 compares viewer takes. These are specified future work; the current art remains the simple original procedural foundation.

Starting project targets, to tune through real profiling: small motifs at 32/64/128 pixels, larger shared atlases at 256/512 where justified, a consistent measured texel density per kit, a small named ramp per material, and geometry spent first on profile and articulated motion. These are authoring defaults, not claims about a reference game or hard limits on every lab. Exceptions must teach a comparison and appear in the asset manifest.

Add an art lint report for project texture/palette/density budgets, material counts, missing licenses, rig markers and imported attribute drift. Capture the asset in motion at actual gameplay distance; atlas compliance alone cannot prove it looks good. Compare an original clean preset with the optional era treatments using the same camera, fixture and event timing.

## Interface personality and control evidence

Use an original observatory lettering/display treatment, readable body text, shaped keycaps and a consistent focus/confirm/back/invalid/slider/toggle sound vocabulary. Controls explain their consequences before activation. Filters should aid browsing without becoming a compulsory menu maze. Focus moves predictably, disabled entries explain why, cancel returns one level, and entering/exiting a room cannot carry a stale input press into the next context.

Input glyph families, confirm/cancel mapping, rebinding conflicts, pause buffering, text scale and separate shake/flash controls belong to LAB-012/LAB-078..080. Synthetic events prove dispatch; real devices and comfort retain their later gates. No automated pixel statistic claims a human's aesthetic approval.
