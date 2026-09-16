# BASIC# Runtime Contract v0.0.46

v0.0.46 changes input-device handling below the creator source layer. Stable Meaning Profiles 1 through 7 and BSharp Bytecode Profiles 1 through 7 remain the accepted language/runtime surface.

`BasicSharp::GameInput` now accepts:

- `key_down` / `key_up` for `WASD`, arrows, and space;
- `button_down` / `button_up` for PS5, Xbox, and generic gamepad directional and jump buttons;
- `axis` for left-stick horizontal and vertical movement;
- existing mouse pointer and right-mouse events.

These device events normalize to the existing host commands: `move`, `move_toward_pointer`, `move_with_collisions`, `face_pointer`, and `open_context`.

This build adds no new BASIC# source syntax, no new meaning profile, no bytecode profile, no engine bridge, no driver layer, no remapping UI, no graphics, and no Ruby replacement.
