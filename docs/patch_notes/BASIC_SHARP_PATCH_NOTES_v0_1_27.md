# BASIC# Patch Notes v0.1.27

BASIC# can now compile resolved program meaning into real BSharp Bytecode files.

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-bytecode
```

This creates:

```text
samples/first_room.bsbc
samples/first_room.bsbc.txt
```

Compiling the matching `.bsir.json` produces identical bytes. The text companion shows the deterministic machine instructions for inspection.

This build does not run bytecode yet. The next eligible lane is the bytecode loader and complete validator.
