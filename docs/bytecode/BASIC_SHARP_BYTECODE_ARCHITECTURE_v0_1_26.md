# BASIC# BSharp Bytecode Architecture v0.1.26

## Role

BSharp Bytecode is the future compact execution artifact between resolved BSharp IR and the BASIC# virtual machine.

```text
BASIC# source -> BSharp IR -> BSharp Bytecode -> BASIC# VM
```

v0.1.26 defines the architecture and validates the contract. It deliberately does not emit or execute bytecode.

## Identity

```text
Name: BSharp Bytecode
Short name: BSBC
Extension: .bsbc
Magic: BSBC
Binary format: bsharp.bytecode.bin version 1
Profile: bsharp.bytecode.v1
Meaning authority: bsharp.meaning.v1
Byte order: little-endian
Alignment: four bytes
```

## Separation of jobs

- **BSharp IR** is readable resolved program meaning.
- **BSharp Bytecode** is compact, deterministic execution input.
- **BSharp Save** is settled runtime world state.
- **BSharp ASK** is read-only inspection.

These are not interchangeable formats.

## Container

The file begins with a fixed 32-byte header and eight 16-byte section-directory entries. Section data begins at byte 160 or later and is four-byte aligned.

```text
STRS  deterministic UTF-8 strings
META  profiles, fingerprint, and counts
KIND  referenced Kind ancestry
THNG  Things in definition order
STRT  starting-world instructions
EVNT  WHEN patterns and code-block references
IFRL  reactive IF conditions and code-block references
CODE  ordered action blocks
```

## Determinism

Equivalent normalized `bsharp.meaning.v1` meaning must produce byte-identical BSBC. Source line numbers, raw spelling, timestamps, machine paths, Ruby classes, caches, and object addresses are not bytecode meaning.

## Future boundary

A later emitter will lower normalized BSIR into BSBC. A later loader and VM will validate and execute BSBC. Those steps require separate proposals and approval.
