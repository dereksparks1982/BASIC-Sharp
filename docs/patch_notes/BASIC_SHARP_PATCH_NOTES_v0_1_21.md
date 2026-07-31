# BASIC# Patch Notes v0.1.21

BASIC# can now deliberately make another event happen with `(cause`.

```text
<then> (cause that guard attacks player
```

The current body finishes first. Reactive IF rules then settle. Follow-up events run afterward in first-created, first-run order. Nested events join the end of the line.

No damage, state change, carry, or unlock action secretly creates an event. The creator must say `(cause`.

A self-feeding event chain stops after 1,024 follow-up events. Failed bodies discard staged events, unmatched events allow later events to continue, and runtime errors stop the remaining line.
