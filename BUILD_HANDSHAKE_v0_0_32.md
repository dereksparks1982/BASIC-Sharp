# BASIC# v0.0.32 Build Handshake

## Approved build

- Title: **Meaning Profile 2: Creator-Facing Text Values and BSharp Bytecode Profile 2**
- Accepted base: clean `main` at commit `e7126c1f7e1963a72abb367687bfa0483fb59b64`, tag `v0.0.31`
- Rollback: commit `e7126c1f7e1963a72abb367687bfa0483fb59b64`, tag `v0.0.31`
- Project scope: 45 modified paths, 40 added paths, 0 deleted paths, 85 total
- Scope expansion: Derek approved adding `tools/runtime_transition.rb` as the required 85th project path after its hardcoded version checks were found.
- Package utility: one installer/validator script inside the changed-files-only ZIP; it is not an installed project path.
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_0_32_MEANING_PROFILE_2_CREATOR_FACING_TEXT_VALUES_AND_BSHARP_BYTECODE_PROFILE_2_CHANGED_FILES_ONLY.zip`

## Included behavior

- Straight-double-quoted, one-line valid UTF-8 creator text.
- Exact preservation and equality for case, punctuation, and spaces.
- Typed text through source, BSIR, fingerprints, Profile 2 BSBC, complete loading, direct VM execution, reference runtime, reactive IF, Save/restore, ASK, and shadow parity.
- Profile 2 instructions `START_TEXT_VALUE`, `CHANGE_TEXT_VALUE`, and `TEXT_VALUE_EQUALS`.
- Role-aware identifier and literal string-table validation.
- Profile 1 selection and compatibility for programs that use no Profile 2 meaning.

## Excluded behavior

No interpolation, concatenation, escape sequences, multiline text, `(speak ...)`, text event matching, arithmetic on text, editor/IDE work, engine bridge, self-hosting, licensing, monetization, optimization, JIT, native code, or unrelated syntax.

## Acceptance gate

The installer must verify the accepted Git base and clean tree, verify all base and package hashes, install exactly the approved paths, run Ruby with warnings enabled, run the complete test and validation lanes on native Ruby, verify Profile 1 artifacts, and roll back every mutation if a post-install gate fails. Derek accepts the build only after those checks pass on his machine.
