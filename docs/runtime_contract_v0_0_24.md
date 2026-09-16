# BASIC# Runtime Contract v0.0.24

v0.0.24 changes no accepted runtime behavior. It makes that behavior testable under `bsharp.meaning.v1`.

Stable runtime order includes:

```text
START facts
startup IF settlement
startup follow-up settlement
external event action body
IF settlement
first-created follow-up events
ASK inspection after settlement
optional save after successful inspection
```

Event priority remains exact named Thing, nearest inherited Kind, then source order for equal distance.

`every Kind` remains definition ordered. `that Kind` remains singular event context. IF rules remain false-to-true reactive and rearm after false. Follow-up events remain explicit and limited to 1,024 per external chain.

The runtime's Ruby classes, collections, caches, and helper methods are not stable interfaces. Final normalized observations in the Profile 1 fixtures are stable meaning.
