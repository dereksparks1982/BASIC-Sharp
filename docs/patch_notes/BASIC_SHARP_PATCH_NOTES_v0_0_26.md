# BASIC# Patch Notes v0.0.26

BASIC# now has an official design for the compact program artifact that will eventually feed its own virtual machine.

```text
BSharp Bytecode
BSBC
.bsbc
bsharp.bytecode.v1
```

This version does not produce or run `.bsbc` files. It defines the roadbed first: exact bytes, sections, instructions, references, ordering, rejection rules, and tests.

Run:

```bash
ruby tools/bytecode_contract.rb
```

The existing BASIC# programs continue running through the Ruby bootstrap exactly as before.
