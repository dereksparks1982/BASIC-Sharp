# BASIC# Patch Notes v0.1.39

BASIC# now lets a creator state both sides of a changing condition with IF / OTHERWISE. The current side runs once at START; afterward only a change of truth runs a branch. This makes alive/defeated, open/closed, available/unavailable, and similar rules direct to express without adding programming-style ELSE syntax.

The change reaches source, BSIR, BSBC, both runtimes, ASK, Save/restore, fixtures, diagnostics, and stress validation. Older bytecode profiles remain unchanged.
