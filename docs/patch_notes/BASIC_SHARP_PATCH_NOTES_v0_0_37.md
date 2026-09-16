# BASIC# v0.0.37 Patch Notes

Creators can now count score, spend ammunition, reduce health, and react to thresholds using plain language:

```bsharp
|then (increase score of PLAYER by 10
|then (decrease ammo of @bow by 1
IF PLAYER has at least 100 score
```

BASIC# keeps changes atomic and refuses overflow, underflow, missing values, and text/number mistakes before anything changes.

This build does not add decimals, equations, timers, collections, loops, random numbers, or an engine bridge.
