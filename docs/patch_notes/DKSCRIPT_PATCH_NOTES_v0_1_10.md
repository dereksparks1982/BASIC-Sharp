# DKScript Patch Notes v0.1.10

A Trigger can now select a named Thing by its Kind:

```text
WHEN
[player attacks a guard
<then> (damage that guard].
```

Running `player attacks henry` selects Henry and makes `that guard` mean Henry for that event.

Exact events such as `player attacks ember` still work. No new syntax or official words were added.
