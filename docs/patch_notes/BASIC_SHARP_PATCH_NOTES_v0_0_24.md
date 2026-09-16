# BASIC# Patch Notes v0.0.24

BASIC# now has a stable implementation-neutral meaning target. The current Ruby bootstrap and future bytecode or VM implementations can be tested against the same 13 Profile 1 cases.

The only creator-visible correction is that WORLD, STATES, RELATIONS, ACTIONS, WHILE, and OTHERWISE are now plainly rejected instead of being half-recognized parser leftovers.
