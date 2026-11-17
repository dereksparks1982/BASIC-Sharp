# BASIC# Master Thread Handoff

## v0.0.85 candidate: independent BSBC Profile 1 bytecode VM

The portable source-only path now includes compiler/portable/bsharp_bsbc_vm.mjs.
Unlike the earlier browser interpreter, this VM receives BSBC binary bytes,
validates them through the strict Profile 1 loader, and executes the decoded
START, WHEN, IF and CODE instructions without recreating BSIR or invoking
Ruby. It supports states, relation and number initialization, state and number
changes, damage, carrying, unlocking, event-bound and every-Kind selection,
nearest-Kind matching, reactive IF rules and bounded FIFO caused events.

The Live Console source now exposes an explicit Execute BSBC button alongside
the earlier Execute IR button. Profile 1 programs follow independent
compiler -> BSBC encoder -> strict BSBC loader -> bytecode VM steps. Higher
profiles fail with an explanation instead of silently falling back to IR.
Reset, typed events, event buttons and world state use the selected engine.

Source-only regression definitions have been added for bytecode VM behavior
and rejection paths, but NO compilation or tests were run. The production
Ruby compiler/VM, accepted v0.0.84 release and language syntax are unchanged.
No new branches, downloads, SSH, local installers or GitHub Actions occurred.

Full details: docs/self_hosting/BASIC_SHARP_PORTABLE_BSBC_VM_v0_0_85.md.
Next: independent Profile 2-7 coverage and Ruby parity, then validation
when the owner authorizes testing.


## v0.0.85 source-only candidate: independent BSBC Profile 1 loader

The Ruby-independent browser toolchain now contains a Profile 1 binary
loader source. It accepts Uint8Array BSBC bytes and checks the established
32-byte header and 8-section directory, offsets/overlaps/alignment/zero
padding, UTF-8 string table uniqueness and first-use ordering, metadata
counts, Kind/Thing indexes, START instructions, WHEN and IF records,
CODE block boundaries, official selector contexts, opcodes, operand counts,
whole-number limits, and canonical ordering. It rejects Profiles 2-7
instead of attempting partial parsing.

The loader can compare the BSBC META fingerprint with a trusted expected
program fingerprint. The binary fingerprint field alone does not
authenticate bytes. The Live Console BSBC inspector now validates newly
emitted Profile 1 bytes through the independent loader before displaying
the header, sections and hex preview. **It never executes BSBC.**

New unexecuted malformed-binary regression definitions cover header,
sections, UTF-8, indexes, opcodes, selectors and block boundaries.
Technical details:
docs/self_hosting/BASIC_SHARP_PORTABLE_BSBC_LOADER_v0_0_85.md.

This remains unaccepted and untested source-only v0.0.85 development.
No compilation, automated tests, GitHub Actions, downloads, local
installers or new branches. The accepted v0.0.84 compiler and VM remain
unchanged. Next: a bytecode-driven browser VM and extended profile
contracts, followed by owner-authorized parity validation.


## v0.0.85 candidate: independent BSBC Profile 1 binary emission

The GitHub-only portable toolchain now includes a source implementation
of the official BSharp Bytecode Profile 1 emitter. It serializes the
established eight-section BSBC binary container, including the 32-byte
header, 16-byte section-directory entries, deterministic UTF-8 strings,
Kind ancestry, Thing definitions, START instructions, event patterns,
IF conditions, CODE block records and the semantic SHA-256 fingerprint.
This is a true binary encoder source path without invoking Ruby, not an
alternate JSON bytecode format. Profiles 2 through 7 fail closed until
their separate contracts are implemented.

The Live Console gained an Inspect BSBC panel for the generated header,
section directory and limited hex preview. It does not download any
files, execute the generated binary or replace the accepted BSBC VM.
Unexecuted regression definitions document the intended contract checks.

Changes: compiler/portable/bsharp_bsbc_encoder.mjs, browser console
and styling, tests/portable_bsharp_bsbc_encoder.test.mjs, documentation,
and the protected documentation hash inventory.

This is **unaccepted, uncompiled and untested** source-only v0.0.85 work
on GitHub main. The accepted v0.0.84 release, production Ruby compiler,
Ruby BSBC emitter/loader and BSharp VM are unchanged; no Actions or
local installer/downloads were used. See
docs/self_hosting/BASIC_SHARP_PORTABLE_BSBC_EMITTER_v0_0_85.md.

Next: independent BSBC structural loader and eventually bytecode-driven
browser execution, then extend profiles 2-7 and establish full parity
when the owner authorizes validation.


## v0.0.85 source-only candidate: mass action selection and caused-event chains

The portable compiler now recognizes the established action-only
"every #Kind" selector and emits a kind_set reference with deterministic
defined candidates. The browser sandbox applies supported actions to each
matching Thing and includes inherited Kind relationships. The compiler also
emits structured (cause events with named or event-bound "it" references.

The sandbox stages caused events FIFO after the initiating actions and IF
settlement, dispatches matching WHEN rules, and stops runaway event cycles at
64 follow-ups. No-match events are logged without inventing side effects.
The Live Console includes an alarm/guards example and additional unexecuted
regression definitions for set selection, caused events, and cyclic chains.

This is not real independent BSBC generation, full Ruby removal, or release
acceptance. The production compiler remains unchanged and no compilation,
test execution, GitHub Actions or local installer was performed. Details:
docs/self_hosting/BASIC_SHARP_PORTABLE_CAUSED_EVENTS_v0_0_85.md.


## v0.0.85 candidate: event interpretation and bound references (source only)

The GitHub Pages BASIC# console now includes typed event input and dynamic
event buttons. One WHEN PLAYER attacks a #creature rule can select different
named creatures, including inherited Kinds, with "it" bound to the Thing
selected by the event. Specific WHEN PLAYER attacks @goblin rules take
precedence over general Kind patterns; the chooser removes duplicate
shadowed entries. Unbound or ambiguous "it" references fail at source parse.

Changes cover the portable compiler, browser sandbox, Live Console, regression
definitions, documentation and protected inventory. The production Ruby
compiler and BSharp VM remain untouched. This is not complete selector parity
or self-hosting.

UNACCEPTED CANDIDATE. No compilation, test execution or GitHub Actions.
Next: remaining selectors and caused events, then independent BSBC execution.
Full details: docs/self_hosting/BASIC_SHARP_PORTABLE_EVENT_BINDINGS_v0_0_85.md.


## v0.0.85 candidate: portable condition and value interpretation (source-only)

The JavaScript source-to-BSIR compiler and browser sandbox now contain a
bounded implementation of more existing BASIC# meaning: the four whole-number
comparisons (**at least**, **more than**, **at most**, **less than**), quoted
text values with exact case and spacing, text and number assignment actions,
unique **the #Kind** resolution using Kind ancestry, and native-lowered
**take/open/close/lock** actions. Built-in Kind names and official action words
have been aligned more closely with the accepted CoreDictionary. The compiler
now selects meaning profiles 1, 2, 5, 6, and 7 according to actual features
instead of treating every numeric START fact as a Profile 5 feature.

The GitHub Pages console includes two examples demonstrating threshold rules
and text/Kind references, plus unexecuted regression definitions. Changes are
confined to the experimental portable compiler, browser sandbox, console,
and development docs. The existing Ruby production compiler, BSBC loader,
virtual machine, creator syntax, and accepted version/tag remain unchanged.

**This is not an accepted v0.0.85 release and not a complete Ruby replacement.**
No compilation, runtime testing, GitHub Actions or local installation was
performed. Missing work includes other selector forms, caused events,
movement/controls/hover/context, full parity, real independent BSBC emission,
and native VM execution in the browser. The next engineering boundary is
continuing semantic parity then implementing the independent BSBC path.
See docs/self_hosting/BASIC_SHARP_PORTABLE_CONDITION_VALUES_v0_0_85.md.


## v0.0.85 source-only README and root cleanup (not accepted)

At the owner's direction, the public `README.md` has been rewritten to describe BASIC# and link to the live console at `https://dereksparks1982.github.io/BASIC-Sharp/`. The complete historical `## Technical History` and its additional notes were moved into `docs/history/BASIC_SHARP_TECHNICAL_HISTORY.md`; the associated README history gate and tests now check the documented archive rather than requiring the entire technical history in the root README.

Seventy-six outdated `BUILD_HANDSHAKE_v0_0_03.md` through `BUILD_HANDSHAKE_v0_0_83.md` files are retired from the root working tree. The current accepted `BUILD_HANDSHAKE_v0_0_84.md` remains. Deleted historical content remains available through Git history. The sealed inventory has the removed handshake paths eliminated and changed-file byte counts and hashes refreshed. No compilation, automated tests, installer, or GitHub Actions were run; this does not represent v0.0.85 acceptance.


## v0.0.85 Live Console development candidate (source only, unaccepted)

GitHub Pages-ready root `index.html` now supplies a BASIC# code editor, Execute, reactive WHEN event controls, world-state inspector and event trace using `compiler/portable/bsharp_sandbox.mjs`. The browser runs a bounded interpreter of the experimental JS compiler's BSIR output. **This is not the accepted BSBC VM, not a complete Ruby compiler replacement, and has not been tested.** No downloads, compilation, GitHub Actions, or release acceptance occurred. Details: `docs/self_hosting/BASIC_SHARP_LIVE_CONSOLE_v0_0_85.md`.


The unaccepted GitHub source candidate is on **main**, after commit 29f39ef4ee1bc777e566ef7a5cc004cd58455392. The local accepted tag and version identity remain unchanged until full validation. Root Pages publishing settings were not verified. No new branches are authorized.


## Current state

- **Accepted release:** v0.0.84 Self-Hosting Milestone 2 Slice 11: Native Action Routing Integration.
- **Accepted release commit:** `14dd3e0f9134ed55cdb71bb69b8a2f3c555206c9`.
- **Accepted release tag:** `v0.0.84`.
- **Branch:** `main`.
- **Next build:** v0.0.85.
- **Release state:** v0.0.84 passed acceptance and closeout. The earlier rejected v0.0.84 package remains rejected evidence and is not a baseline.

## v0.0.84 purpose

v0.0.81 put BASIC# bytecode into active parser dispatch. v0.0.82 added active BASIC# semantic-family routing. v0.0.83 added active BASIC# symbol-resolution decisions. v0.0.84 preserves all three and adds a fourth authority boundary: `compiler/small_compiler_subset_native_action_routing.rb` executes `compiler/native/first_bsharp_action_router.bsbc`, and the independent semantic resolver must obey the BASIC# action-family decision or fail visibly.

Primary bounded path:

```text
BASIC# source
-> TokenizerReader
-> v0.0.81 BASIC# native parser dispatch
-> SmallCompilerSubsetParser
-> v0.0.82 BASIC# native semantic routing
-> v0.0.83 BASIC# native symbol resolution
-> v0.0.84 BASIC# native action routing
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> independent BSBC encoder
-> independent BSBC loader
-> independent BSharp VM
```

## Critical acceptance evidence

The v0.0.84 gate must prove all accepted official action words route through BASIC# BSBC, native action invocation counts are observable, wrong-family sabotage fails closed without Ruby family fallback, v0.0.81 parser dispatch/v0.0.82 semantic routing/v0.0.83 symbol resolution remain active upstream, production compiler constructors and Ruby Runtime remain unavailable on the primary proof path, independent source-to-BSIR/BSBC/execution preserves referee parity, and generation #1 / generation #2 action-router output is byte-identical. The accepted v0.0.84 release passed `tools/company_bible_audit.rb` after the rejected current-reference failure was repaired.

## Canonical Company Bible

`docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` is the single canonical BASIC# Company Bible and remains mandatory for build, validation, packaging, rollback, and closeout conduct. Canonical self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.

## Language and runtime boundary

No new creator-facing syntax and no Profile 8. Profiles 1 through 7, BSBC binary layout, Save meaning, ASK, input behavior, event ordering, and accepted game-making semantics remain protected. Ruby remains the bootstrap compiler and separate referee authority. Do not claim BASIC# is fully self-hosted or that Ruby is retired.

## Current validation floor

Accepted v0.0.84 validation floor:

```text
87 test files
692 runs
minimum 10,190 assertions
0 failures
0 errors
0 skips
75 required tools
386 sealed artifacts
14 protected artifacts
```

Complete normal and no-locale suites, every sealed required tool, deterministic sweep, release preflight, forensic overlay, whole-language gauntlet, and full-count Trial by Fire remain mandatory before `FINAL PASS`.

## Release workflow

1. Run the next self-contained versioned `.sh` installer against exact accepted v0.0.84.
2. Verify exact v0.0.84 HEAD/tag/branch/clean tree and all base-file hashes before mutation.
3. Materialize the embedded changed-file payload outside the project, verify hashes, and run pre-mutation forensic checks.
4. Capture rollback bytes, install only declared paths, and validate syntax/JSON/whitespace/package scope plus Company Bible/current-reference integrity.
5. Run native parser dispatch, native semantic routing, native symbol resolution, and native action routing proofs; complete normal/no-locale suites; every sealed required tool; stress lanes; deterministic sweep; preflight; forensic overlay; whole-language gauntlet; and full-count Trial by Fire.
6. Require one unmistakable `FINAL PASS`.
7. After FINAL PASS is confirmed: accepted snapshot first, then local commit/annotated tag, then GitHub SSH push and peeled-tag verification.

## Canonical contract reference ledger

```text
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_LOADER_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_VM_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PIPELINE_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_DRIVER_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ARTIFACT_ROUND_TRIP_v1.json
spec/self_hosting/BASIC_SHARP_FIRST_NATIVE_COMPILER_COMPONENT_v1.json
spec/self_hosting/BASIC_SHARP_NATIVE_PARSER_DISPATCH_INTEGRATION_v1.json
spec/self_hosting/BASIC_SHARP_NATIVE_SEMANTIC_ROUTING_INTEGRATION_v1.json
spec/self_hosting/BASIC_SHARP_NATIVE_ACTION_ROUTING_INTEGRATION_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_EXECUTION_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json
spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
```

## Continuation point

v0.0.84 Native Action Routing Integration is accepted and closed. The next build is v0.0.85. Profiles 1 through 7 remain protected; no Profile 8 is implied. Ruby remains bootstrap/referee authority until later boundaries are independently replaced and proven.
