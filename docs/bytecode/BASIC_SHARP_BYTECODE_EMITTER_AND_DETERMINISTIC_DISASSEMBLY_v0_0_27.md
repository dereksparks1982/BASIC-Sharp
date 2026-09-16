# BASIC# v0.0.27 BSharp Bytecode Emitter and Deterministic Disassembly 1

## Status

Candidate implementation for owner installation and acceptance.

## Purpose

v0.0.27 turns resolved BSharp IR meaning into the first real BSharp Bytecode artifacts governed by `bsharp.bytecode.v1`.

```text
.bsharp source -> resolved BSIR -> deterministic .bsbc
.bsir.json      -> resolved BSIR -> deterministic .bsbc
```

Equivalent normalized `bsharp.meaning.v1` meaning must produce byte-identical binary and diagnostic disassembly output.

## CLI

```bash
ruby compiler/basic_sharp.rb program.bsharp --emit-bytecode
ruby compiler/basic_sharp.rb program.bsir.json --emit-bytecode
ruby compiler/basic_sharp.rb program.bsharp --emit-bytecode --out /tmp/program.bsbc
```

Each successful emission writes a pair:

```text
program.bsbc
program.bsbc.txt
```

The text file is diagnostic disassembly. It is not creator-facing BASIC# syntax.

## Deterministic lowering order

1. Intern mandatory strings:
   - `bsharp.bytecode.v1`
   - `bsharp.meaning.v1`
   - `sha256-bsir-meaning-v1`
2. Traverse semantic sections in `KIND`, `THNG`, `STRT`, `EVNT`, `IFRL`, `CODE` order.
3. Add every referenced Kind ancestor before its descendants.
4. Preserve Thing definition order.
5. Preserve START fact order.
6. Assign all WHEN blocks before all IF blocks.
7. Use zero-based indexes.
8. Fill alignment padding with zero bytes.
9. Store the program fingerprint as 32 raw SHA-256 bytes.

## Lowered Profile 1 machinery

Starting records:

```text
START_STATE
START_RELATION
START_VALUE
```

Actions:

```text
DAMAGE
CHANGE_STATE
CHANGE_VALUE
CARRY
UNLOCK
CAUSE_EVENT
```

Selectors:

```text
EXACT_THING
ONE_KIND
BOUND_THAT_KIND
EVERY_KIND
NO_REFERENCE
```

IF conditions:

```text
STATE_IS
STATE_ISNT
RELATION_EXISTS
VALUE_EQUALS
```

## Rejection rules

Emission fails without partial output when:

- source or BSIR contains an error or warning;
- input is a BSharp Save rather than a program;
- an action, condition, selector, Kind, Thing, number, or reference cannot be represented by Profile 1;
- `--emit-bytecode` is combined with execution, ASK, save, AST, or BSIR output modes;
- the requested output does not end in `.bsbc`;
- either output file cannot be written safely.

## Atomic pair write

The binary and disassembly are written to temporary files first. Existing outputs are temporarily preserved, both replacements are completed, and backups are removed only after success. A failed replacement restores the previous pair or leaves no new pair.

## Fixtures

Six sample binaries and six sample disassemblies are committed under `samples/`.

Hashes for those files and the twelve valid Meaning Profile cases are locked by:

```text
spec/bytecode_v1/BASIC_SHARP_BYTECODE_EMITTER_FIXTURES_v1.json
```

Meaning case 13 remains invalid and must be rejected without output.

## Explicit exclusions

No arbitrary bytecode loader, VM, bytecode execution, runtime replacement, optimization, compression, new creator syntax, new language meaning, editor, IDE, engine bridge, or self-hosting work is included.
