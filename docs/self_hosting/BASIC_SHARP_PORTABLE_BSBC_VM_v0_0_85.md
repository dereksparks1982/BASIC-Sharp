# BASIC# Portable BSBC Profile 1 Virtual Machine

Status: UNACCEPTED v0.0.85 source-only candidate on GitHub main.
Parent commit: bc6a3c0143d597050bf88c54821191939266452f.
Accepted release/tag: v0.0.84, unchanged.
Rollback: revert the development commit to the parent above.
Validation: NO compilation, test execution, browser run or GitHub Actions.
Owner workflow: GitHub main only, no downloads, installers, SSH or terminal.

## Purpose

Make a Ruby-independent bytecode execution path after the independent BSBC
Profile 1 encoder and strict binary loader. The existing browser BSIR
interpreter does not count as a BSBC VM. This new module does.

## New source

File: compiler/portable/bsharp_bsbc_vm.mjs
Exports: BSharpBytecodeVM and BSBCVMError.

The constructor takes Uint8Array BSBC binary bytes, not an unvalidated
model, source text or BSIR. It calls loadProfile1 internally and optionally
compares the META fingerprint against trusted expected program meaning.
It does not use Ruby, JavaScript eval, network services or a fallback
source interpreter. The model returned by the strict loader supplies
the actual execution instruction records.

## Profile 1 behavior implemented in source

- START_STATE, START_RELATION and START_VALUE initialize the world from
  bytecode instructions, with damage initially zero for each Thing.
- WHEN chooses exact Things or one matching Kind. It includes inherited
  Kind distance; exact matches outrank equally close general Kind
  matches. Source order resolves any remaining tie.
- CODE instructions include DAMAGE, CHANGE_STATE, CHANGE_VALUE, CARRY,
  UNLOCK and CAUSE_EVENT. State changes obey the encoded opposite state.
- EXACT_THING, BOUND_THAT_KIND and EVERY_KIND action selectors resolve
  named Things, event-bound Things and matching collections in Thing order.
  Arbitrary one-Kind caused event selection is rejected, not guessed.
- IF conditions include STATE_IS, STATE_ISNT, RELATION_EXISTS and
  VALUE_EQUALS. Reactive IF rules rearm when the condition becomes false.
- Caused events enter a FIFO queue and are processed after each event and
  reactive IF settlement. An unmatched caused event is logged and skipped.
- Loop and resource bounds: at most 64 caused follow-up events per
  invocation; a bounded number of reactive IF firings; at most 10,000
  action instructions per root event; at most 512 targets per set action.
- Failed action bodies discard their staged caused events. World changes
  that preceded a failure are not automatically rolled back; Reset
  recreates the START state from the validated binary.
- The browser world inspector and typed event interface share the same
  API as the older IR sandbox, but run against separate engines.

## Live Console source

The existing Execute control runs the browser BSIR subset.
The new Execute BSBC control performs:
1. BASIC# source -> experimental independent BSIR compiler.
2. BSIR -> official Profile 1 BSBC binary encoder.
3. Binary -> strict BSBC loader and expected fingerprint comparison.
4. Validated BSBC -> new binary VM, including START/WHEN/IF execution.

Unsupported profiles or invalid bytes produce explicit errors, without
silent fallback to the IR interpreter. A source-change guard avoids
displaying a stale asynchronously compiled binary as a different program.
The existing BSBC inspector remains available.

## Tests defined, NOT executed

New file tests/portable_bsharp_bsbc_vm.test.mjs declares future checks for:
binary-only loader entry; state and number initialization; WHEN and IF
execution, rearming and reset; event-button invocation and unknown event
rejection; numeric assignment preconditions; carry and unlock; Kind
inheritance and selected it references; exact-rule precedence; set
selection; FIFO caused events; bounded cyclic chains; profile rejection;
and expected fingerprint refusal.

The tests are not PASS evidence. Neither actual browser execution nor
binary parity against the accepted Ruby VM has been established.

## Explicit exclusions and release truth

This is an experimental, incomplete Profile 1 VM, not the full BASIC#
compiler or a verified Ruby replacement. It does not implement Profiles
2-7, all language features, movement, game input, CONTROLS, HOVER,
CONTEXT, world-save compatibility, full semantic selectors, bytecode
fixture parity or self-hosting. The accepted Ruby production compiler
and bytecode VM remain unchanged and authoritative.

Next development work: audit parity and extend Profile 2 text semantics
and remaining bytecode profiles without changing creator syntax.
