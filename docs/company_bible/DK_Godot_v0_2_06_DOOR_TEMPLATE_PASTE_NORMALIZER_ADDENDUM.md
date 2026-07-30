# DK Godot v0.2.06 Door Template Paste Normalizer Addendum

## Company Bible Addition

When a raw Godot paste places a copied `DoorTemplate*` under the original template, the DK editor guard must normalize it automatically.

The copy must become a sibling template copy named by side and number, for example:

```text
DoorTemplateNorth1
DoorTemplateNorth2
DoorTemplateSouth1
DoorTemplateEast1
DoorTemplateWest1
```

The original palette templates stay unnumbered. Template copies must not stay nested inside the original template.

## Main Safety

`scenes/Main.tscn` was not changed in this patch. No Main backup was required.
