# BASIC# Live Console: v0.0.85 source-only development candidate

**Branch:** main only. **Status:** unaccepted and untested. No compilation, no
test execution, no GitHub Actions, no installer, and no release tag.

The repository root index.html is a static GitHub Pages entrypoint. It imports
the existing browser-native BASIC# source-to-IR compiler and the new
compiler/portable/bsharp_sandbox.mjs simulation runtime directly as ES modules.

The console provides:
- Editable BASIC# source, supplied examples, Execute, Reset, and Ctrl+Enter.
- Clickable WHEN event triggers that perform real state and number changes.
- START facts, state changes, damage, carry, unlock, number changes, and
  reactive IF/OTHERWISE clauses, limited to supported direct object references.
- Inspectable event trace, world state, and generated BSharp IR.
- Local editor persistence (best effort) and plain-English error reporting.
- No eval, no remote code service, no arbitrary JavaScript execution.

The runtime is **not** a full BSharp VM or .bsbc executor. BSharp IR produced
by the independent JavaScript compiler is interpreted directly for a deliberately
bounded BASIC# language subset. Unsupported operations are rejected before
execution where possible, and the accepted Ruby compiler remains unchanged.

The site is placed in the repository root for GitHub Pages configurations that
publish from main/(root). If Pages is configured for /docs or a custom Actions
workflow, the deployment source will need to point to the appropriate content
before the site becomes visible. We could not verify Pages settings via the
available GitHub connection, and no settings were changed.

Known limitations: no full selectors, text/phrase value semantics, CONTROLS,
HOVER, CONTEXT, generated BSBC, BSBC VM, true game rendering, world saves,
remote publishing, proof of parity or native compiler self-hosting. The console
must not be advertised as a completed Ruby replacement.

This source-only candidate must not be accepted as a numbered release until
the owner resumes testing and the mandatory full suite and contract audit pass.
Failed previous v0.1.85 local installer attempts remain acknowledged history.

Next: strengthen the JavaScript compiler's semantic parity and add a
Ruby-independent BSBC emitter and VM, then bring the full language to the
interactive console. Creator syntax and profiles 1 through 7 are protected.

## Condition/value interpretation extension (same unaccepted candidate)

The browser sandbox gained numeric threshold IF comparisons, exact quoted text
value storage/comparisons/changes, one-object definite Kind references, and
plain-English object-interaction lowering. The console gained examples for
these features. None of the additions were compiled, executed or validated;
they do not turn the sandbox into a real BSBC VM. See
`docs/self_hosting/BASIC_SHARP_PORTABLE_CONDITION_VALUES_v0_0_85.md`.

## Event bindings (unaccepted source-only candidate)

The console can now interpret an entered event such as PLAYER attacks @goblin,
match a named or Kind-pattern WHEN rule, and bind "it" to the selected Thing.
The nearest Kind match wins, with exact named rules preferred. Event buttons
show concrete Things and do not duplicate shadowed entries. This remains an
untested browser subset, not the accepted BSharp VM. Details:
BASIC_SHARP_PORTABLE_EVENT_BINDINGS_v0_0_85.md.

## Mass selection and caused events (unaccepted source-only candidate)

Added action-only every #Kind selection, FIFO (cause event staging, and a
bounded 64-follow-up limit in the browser sandbox. A new alarm/guards example
demonstrates one event causing another. See
BASIC_SHARP_PORTABLE_CAUSED_EVENTS_v0_0_85.md. The console is still an
experimental BSIR interpreter, not the BSBC VM, and no tests were run.

## BSBC inspection source-only extension

The browser console now offers an Inspect BSBC button that calls the
independent Profile 1 emitter, displays the section directory, fingerprint
and a bounded binary hex preview, and explains when a program uses a higher
profile. The binary is NOT executed or downloaded and the emitter has
not been compiled or tested. See
docs/self_hosting/BASIC_SHARP_PORTABLE_BSBC_EMITTER_v0_0_85.md.

## Strict Profile 1 BSBC inspection (unaccepted candidate)

The Inspect BSBC control now reads emitted BSBC bytes through
compiler/portable/bsharp_bsbc_loader.mjs and refuses malformed sections
or instructions before displaying their contents. It validates against
the expected source fingerprint. This is inspection only: BASIC# console
execution still uses its limited BSIR interpreter, not the BSBC VM.
No tests were run. See BASIC_SHARP_PORTABLE_BSBC_LOADER_v0_0_85.md.

## Profile 1 BSBC bytecode execution (unaccepted development)

The console source offers two distinct modes: Execute (the IR sandbox) and
Execute BSBC (actual Profile 1 bytecode VM). The binary path first emits
real BSBC, validates its structure and expected meaning fingerprint, and
executes the decoded bytecode's START, WHEN, IF and CODE records. The
binary VM is experimental, not tested, and higher profiles are rejected.
See BASIC_SHARP_PORTABLE_BSBC_VM_v0_0_85.md.

## Independent Profile 2 BSBC support (unaccepted source candidate)

The Execute BSBC and Inspect BSBC controls now select the real Profile 1 or
Profile 2 binary format from source meaning. Profile 2 carries exact text
values through the encoder, strict loader, and independent bytecode VM:
START text, text change and text IF equality. Later profiles still error.
The browser and parity checks have NOT been run. Details:
BASIC_SHARP_PORTABLE_BSBC_PROFILE2_v0_0_85.md.

## Profile 3 game declarations and interaction panel (source-only)

The console's independent BSBC mode now recognizes a limited set of
CONTROLS, HOVER and CONTEXT grammar and binary sections. A Profile 3
example provides a door's hover information, Open/Close/Examine
context actions, and keyboard movement intent buttons. No rendered
world or character movement is implied. The original IR interpreter
does not implement Profile 3 and will fail explicitly. No browser
testing has occurred. See BASIC_SHARP_PORTABLE_BSBC_PROFILE3_v0_0_85.md.
