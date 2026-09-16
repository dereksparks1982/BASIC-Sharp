# BASIC# Demon Killer controls, hover, and context

```bsharp
CONTROLS for PLAYER
[
    W moves PLAYER north
    PLAYER faces mouse pointer
    holding right mouse moves PLAYER toward mouse pointer
].

HOVER for #door
[
    name
    state
].
```

Held WASD directions combine and normalize. Held right mouse on empty ground moves toward the pointer; right-click over an object opens its context menu and always wins over movement.
