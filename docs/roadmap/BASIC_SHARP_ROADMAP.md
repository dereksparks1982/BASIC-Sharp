# BASIC# Roadmap

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


## Current accepted base

```text
v0.0.84: Self-Hosting Milestone 2 Slice 11 - Native Action Routing Integration
accepted release commit 14dd3e0f9134ed55cdb71bb69b8a2f3c555206c9
tag v0.0.84
```

v0.0.84 is the accepted release. It preserves v0.0.81 BASIC#-authored parser dispatch, v0.0.82 BASIC#-authored semantic routing, and v0.0.83 BASIC#-authored symbol resolution, then adds active BASIC#-authored action-routing decisions. Ruby remains the bootstrap compiler and separate referee authority.

The accepted path is:

```text
BASIC# source
-> TokenizerReader
-> BASIC# native parser dispatch [v0.0.81]
-> SmallCompilerSubsetParser
-> BASIC# native semantic routing [v0.0.82]
-> BASIC# native symbol resolution [v0.0.83]
-> BASIC# native action routing [v0.0.84]
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> independent BSBC encoder
-> independent BSBC loader
-> independent BSharp VM
```

## Canonical Company Bible

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

This is the single canonical Company Bible for BASIC# conduct, release, validation, rollback, packaging, GitHub closeout, and Elderedd migration rules. Its header version must match `BasicSharp::VERSION`.

## Release closeout order

Every accepted BASIC# build follows the same release path:

1. Run the self-contained versioned `.sh` installer supplied with the download; use a changed-files ZIP only when that packaging path is explicitly requested.
2. Run installer validation including the complete normal test suite, complete no-locale suite, all sealed tools, required stress lanes, deterministic sweep, forensic/preflight gates, whole-language gauntlet, and full Trial by Fire counts.
3. Preserve `PHASE START` / `PHASE PASS`, visible Minitest dot progress, run/assertion counts, and one unmistakable `FINAL PASS`.
4. Create the accepted snapshot after final PASS and before local Git closeout.
5. Commit and create the annotated tag locally only after acceptance proof.
6. Push through the proven SSH/no-password GitHub path and verify the peeled annotated tag.
7. Begin the next build only after the current build is fully closed.

## Elderedd migration

Priority: active.

- Elderedd Softworks LLC is the parent company identity.
- Elderedd Laboratory is the active lab identity.
- ELDL is internal shorthand only.
- BCS means BSharp Creator Services and remains future service-layer naming only.
- DKLab is retired as an active BASIC# identity.
- DKLab may remain as compatibility, rollback, migration, and archival history.
- Canonical future path: `~/Elderedd/Projects/BASIC#`.
- Legacy compatibility path: `~/DKLab/Projects/BASIC#`.
- Do not remove the DKLab compatibility bridge until a later accepted build proves no active BASIC# workflow depends on it.

## Self-hosting runway

Current truthful claim:

```text
v0.0.80 proved the first bounded compiler-domain component authored in BASIC#.
v0.0.81 made BASIC# BSBC control bounded native parser dispatch.
v0.0.82 made BASIC# BSBC control bounded semantic routing.
v0.0.83 added bounded BASIC#-authored symbol-resolution decisions.
v0.0.84 added active BASIC#-authored action routing.
Ruby remains the bootstrap compiler and separate referee authority.
BASIC# is not fully self-hosted.
```

The v0.0.72 Milestone 2 proposal is now implemented through semantic resolver independence, independent BSBC encoding, independent loading, independent BSharp VM execution, integrated pipeline independence, real artifact round trip, the first BASIC#-authored compiler decision kernel, and active native parser dispatch integration.

## Game-making runway

v0.0.73 established direct creator actions including open, close, lock, and take. v0.0.81 preserves those game-making semantics unchanged while the compiler machinery underneath them becomes more self-directed.

## Next direction for v0.0.85

1. Continue transferring real compiler authority from Ruby into BASIC# until the production compiler chain no longer requires Ruby decisions.
2. Next likely bounded targets are condition interpretation, event interpretation, selector/reference resolution, semantic transformation, IR construction/emission, source reading/token processing, and compiler orchestration.
3. Keep Ruby as separate bootstrap/referee authority until each replacement boundary earns removal through locked parity and sabotage validation.
4. Do not contaminate creator-facing BASIC# syntax merely to imitate conventional programming languages.
5. Repair any proven validation or release defect inside the current candidate before beginning a later version.

No new governance/audit system is planned unless a demonstrated failure requires it.

## Public proof-application ladder

1. Calculator
2. Text Adventure / choose-your-own-adventure
3. Pong
4. Breakout
5. Solitaire
6. Larger 2D Game
7. Media Player

These are future proof programs, not permission to interrupt the active compiler/runtime lane. Solitaire remains intended as a free noncommercial BASIC# showcase while the final decision authority's Demon Killer card/deck artwork remains separately protected.

## Release-hardening runway

```text
tools/native_parser_dispatch_integration.rb
tools/native_semantic_routing_integration.rb
tools/native_symbol_resolution_integration.rb
tools/deterministic_fixture_hash_sweep.rb
tools/release_package_preflight.rb
tools/release_forensic_overlay.rb
tools/trial_by_fire_inventory.rb
tools/trial_by_fire_gauntlet.rb
```

## Future BASIC# Graphics Format runway

Recorded for later only:

```text
BSG = BASIC# Graphics system
BGF = BASIC# Graphics Format
Extension = .bgf
```

Compatibility and functional language progress remain ahead of BGF implementation.

## Canonical self-hosting specification runway

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
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json
spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_2_PROPOSAL_v0_0_72.md
```
