# BASIC# Changelog v0.0.17

## Added

- Reactive false-to-true IF wake-up behavior.
- IF re-arming after a condition becomes false.
- START and event-time IF settling.
- Deterministic IF cascades in source order.
- Plain IF trace entries with reason, actions, and world changes.
- Repeating-state and scaled firing loop protection.
- Focused IF behavior test suite.
- 128-rule IF stress runner.
- v0.0.16 saved-BSharp IR fixture.

## Changed

- The runtime now settles IF after START and after a complete matched WHEN action list.
- Sample `first_room.bsharp` now demonstrates a reactive IF after Cinder becomes angry.
- Active version surfaces now report v0.0.17.

## Preserved

- Existing IF syntax.
- Exact and inherited WHEN matching.
- Source order.
- Source/saved-BSharp IR parity.
- v0.0.13, v0.0.15, and v0.0.16 valid saved-BSharp IR compatibility.
