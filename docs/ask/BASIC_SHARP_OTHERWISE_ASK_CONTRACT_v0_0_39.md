# BASIC# OTHERWISE ASK Contract v0.0.39

ASK is read-only. For Profile 7 two-sided IF rules it reports the settled current branch as `IF` or `OTHERWISE` without executing actions or settling the runtime again. Restored rules report the saved branch. Profile 1 through Profile 6 ASK output remains unchanged where no OTHERWISE branch exists.

`what IF rules are true` remains accepted. `what IF rules are false` is added for inspecting the opposite set. Individual Profile 7 IF records include their current branch and whether an OTHERWISE body exists.
