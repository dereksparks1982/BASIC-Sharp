# BASIC# v0.1.28 BSharp Bytecode Loader and Complete Structural Validation 1

## Purpose

v0.1.28 adds the first arbitrary `.bsbc` reader. It validates the complete BSharp Bytecode Profile 1 artifact before exposing a trusted program model.

```text
.bsbc bytes
-> complete structural and cross-reference validation
-> deeply frozen trusted in-memory model
-> deterministic summary or binary-derived disassembly
```

The loader is intentionally non-executing. The future BSharp virtual machine is the only approved next owner of instruction execution.

## Public entry points

```ruby
BasicSharp::BytecodeLoader.read(path)
BasicSharp::BytecodeLoader.new(binary_bytes)
```

Optional exact meaning comparison:

```ruby
BasicSharp::BytecodeLoader.read(path, expected_fingerprint: fingerprint)
```

CLI:

```bash
ruby compiler/basic_sharp.rb program.bsbc
ruby compiler/basic_sharp.rb program.bsbc --disassemble-bytecode
ruby compiler/basic_sharp.rb program.bsbc --against program.bsharp
ruby compiler/basic_sharp.rb program.bsbc --against program.bsir.json
```

## Trusted model

The loader reconstructs:

- bytecode and meaning profile identities;
- `sha256-bsir-meaning-v1` fingerprint;
- deterministic strings;
- Kinds and parent relationships;
- Things and definition order;
- START records;
- WHEN records;
- IF conditions;
- CODE blocks and instructions.

The complete model, nested arrays, hashes, and strings are deeply frozen. Separate loader instances do not share mutable model state. A rejected file exposes no model.

## Validation boundary

Validation covers:

- 32-byte header and eight-entry directory;
- exact section identities and order;
- file-size agreement, offsets, lengths, alignment, gaps, overlaps, zero padding, and trailing bytes;
- valid canonical UTF-8 string records, mandatory prefix, uniqueness, use, and first-encounter order;
- META identities, fingerprint shape, and count agreement;
- Kind uniqueness, parent bounds, ancestry circles, parent-before-descendant order, and source order;
- Thing uniqueness, Kind references, and definition order;
- START opcode and operand rules;
- WHEN selectors, references, block order, and source order;
- IF operators, operands, block order, and source order;
- CODE block directory, identifiers, boundaries, instruction counts, opcodes, operand counts, reserved fields, selectors, references, and whole-number bounds.

## Fingerprint meaning

Structural validation proves that an artifact is internally valid BSharp Bytecode. It does not independently prove which source file created it.

`--against` compiles or reads the supplied `.bsharp` or `.bsir.json`, computes the accepted normalized meaning fingerprint, and requires exact equality.

## Malformed fixtures

`spec/bytecode_v1/BASIC_SHARP_BYTECODE_LOADER_FIXTURES_v1.json` names all 41 malformed-bytecode rules. Tests create corruptions in memory from a known-good sample. No loose corrupted binary files are stored in the repository.

Every truncated prefix of the reference artifact is also rejected.

## Preserved artifacts

The six v0.1.27 sample `.bsbc` files and their hashes remain unchanged. Loader-generated disassembly must exactly equal each committed `.bsbc.txt` companion.

## Exclusions

No VM, bytecode execution, runtime replacement, world mutation, ASK against BSBC, optimization, compression, bytecode Profile 2, binary-layout change, new creator syntax, or language-semantic change is included.
