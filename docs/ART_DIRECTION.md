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
