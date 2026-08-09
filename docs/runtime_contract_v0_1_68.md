# BASIC# Runtime Contract v0.1.68

v0.1.68 adds `input_action` as an engine-neutral host command emitted by `BasicSharp::GameInput` when a resolved `CONTROLS for PLAYER` declaration includes plain-English input action meanings.

The command shape is:

```json
{
  "command": "input_action",
  "subject": "player",
  "action": "jump",
  "source": "keyboard:SPACE"
}
```

Allowed actions in this build are `jump`, `attack`, `interact`, and `pause`.
