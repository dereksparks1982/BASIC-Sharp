# BASIC# Portable BSBC Profile 1 Loader (v0.0.85 candidate)

**Status:** Unaccepted, uncompiled and untested GitHub source-only candidate.
**Branch:** main only.
**Previous GitHub commit:** 02db1eeec063b7150a8c0341cfaf5a5c333a9de9.
**Accepted release/tag:** v0.0.84, unchanged.
**Rollback:** Revert this development commit to the parent above.
**Owner workflow:** No downloads, SSH files, local commands, automated tests,
compilation or GitHub Actions.

## Purpose

Provide an independent, strict BSharp Bytecode (BSBC) Profile 1 binary
loader in browser-compatible JavaScript, without invoking Ruby or
inventing a new bytecode format. The normative sources remain:

- spec/bytecode_v1/BASIC_SHARP_BYTECODE_PROFILE_v1.json
- compiler/bytecode_contract.rb
- compiler/bytecode_loader.rb
- compiler/small_compiler_subset_bsbc_loader.rb
- docs/bytecode/BASIC_SHARP_BYTECODE_FORMAT_AND_INSTRUCTION_CONTRACT_v0_0_26.md

## Source-only implementation

**File:** compiler/portable/bsharp_bsbc_loader.mjs

**API:** loadProfile1(Uint8Array, {expectedFingerprint})

The loader makes an independent copy of the supplied byte array and
decodes only the existing Profile 1 format. It rejects malformed input
before returning a model:

- The 32-byte header must carry magic BSBC, binary version 1, profile 1,
  eight sections, a directory at offset 32, fixed entry width 16,
  exact complete file size and zero reserved header field.
- Required sections must appear in canonical order:
  STRS, META, KIND, THNG, STRT, EVNT, IFRL, CODE.
- Section offsets/lengths must be in bounds, four-byte aligned,
  nonoverlapping and contiguous except for zero alignment padding.
  Trailing unexplained data is forbidden.
- UTF-8 STRS records are length-delimited, validated using a fatal
  decoder, four-byte padded with zero bytes and distinct. The first
  three strings must be the prescribed Profile 1 identities.
- META carries exact identity-string indexes, a 32-byte declared
  meaning fingerprint and Kind, Thing, START, WHEN, IF, CODE counts
  matching the section directory.
- Kind names and Thing names must be distinct, their definition/source
  order canonical, parent Kind references must precede descendants,
  and all Kind/Thing indexes must exist.
- START and CODE instructions and IF conditions must use known
  Profile 1 opcodes, correct operand counts, zero reserved fields,
  valid references, legal selector contexts and whole-number ranges.
- WHEN records must have valid actors/targets and canonical block
  and source order; IF condition records and block references must
  be within bounds.
- CODE uses the official block count and 16-byte block directory.
  Blocks and instructions must be contiguous, properly bounded and
  have correct record counts. Overlap, gaps, invalid opcodes and
  instruction crossing block boundaries are rejected.
- String references must be used in first-encounter order and valid
  semantic identifier strings must be normalized.
- Duplicate starting number assignments to the same Thing and name
  are rejected.
- Profile versions 2-7 and malformed/unrecognized selectors are
  rejected rather than partially interpreted.
- A 64 MiB per-input browser validation limit bounds resource use.

A returned object describes the parsed binary and is not executable.
This parser uses no JavaScript eval, no external service and no Ruby.

## Expected fingerprint trust boundary

The loader can compare the BSBC META fingerprint against a trusted
expected 64-character SHA-256 meaning fingerprint from the same source
IR. This catches unrelated-program bytecode identity mismatches. The
stored fingerprint field itself is not a signature, and a structural
parse cannot independently reconstruct the original source meaning.
Neither a successful parse nor a matching META fingerprint proves
complete program integrity or semantic equivalence to the Ruby
compiler. Binary parity and adversarial testing are still required.

## Live Console

The Inspect BSBC feature now calls encodeProfile1 to produce bytes,
then loadProfile1 with the expected fingerprint to validate them
before displaying an inspected section directory, counts and hex
preview. On failure, the panel displays a plain-language rejection.

**No BSBC code is executed.** The Console still runs a bounded
JavaScript BSIR interpreter. The accepted Ruby compiler and native
BSharp VM are untouched.

## Future regression definitions (not executed)

tests/portable_bsharp_bsbc_loader.test.mjs covers:
- Valid binary loads and source-fingerprint matching.
- Refusal of wrong magic, version, file size, reserved fields.
- Malformed sections, overlap, alignment and trailing bytes.
- STRS truncation, invalid UTF-8 and META counts.
- Kind and Thing index corruption.
- Wrong opcode, operand count and reserved record fields.
- Invalid WHEN selectors, IF conditions and CODE block offsets.
- Deliberate refusal of higher-profile bytecode.
- Preservation of the supplied byte array.

These are test source definitions, not test results. No PASS claim.

## Remaining work

Independent code-byte execution (a real BSBC VM), complete loader
equivalence and negative tests against the Ruby loader, string
role/type parity audits, exact SHA-256 fixture parity, Profiles 2-7,
broader BASIC# language parity and removal of the Ruby bootstrap.
The current candidate has not been validated or accepted.

**Next roadmap item:** A bounded Ruby-independent BSBC Profile 1
execution engine using this strict loader as its only binary entry.
Do not promote it to production without owner-authorized tests.
