# BASIC# Patch Notes v0.0.15

Kind families now work instead of merely sitting in the paperwork.

```text
wyrm -> dragon -> creature -> thing
```

A `wyrm` can now answer a Trigger written for a `dragon`, `creature`, or `thing`.

```text
WHEN
[player attacks a creature
<then> (damage that creature].
```

Exact named-Thing Triggers still go first. When several Kind Triggers fit, BASIC# chooses the nearest family member rather than letting a broad ancestor cut the line.

Broken or circular Kind families are rejected with the offending parent or complete loop shown plainly.
