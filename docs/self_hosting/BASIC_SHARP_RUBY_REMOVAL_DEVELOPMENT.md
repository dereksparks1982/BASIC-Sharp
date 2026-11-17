# BASIC# Ruby-removal work: source-only development

Status: unaccepted experiment. No compiler runs, no tests, no GitHub Actions, no release.

The main branch contains a Ruby-independent source-to-BSharp-IR path in
compiler/portable/bsharp_compiler.mjs and a Node CLI in
compiler/portable/bsharp_cli.mjs. These are working source implementations
for a bounded subset, not a full language implementation.

The compiler parses the established Heads, Bodies, comments, Kind and Thing
declarations, state and numeric START facts, basic WHEN rules, simple and
compound IF rules, OTHERWISE, and selected action words. It preserves the
creator-facing visual grammar and rejects unimplemented features instead of
silently delegating to Ruby or pretending to have emitted correct bytecode.

compiler/native/first_bsharp_condition_router.bsharp carries the next native
BASIC# authored IF connector logic, but has not been compiled into BSBC.
tests/portable_bsharp_compiler.test.mjs contains future checks, not run now.

The live console adds a bounded Ruby-free BSIR execution sandbox, but not the accepted BSBC VM. See docs/self_hosting/BASIC_SHARP_LIVE_CONSOLE_v0_0_85.md.

Remaining: full selector/reference resolution, text values, movement,
CONTROLS, HOVER, CONTEXT, full parity, Ruby-free BSBC emitter, Ruby-free VM,
self-hosted compiler orchestration, and a validated production cutover.

Do not claim self-hosting or Ruby retirement. The accepted local v0.1.84
release remain protected; GitHub main contains subsequent unaccepted source-only development. The previous local
v0.1.85 installer failure and rollback are not accepted-release evidence.

## Subsequent source-only progress

The v0.0.85 candidate on `main` now includes number-threshold condition
interpretation, quoted text values and value changes, unique `the #Kind`
references, and canonical lowering of take/open/close/lock. The browser
sandbox has matching bounded semantics. The Ruby production compiler is
unchanged, and complete parity/BSBC execution remains outstanding. See
`docs/self_hosting/BASIC_SHARP_PORTABLE_CONDITION_VALUES_v0_0_85.md`.

## More source-only progress toward Ruby removal

The portable compiler/browser sandbox development lane now includes the
existing every #Kind action selector and queued (cause event interpretation.
This remains a bounded JavaScript BSIR interpreter, not binary BSBC execution,
and cannot replace the accepted production Ruby compiler. See
docs/self_hosting/BASIC_SHARP_PORTABLE_CAUSED_EVENTS_v0_0_85.md.

## Portable BSBC binary emitter (Profile 1 only, unaccepted)

A new Ruby-independent JavaScript encoder constructs the specified real
BSBC Profile 1 binary layout from resolved BSharp IR. It does not run or
replace the Ruby production path. Web Crypto SHA-256 supports the required
semantic fingerprint. Profiles 2-7 are intentionally blocked.
See docs/self_hosting/BASIC_SHARP_PORTABLE_BSBC_EMITTER_v0_0_85.md.

## Portable BSBC structural loader (source-only)

A separate JavaScript Profile 1 BSBC loader now checks the container,
indexes, instructions, selectors and block boundaries. The Live Console
inspector round-trips freshly emitted bytes through that loader. It is
not yet a VM and is not a verified replacement for the Ruby production
compiler/loader. See
docs/self_hosting/BASIC_SHARP_PORTABLE_BSBC_LOADER_v0_0_85.md.

## Independent BSBC Profile 1 VM candidate

The portable JavaScript path now contains a binary-input VM after its
Profile 1 emitter and loader. This is an actual independent execution
component, not a complete Ruby replacement. It remains untested and
does not implement Profiles 2-7. See
docs/self_hosting/BASIC_SHARP_PORTABLE_BSBC_VM_v0_0_85.md.
