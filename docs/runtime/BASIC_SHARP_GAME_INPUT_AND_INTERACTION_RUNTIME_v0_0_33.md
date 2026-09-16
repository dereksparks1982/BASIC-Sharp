# BASIC# game input and interaction runtime v0.0.33

The host adapter supplies deterministic key, pointer, button, hover, and context events. Movement normalizes diagonals and caps speed. A quick right-click on empty ground does not move; a held press does. Object hits take priority. Hover output follows declared order. Context actions bind `it`, execute atomically through the runtime or VM, and participate in Save state.
