# BASIC# Parser Contract v0.0.36

The canonical Heads and Body grammar remain unchanged. Profile 4 adds three exact `CONTROLS for PLAYER` instruction shapes:

```text
KEY moves PLAYER left at WHOLE_NUMBER speed
KEY moves PLAYER right at WHOLE_NUMBER speed
KEY makes PLAYER jump at WHOLE_NUMBER speed
```

`KEY` is one uppercase word beginning with A through Z. The resolver requires positive whole-number speeds, distinct keys, one left job, one right job, one jump job, and no mixture with top-down movement.

All Profile 1 through Profile 3 grammar remains accepted unchanged.
