# DK Godot v0.2.10 - Sprite Player BodyRect Hotfix Addendum

## Sprite Player Transition Rule
When the player visual changes from the old rectangle body to a sprite or animated sprite, scripts must not require `BodyRect` as a mandatory child.

Old rectangle-only visual code may remain temporarily if guarded, but it must not block runtime startup when the sprite player is present.

## Movement Preservation Rule
If movement is confirmed working, do not rewrite the movement controller during visual hotfixes. Patch only the broken visual dependency unless a movement bug is separately reported.
