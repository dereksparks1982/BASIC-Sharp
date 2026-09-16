# BSIR OTHERWISE Branches Contract v0.0.39

An IF rule in `bsharp.meaning.v7` retains its ordered condition or condition group and required `actions` array. It may additionally carry `otherwise`, an ordered action array, plus the OTHERWISE source line.

The resolver emits Profile 7 whenever any IF owns an OTHERWISE body. Both action lists are completely resolved and validated before execution. An omitted OTHERWISE field preserves the accepted one-sided rule. Empty, misplaced, repeated, or chained OTHERWISE structures are rejected before BSIR emission.
