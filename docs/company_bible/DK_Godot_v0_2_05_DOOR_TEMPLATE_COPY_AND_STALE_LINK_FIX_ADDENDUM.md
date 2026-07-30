# v0.2.05 DOOR TEMPLATE COPY AND STALE LINK FIX - Company Bible Addendum

## Locked Rules

- New placed doors must be created from `DoorTemplate*` sources through the DK tool path.
- The original four template nodes remain templates only.
- Any copied template converted into a placed door must become the next higher global `Door#`.
- The converted door must be placed directly under the target `Cell*`, not under the original template and not under another door.
- Placed doors should not keep `dk_placeable_door_template=true`.
- Stale manual door links that point to copied `@Node2D@...` paths may be repaired by editor guard logic when a reciprocal linked door exists.
- Re-linking cells that are already linked should produce a confirmation instead of rewriting the same connection.

## Main Scene Safety

This patch does not overwrite `scenes/Main.tscn`. The stale-link repair is handled by code so Derek's current scene edits are preserved. If Godot marks the scene unsaved after repair, save the scene so the cleaned link path is written permanently.
