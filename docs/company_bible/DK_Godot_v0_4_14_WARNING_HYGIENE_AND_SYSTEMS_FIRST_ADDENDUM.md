# DK Godot v0.4.14 Warning Hygiene and Systems-First Addendum

**Date:** 2026-07-12  
**Status:** Mandatory  
**Scope:** All DK / Demon Killer Godot builds, patches, repairs, and validation packages

## Systems first

Derek reaffirmed the project direction: build the systems first and worry about final graphics later. A working mechanic with rough placeholder visuals is preferred over a polished scene that does not actually function.

Examples:

```text
Fishing may look ugly during foundation work, but the player must actually be able to fish.
A resource task may use placeholder shapes, but collection, inventory, save, and reload must work.
A puzzle may look rough, but its state machine, bypass, persistence, and validation must exist before art polish.
```

This rule supports the foundation strategy already used by the save system, region state, object mutation state, ghost/resurrection loop, Continue path, and DK Test Pilot contracts.

## Warning Goblin intake

Derek reported two Godot/GDScript warnings after v0.4.13. They are now documented as repair targets before the next feature build:

```text
W 0:00:03:702 GDScript::reload: The parameter "kind" is never used in the function "_frame_index_for_action_phase()".
<GDScript Error> UNUSED_PARAMETER
<GDScript Source> DKDirectionalPlayerVisual.gd:347 @ GDScript::reload()

W 0:00:00:560 GDScript::reload: The constant "DKSaveContinueReadinessContract" has the same name as a global class defined in "DKSaveContinueReadinessContract.gd".
<GDScript Error> SHADOWED_GLOBAL_IDENTIFIER
<GDScript Source> DKSaveManager.gd:4 @ GDScript::reload()
```

## Mandatory handling

- Reported warnings are Goblins, not decoration.
- Fix safe warning Goblins before stacking new feature work on top.
- If a warning must remain temporarily, document why and add a follow-up item.
- Do not ignore warnings merely because DK Live Builder and DK Test Pilot still pass.

## v0.4.14 repair decision

- Rename the unused `kind` parameter to `_kind` in `DKDirectionalPlayerVisual._frame_index_for_action_phase()`.
- Rename the `DKSaveManager` preload constant so it no longer shadows the global `DKSaveContinueReadinessContract` class.
- Add DK Live Builder static token checks so the same warning forms cannot quietly return.
- Keep the next larger save-slot user-flow build separate.
