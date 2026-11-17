# BASIC# Independent BSBC Profile 2 Text Support

Status: unaccepted v0.0.85 source-only candidate, committed directly to main.
Starting parent: fa7f12c1d4c1183604e21f4c7d111e9c6d80e005.
Accepted production version/tag: v0.0.84 unchanged.
Rollback: revert this candidate commit to the stated parent.
Validation: NOT RUN, no compiling, execution of tests, browser testing,
GitHub Actions, downloads, local installers, SSH or user terminal commands.

## Why Profile 2

Profile 1 can encode whole numbers and states, but not creator-facing text.
The established bytecode contract at
spec/bytecode_v2/BASIC_SHARP_BYTECODE_PROFILE_v2.json
adds exact UTF-8 text in START, change actions and reactive IF comparisons.
This candidate extends the independent binary pipeline accordingly without
inventing a different format or new creator-facing syntax.

## BSBC encoder

compiler/portable/bsharp_bsbc_encoder.mjs now exports:
- encodeProfile1: strict Profile 1 only, preserved API.
- encodeProfile2: strict Profile 2 only.
- encodeBSBC: chooses Profile 1 or 2 from resolved meaning, no fallback.
- meaningFingerprint and hexView: existing helper APIs retained.

The Profile 2 binary uses header profile version 2 and the exact required
string identities bsharp.bytecode.v2, bsharp.meaning.v2 and
sha256-bsir-meaning-v2. The eight ordered sections and 32-byte container
header stay unchanged. Profile 2 adds the official opcodes:
- START_TEXT_VALUE 0x13: Thing, value-name string, exact text string.
- CHANGE_TEXT_VALUE 0x26: action selector, reference, value-name, text.
- TEXT_VALUE_EQUALS 0x34: Thing, value-name, exact text.

Creator-facing literals are interned at their first semantic occurrence
without trimming, case-folding or altering internal spaces, punctuation or
non-ASCII characters. Invalid multiline literals, straight double quotes,
backslash escapes, and interpolation markers are rejected. Type names are
tracked independently of content, preventing accidental treatment of
text as a whole number or use of damage as text. Profile 2 requires at
least one actual text feature; Profiles 3-7 remain explicitly unsupported.

## Strict bytecode loader

compiler/portable/bsharp_bsbc_loader.mjs now exports loadProfile1,
loadProfile2 and loadBSBC. Each named profile loader checks the binary
header version exactly; loadBSBC accepts only header versions 1 or 2.

Profile 2 adds strict parsing and operand-index validation for the three
new opcodes. Literal string roles retain exact text and reject unsupported
creator-text characters. Value names retain canonical normalized
identifier rules. The loader enforces duplicate START assignment checks
and the global established text-versus-number type contract across START,
IF and action CODE records. Profile 2 text opcodes cannot be smuggled
into a Profile 1 container. Existing header, section, Kind, Thing,
offset, padding, block and fingerprint checks remain required.

An expected semantic fingerprint must come from trusted program meaning.
The bytecode fingerprint alone is not an authenticity signature.

## Bytecode VM and browser

compiler/portable/bsharp_bsbc_vm.mjs now calls loadBSBC as its binary
entrypoint. A validated Profile 2 model can initialize exact text
(START_TEXT_VALUE), change existing typed text values atomically for a
selected target set (CHANGE_TEXT_VALUE preflight), and perform
case-sensitive exact reactive comparisons (TEXT_VALUE_EQUALS).

site/console.js selects encodeBSBC automatically for both the Execute
BSBC path and the BSBC inspector; the engine accepts either supported
profile and explicitly reports unsupported higher profiles. The older
IR sandbox remains separate. Existing typed events, event buttons,
world inspector, reset, and binary preview continue to use the selected
engine. HTML messaging now describes Profiles 1 and 2, not only 1.

## Future regression definitions

tests/portable_bsharp_bsbc_profile2.test.mjs contains UNEXECUTED cases for:
header/profile identities; exact punctuation, spacing and UTF-8;
text START/change/IF operations; text equality case sensitivity;
Kind-set text updates; Profile 1 binary and API preservation;
Profile-specific refusal; invalid text literal rejection;
text/number conflicts; malformed bytecode indexes and fingerprints;
and rejection of Profiles 3-7.

No PASS or parity assertions have been established by a test run.

## Remaining work and release boundary

Full Ruby bytecode/referee parity, actual browser execution checks,
negative structural fuzzing, world save/ASK integration, complete
Profiles 3-7 (input, movement, numeric comparisons, compound IF,
OTHERWISE), general language semantics and complete Ruby retirement
remain outstanding. Do not mark v0.0.85 accepted without explicit
owner-authorized validation and the required release checks.

Next: audit Profile 2 behavior and binary invariants, then follow the
existing Profile 3 contract for game-control and interaction meaning.
