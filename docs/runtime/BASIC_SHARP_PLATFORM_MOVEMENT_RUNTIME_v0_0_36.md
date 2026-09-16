# BASIC# Platform Movement Runtime v0.0.36

`BasicSharp::GameInput` accepts Profile 4 source/BSIR documents and validated Profile 4 BSBC models through the same engine-neutral boundary.

## Host events

- `key_down` and `key_up` carry `key`.
- `frame` carries whole-number, nondecreasing `time_ms`.
- A frame may carry Boolean `grounded`, `hit_left`, `hit_right`, and `hit_ceiling`; omitted collision facts mean `false`.

Invalid time or non-Boolean collision facts stop with a plain `GameInputError`. The first frame has `delta_seconds = 0`. Later elapsed time is capped at `0.25` seconds.

## Host command

Every valid platform frame emits one `move_with_collisions` command:

```json
{
  "command": "move_with_collisions",
  "subject": "player",
  "velocity_x": 6.0,
  "velocity_y": -9.52,
  "delta_seconds": 0.016,
  "gravity": 30.0,
  "grounded": true
}
```

Positive X is right; negative Y is up. The host applies the supplied velocity through its collision-moving primitive and reports collision facts on frames. No Godot, Unity, or other engine type crosses this contract.

The runtime fixture is `spec/runtime_v4/BASIC_SHARP_PLATFORM_MOVEMENT_RUNTIME_FIXTURES_v1.json`.
