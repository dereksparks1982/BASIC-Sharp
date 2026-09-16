# BSharp Bytecode Profile 2 v0.0.32

## Identity and compatibility

- Bytecode profile: `bsharp.bytecode.v2`
- Required meaning profile: `bsharp.meaning.v2`
- Fingerprint algorithm: `sha256-bsir-meaning-v2`
- Binary container format/version: unchanged `bsharp.bytecode.bin` version 1
- Profile format version in the header: 2

Profile 1 remains `bsharp.bytecode.v1`, requires `bsharp.meaning.v1`, uses profile format version 1, and retains its accepted bytes and validation rules.

## Added instructions

| Name | Purpose | Operands |
|---|---|---|
| `START_TEXT_VALUE` | Set a Thing's starting text slot | Thing index, value-name string index, literal string index |
| `CHANGE_TEXT_VALUE` | Set selected targets' text slot | selector code, reference index, value-name string index, literal string index |
| `TEXT_VALUE_EQUALS` | Test exact text equality in an IF | Thing index, value-name string index, literal string index |

All instruction records retain the accepted opcode/operand-count/reserved-zero/u32 operand layout.

## Role-aware string table

Profile identity and fingerprint strings remain mandatory first entries. Identifier references must point to canonical lowercase identifier strings. Literal operands may point to exact valid UTF-8 creator text strings. A string's role comes from its validated structural reference; accepting literal strings does not relax identifier rules.

## Complete validation

The loader rejects unsupported profile pairs, Profile 2 opcodes inside Profile 1, bad operand counts, bad references, nonzero reserved data, invalid UTF-8, unsupported literal boundaries, noncanonical identifier roles, and text/whole-number schema conflicts before exposing a frozen model.

The complete machine-readable contract is `spec/bytecode_v2/BASIC_SHARP_BYTECODE_PROFILE_v2.json`; deterministic hashes are recorded in `spec/bytecode_v2/BASIC_SHARP_BYTECODE_PROFILE_v2_FIXTURES_v1.json`.
