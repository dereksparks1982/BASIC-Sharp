# BASIC# Independent BSBC Profile 3: Game Controls and Interactions

**Status:** UNACCEPTED v0.0.85 source-only development on GitHub main.
**Parent commit:** e6ccab4ef7414d96b415bd1982eeb536aab1b2d4.
**Accepted release:** v0.0.84 remains unchanged.
**Rollback:** Revert this development commit to the parent above.
**Validation:** No compilation, tests, browser execution, GitHub Actions,
downloads, SSH, installers or release tags. Test definitions are NOT PASS evidence.

## Why this is the next roadmap slice

The original Profile 3 contract is
spec/bytecode_v3/BASIC_SHARP_BYTECODE_PROFILE_v3.json.
It adds three game-data sections to the existing binary container:
CTRL (control declarations), HOVR (hover fields) and CTXT (context menus).
Unlike movement or game rendering, these declarations are engine-neutral
meaning consumed by a host.

## Portable compiler source

compiler/portable/bsharp_compiler.mjs recognizes these existing forms:

- CONTROLS for PLAYER with "W moves PLAYER north" style direction controls,
  "PLAYER faces mouse pointer", and "holding right mouse moves PLAYER
  toward mouse pointer".
- HOVER for #Kind or @Thing, with name, kind, state and description fields.
- CONTEXT for #Kind or @Thing, with exact quoted labels, optional
  "when it is/isnt state" conditions, and established action words
  such as (change it to open and (cause PLAYER examines it.

Declarations use the established BSIR controls, hover_declarations and
context_declarations collections and context_it references.
The meaning-profile classifier follows the accepted priority:
OTHERWISE -> compound IF -> number comparisons -> movement ->
game declarations -> exact text -> Profile 1. Platform and world
movement controls are not implemented here and fail at source parsing.
Invalid Kinds, Things, hover fields, duplicate keys/labels and
unbound references produce explicit source errors.

## Binary encoder and strict loader

compiler/portable/bsharp_bsbc_encoder.mjs can select strict Profile 3
based on meaning v3. It keeps the same BSBC magic, little-endian header
and eight existing sections, inserts the official CTRL, HOVR and CTXT
sections before CODE, and writes an 11-entry section directory.

Each game section is canonical UTF-8 JSON with sorted object keys,
source-only line_number/raw fields excluded, stable array order and
exact counts. The Profile 3 semantic fingerprint covers all eight
meaning collections, including controls, hover and context declarations.

compiler/portable/bsharp_bsbc_loader.mjs recognizes only versions
1, 2 or 3 and rejects mismatched named Profile loaders. For v3 it
requires the 11 prescribed section IDs and validates each game section
as canonical JSON with correct record counts, known Kinds and Things,
supported control types, hover fields, state predicates, context labels,
bound context_it references and approved context actions. Invalid
UTF-8, malformed JSON, duplicate labels, out-of-range sections and
unexpected instructions remain fail-closed. The parser copies input
bytes before parsing and does not execute JSON or arbitrary JavaScript.

## Browser bytecode VM

compiler/portable/bsharp_bsbc_vm.mjs exposes the following for a
validated Profile 3 world:

- hoverFor(name): read information from matching Kind ancestry and
  named-Thing HOVER declarations; description must exist if requested.
- contextFor(name): compute visible context entries based on the Thing's
  current state; more-specific declarations override shared labels.
- executeContext(name, label): apply a currently offered, validated
  change/damage/carry/unlock action or queue a caused event, settle IFs
  and process follow-ups. Unavailable choices fail rather than bypass
  their conditions.
- controlBindings(): inspect declared input instructions.
- keyCommand(key): produce an engine-neutral move_intent for a declared
  keyboard direction, recording the intent in the trace.

No actual character coordinates, rendering, physics, hover pointer
integration, controller support, host command dispatch, movement
collision or persistence are claimed. A move_intent is a command for
a future host adapter, not proof a character moved.

## Live Console

A new "Profile 3: Door interactions" example uses a gate Thing,
keyboard direction declarations, HOVER fields, CONTEXT choices
and a caused Examine event. The BSBC console path exposes the selected
Thing, its hover fields, currently available context actions and
input-intent buttons. The existing Execute IR path remains separate
and does not silently implement Profile 3.

## Regression source, not results

tests/portable_bsharp_bsbc_profile3.test.mjs defines future checks for:
syntax and BSIR shapes, Profile 3 binary header/11 sections, strict
loader roundtrip, source-line-independent fingerprints, state-dependent
context menus, hover inheritance and override, caused events, host
intent non-mutation, malformed JSON/count rejection, invalid source
declarations and strict Profile 1/2 backward boundaries.

The file has NOT been executed. Browser rendering and real source,
BSIR, Ruby emitter, bytecode and VM parity have NOT been established.

## Next stages

Close Profile 3 compatibility gaps and test against accepted Ruby
fixtures when authorized. Implement safe host-input integration and
later Profile 4 movement meaning, plus remaining Profile 5-7 binary
contracts. Do not call the independent path production-ready, fully
Ruby-free or an accepted numbered release until validation is complete.
