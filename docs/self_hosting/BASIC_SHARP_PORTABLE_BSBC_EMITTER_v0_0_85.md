# BASIC# Portable BSBC Profile 1 Emitter (v0.0.85 candidate)

**Status:** Unaccepted, source-only GitHub development. No compilation,
test execution, GitHub Actions, local installer, release tag or acceptance.
**Repository branch:** main only.
**Commit parent:** 59734e16b216df893f3e0c1d754d2ab44f3550e9.
**Accepted release:** v0.0.84 remains unchanged.
**Rollback:** Revert the next source-only commit to the parent above.

## Purpose

Move actual binary bytecode generation closer to the Ruby-independent
browser compiler. Do not invent another file format: emit the existing
BSharp Bytecode (BSBC) container defined in the Profile 1 machine contract,
referencing:
- spec/bytecode_v1/BASIC_SHARP_BYTECODE_PROFILE_v1.json
- compiler/small_compiler_subset_bsbc_encoder.rb
- compiler/bytecode_contract.rb
- compiler/world_save.rb

The accepted Ruby implementation remains the future parity referee.

## Source implementation

File: compiler/portable/bsharp_bsbc_encoder.mjs

The async encodeProfile1(ir) function consumes resolved BSharp IR and
returns a Uint8Array with the original Profile 1 BSBC layout:

- Magic "BSBC", little-endian binary version 1, profile version 1,
  exactly 32-byte header, 16-byte directory entries, file size and zero
  reserved fields.
- Eight ordered sections: STRS, META, KIND, THNG, STRT, EVNT, IFRL, CODE.
- Deterministic string interning in the Ruby encoder's traversal order:
  mandatory identities, Kinds, Things, START, event patterns, IF, actions.
- Kind parent indexes, Thing indexes and stable semantic source order.
- Official opcode/selector values and fixed operand records.
- Event selectors, action selectors, bound Kind references, every-Kind
  actions and caused-event instructions.
- IF state and exact-value conditions supported by Profile 1.
- SHA-256 meaning fingerprint over the sorted, line-number-free
  semantic IR fields. This relies on native Web Crypto, not Ruby.
- Code-block directory with section-relative offsets and record counts.
- A separate bounded hex view for inspection of produced binary bytes.

There is no alternate BSBC format, JSON header masquerading as binary,
manual executable code injection, JavaScript eval, or hidden Ruby fallback.

## Browser console

An Inspect BSBC control shows the calculated profile, section offsets,
record counts, total bytes, fingerprint, and first 4096 bytes in hex.
Unsupported profiles produce an explanatory message. No file download or
local installation is required. The console still runs its separate
limited BSIR interpreter; it does NOT execute these binary bytes.

## Supported versus deferred

The new emitter supports only the official Profile 1 bytecode contract.
It refuses Profiles 2-7 (including text values, numeric changes, compound
conditions, OTHERWISE, and game input/movement declarations) until their
actual binary records can be emitted. Such rejection is deliberate.

Unimplemented: independent BSBC structural loader, bytecode VM, full
meaning-profile coverage, binary parity against the accepted Ruby emitter,
verified deterministic fixtures, complete creator-language parity,
production cutover, and complete Ruby removal.

## Regression definitions (not executed)

tests/portable_bsharp_bsbc_encoder.test.mjs includes intended checks for:
- Header and ordered eight-section binary layout.
- Section offsets, record counts, and sizes.
- Source-line-independent SHA-256 meaning fingerprints.
- Actual START, DAMAGE and CHANGE_STATE binary instruction opcodes.
- Kind-set and caused-event selector/operand serialization.
- Explicit higher-profile rejection and bounded hex inspection.

No PASS assertions are claimed. The source must undergo the approved
Profile 1 parity/contract, malformed-input and full-system validations
before release acceptance or production use.

## Next development slice

Build an independent strict BSBC Profile 1 loader that validates every
header, section, string, opcode, operand, reference, selector, fingerprint
and block boundary before enabling any bytecode-driven execution.
After loader parity, implement a Ruby-independent bytecode VM and broaden
profiles 2-7. No change to creator-facing BASIC# syntax.
