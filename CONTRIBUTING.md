# Contributing

A useful contribution teaches a capability through an action a player can perform. Begin with the payoff: what can someone try, what should change, and why does that reveal something useful about Godot?

1. Use [TEMPLATE](experiments/TEMPLATE.md) to specify the lab and [the extension contract](docs/EXTENSION_CONTRACT.md) to define its boundaries.
2. Give it a stable LAB ID, update the catalog, and add a ticket with dependencies and measurable acceptance.
3. Build the smallest real playable interaction, clear instructions, visible result, reset, and exit before decorating it.
4. Add original fixtures and a replay scenario that invokes the same operations as the live route. Test failure and repeated reset where relevant.
5. Verify the claims with the appropriate logic, rendered, audio, provider, and export evidence. Keep human/device testing explicitly pending when absent.
6. Update BUILD_STATUS with the actual command, build, machine, outcome, and limits. Review public paths, media rights, and metadata before committing.

Prefer focused patches and explicit file staging. Generated imports, recordings, save files, captures, export binaries, credentials, and machine-specific reports do not belong in source control. External assets need a provenance/license entry before adoption. A screenshot from a reference game is not an original fixture.
