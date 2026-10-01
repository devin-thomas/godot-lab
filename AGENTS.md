# Builder instructions

Read SPEC.md, docs/BUILD_STATUS.md, docs/EXTENSION_CONTRACT.md, and the ticket for the work before editing. Inspect Git state and preserve unrelated work. Use the existing main branch unless an isolated branch is requested or required for review. Commit explicit project paths; never stage generated output or credentials.

The expanded program has 96 contracts in planning/catalog.json; six have bounded bootstrap evidence and expansion remains specified. Read docs/ROADMAP.md, docs/DATA_CONTRACTS.md and docs/CAPABILITY_PROFILES.md. Preserve IDs 001..036 and historical evidence. Lab A tickets implement/deepen; B tickets qualify. Documentation cannot promote runtime status. After catalog edits run `python scripts/plan.py --write`, then `python scripts/plan.py --check --self-test` and inspect generated changes. Keep optional native/provider/device targets outside default startup.

## Product rules

- The deliverable is a playable executable with ordinary input. Never replace interaction with a cutscene or scenario-only implementation.
- Use the same state-changing operation for a player's action and its scenario. Test adapters may drive input or operations; they must not manufacture a passing state.
- Every implemented lab has clear instructions, visible feedback, reset, return-to-hub, bounded resource use, and an automated acceptance scenario.
- Keep the public core independent: no accounts, private dependencies, capture software, secrets, or cloud services required to play.
- Separate implementation state from verification evidence. A headless test cannot prove rendered appearance, audible output, comfortable controls, or hardware support.
- Keep recordings, exports, caches, and machine-specific reports ignored. Publish curated summaries or selected original media only after checking rights and metadata.
- Verify actual Godot APIs against the installed engine and official documentation. A capability in the catalog is not an implementation promise.

## Changes and verification

Search for existing helpers before adding new abstractions. Prefer typed GDScript, explicit failures, narrow responsibilities, and reusable scene boundaries. Tests must measure outcomes beyond mirroring implementation. Use a tolerance for simulation checks rather than promising portable bit-identical physics.

Update the experiment page, ticket, BUILD_STATUS, and command documentation when changing a lab's contract. The status page must name the build, machine, command, outcome, and missing gates. Finish scoped automated checks before publishing. Preserve a failed evidence artifact as a failure; do not label an unavailable OBS connection as a successful recording.

## Art rules

Follow docs/ART_DIRECTION.md. Use original assets, deliberate nearest-sampled pixel surfaces, readable low-poly silhouettes, consistent UI feedback, and a clean default presentation. Keep gameplay controls responsive. Modern effects need a teaching purpose. Flash, shake, wobble, and CRT effects must be optional and comfort-aware when introduced.
