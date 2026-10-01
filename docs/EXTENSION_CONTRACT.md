# Lab extension contract

A new lab is complete only when it exists as an interaction, documentation, and inspectable automated scenario. This is a behavior contract; use the runtime's actual entry points rather than inventing a plugin API.

## Required package

| Item | Contract |
|---|---|
| Stable ID | A unique `LAB-NNN` ID and a stable slug; never reuse retired IDs |
| Catalog metadata | Title, payoff, mechanism, implementation state, platform/renderer gates |
| Entry | Establish a known initial state and readable control instructions |
| Interaction | At least one player action changes a real engine mechanism |
| Observation | Explain the visible result; expose useful numeric/semantic state where appropriate |
| Reset | Restore the lab baseline without resetting unrelated progress |
| Exit | Cancel work and release nodes/resources; return to usable hub controls |
| Scenario | Bounded actions, stable fixtures, tolerance-based outcomes, versioned scenario ID |
| Evidence | Checks appropriate to the claim and clear missing gates |
| Sources/assets | Official Godot API references and original/licensed fixture provenance |

Keep input routing thin. Reuse one operation implementation for keyboard, focused UI, controller actions, and automated driving. For path-following, test the real agent and navigation world. For audio, inspect rendered channels as well as player state. For persistence, restart a process with the same isolated test storage rather than checking only an in-memory cache.

Every lab must remain usable after repeated entry/reset/exit cycles. A missing optional provider should produce a clear unavailable result in developer tooling and must not disable ordinary play. A blocked future capability may have a specification in the catalog; it must not appear as an implemented portal.

## Review questions

- Can a new player find the action and interpret its effect without source code?
- Does the automated route exercise the same mechanism as the player route?
- What would fail if the mechanism were replaced by a hard-coded final state?
- What claim remains unproven by this evidence?
- Can the lab reset and exit safely during its longest operation?
- Can another developer reuse the important mechanism without importing the whole museum?
