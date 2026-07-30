# Company Bible Addendum - v0.2.07 Cell/Door Draw Order Fix

Version: v0.2.07
Package: DK_Godot_v0_2_07_CELL_DOOR_DRAW_ORDER_FIX_CHANGED_FILES.zip

## Rule

Cells and doors must have a stable draw order by default.

- Cell roots stay on the common base draw level.
- Door roots and door templates draw one layer above the cell.
- Doors must remain visible when moved onto NES/edge-test cells or created from templates.
- Draw-order fixes should be handled by scripts/tools whenever possible instead of manually editing Derek's active map scene.

## Version habit

This patch advances the visible project identity to v0.2.07. Every numbered patch/build must continue updating the version that appears when the project opens.

## Checksum rule

No external SHA/checksum file is included unless Derek asks for one.
