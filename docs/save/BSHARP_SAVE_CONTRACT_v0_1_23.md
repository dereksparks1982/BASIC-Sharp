# BSharp Save Contract v0.1.23

The v0.1.22 save format remains `bsharp.save.json`, format version 1.

v0.1.23 adds read-only ASK inspection of restored worlds and save metadata. Loading still validates the complete save before changing runtime state, and START is not replayed.

`what is the save` reports whether a save was loaded, its format version, settled status, Thing count, and matched fingerprint. ASK does not alter the save document or save readiness.

The same program and settled world continue producing byte-identical BSharp Save files, now marked as created by BASIC# v0.1.23 when newly written.
