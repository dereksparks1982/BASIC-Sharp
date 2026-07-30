# DK Godot v0.3.47 Demon Killer Visual Style and Compact Panel Addendum

**Date:** 2026-07-10  
**Status:** Mandatory  
**Scope:** All Demon Killer concept-art work and DK Live Builder bottom-panel layout

## Concept-art authority

All new Demon Killer concept art must use the **Demon Killer Iron-and-Ember visual style** defined in the active Company Bible and expanded in:

```text
res://docs/art_direction/DK_DEMON_KILLER_VISUAL_STYLE_GUIDE_v0_3_47.md
```

Saying only “make it DK style” is insufficient. An art brief must state the material language, palette, lighting, tone, proportions, and exclusions that make the style recognizable.

## DK Live Builder bottom-panel rule

DK Live Builder must never force the Godot bottom dock to remain excessively tall or prevent the owner from reaching DK Door or another bottom-panel tool. Large content must scroll inside the panel. The panel root must be allowed to collapse normally, and report panes must use modest minimum heights rather than dictating the editor layout.

## v0.3.47 application

This build removes the 390-pixel root minimum and 220-pixel report-pane minimums, moves the working controls into a scrollable content body, and establishes the first complete Demon Killer visual-style definition.
