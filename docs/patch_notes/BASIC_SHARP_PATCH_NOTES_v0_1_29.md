# BASIC# v0.1.29 Patch Notes

BASIC# can now run its own BSharp Bytecode through the first BSharp Virtual Machine.

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsbc --run "player attacks cinder"
```

The VM interprets validated bytecode directly. It does not convert the bytecode back into BSIR and does not hand execution to the old reference Runtime.

This build is intentionally the first execution milestone, not the final runtime. Save/ASK integration and full three-path hardening remain next.
