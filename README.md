# BASIC#

## Intro

BASIC# is a scripting language made for non-programmers, by non-programmers. It favors readable intent, full words, plain-English structure, and creator clarity over terse programmer-first syntax.

The current version is **v0.0.84**. The compiler is still bootstrapped and independently checked with Ruby while BASIC# progressively takes over bounded compiler responsibilities through its own BSharp IR, BSharp Bytecode (`.bsbc`), and BSharp VM path. BASIC# is not yet fully self-hosted, and no creator-facing syntax change is implied by the current self-hosting work.

Source files use `.bsharp`. The intermediate representation is BSharp IR / BSIR. Bytecode is BSharp Bytecode / BSBC. Runtime inspection uses BSharp ASK, saves use BSharp Save, and the preferred runtime is the BSharp VM.

The canonical project rules are recorded in `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`.

## Version Technical History

### v0.0.84 — Native Action Routing Integration
Moved another bounded compiler decision into BASIC# by routing accepted official action words through the BASIC#-authored native action-routing component. Existing native parser dispatch, semantic routing, and symbol resolution remain upstream. Wrong-family decisions fail closed rather than silently falling back to Ruby.

### v0.0.83 — Native Symbol Resolution Integration
Added BASIC#-authored bounded symbol-resolution decisions for Kind, Thing, PLAYER, actions, values, duplicates, unknowns, and Kind links while preserving the earlier native parser and semantic-routing stages.

### v0.0.82 — Native Semantic Routing Integration
Moved bounded semantic-family routing into BASIC# bytecode while retaining Ruby as bootstrap compiler and separate referee authority.

### v0.0.81 — Native Parser Dispatch Integration
Put BASIC# bytecode into active bounded parser dispatch and required observable native invocation while preserving the existing compiler meaning and creator-facing syntax.

### v0.0.80 — First BASIC#-Authored Compiler Component
Established the first bounded compiler-domain component authored in BASIC#, with checked-in `.bsharp`, `.bsbc`, and readable disassembly evidence under Ruby referee control.

### v0.0.79 — Independent Compiler Driver and BSBC Artifact Round Trip
Added an independent compiler driver and proved a real BSBC artifact round trip across the self-hosting subset.

### v0.0.78 — Integrated Independent Compiler Pipeline
Connected the independent subset reader, parser, resolver, emitter, loader, and VM into an integrated compiler pipeline.

### v0.0.77 — BSharp VM Execution Independence
Gave the self-hosting subset an independent BSharp VM execution path while keeping the production runtime as a separate referee.

### v0.0.76 — BSBC Loader Independence
Added an independent BSBC loader boundary for the self-hosting compiler subset.

### v0.0.75 — BSBC Emitter Independence
Added independent BSBC byte generation for the self-hosting subset.

### v0.0.74 — Semantic Resolver Independence
Added an independent semantic resolver for the self-hosting compiler subset.

### v0.0.73 — Plain-English Object Interaction Actions
Expanded creator-facing game actions with direct plain-English object interactions including open, close, lock, and take.

### v0.0.72 — Self-Hosting Milestone 2 Proposal and Roadmap Truth Repair
Recorded the next self-hosting direction and repaired roadmap/release truth. It also records the release closeout rule: full validation must prove a build before acceptance; the accepted snapshot comes before local Git commit/tag; GitHub closeout comes after local acceptance; and the proven project transcript must be followed instead of guessing at SSH keys, HTTPS password prompts, or giant token blocks.

### v0.0.71 — No-Locale CLI Capture Encoding Repair
Repaired CLI capture behavior under minimal/no-locale environments and hardened encoding behavior.

### v0.0.70 — Whole-Language Test Gauntlet Expansion
Expanded the whole-language gauntlet and strengthened full native validation before release acceptance.

### v0.0.69 — Gauntlet Gear-Up and Release Forensics
Added release-forensic preparation and stronger validation gates ahead of the expanded whole-language gauntlet.

### v0.0.68 — Plain-English Input Mapping
Added creator-facing plain-English input mapping.

### v0.0.67 — Plain-English 2D and 3D Movement Intent
Added plain-English movement intent covering both 2D and 3D movement concepts.

### v0.0.66 — Self-Hosting Execution and Runtime Behavior Expansion
Expanded self-hosting execution coverage and runtime behavior validation.

### v0.0.65 — Self-Hosting Execution Corpus Expansion and BGF Roadmap
Expanded the self-hosting execution corpus and recorded the future BASIC# Graphics Format roadmap.

### v0.0.64 — Self-Hosting Execution Expansion and Release Gate Hardening
Expanded execution coverage and tightened release acceptance gates.

### v0.0.63 — UTF-8 Hardening, Path Proof, and BSBC Execution Parity
Hardened UTF-8 source reading, proved the active/compatibility project paths, and strengthened BSBC execution parity.

### v0.0.62 — Project Identity and Compatibility Bridge
Established the current project identity while retaining the legacy workspace path only as a compatibility, rollback, migration, and archival bridge.

### v0.0.61 — Self-Hosting Milestone 1 Repair
Repaired the first self-hosting milestone record and its acceptance truth.

### v0.0.60 — No Accepted Release Record Found
The current repository history does not contain an accepted release record for this numbered step. The number is retained so the version history remains complete.

### v0.0.59 — Bootstrap Boundary Audit
Added a formal bootstrap-boundary audit to distinguish self-hosted subset authority from Ruby bootstrap/referee authority.

### v0.0.58 — Compiler Subset Runtime Smoke
Added runtime smoke validation for the compiler subset.

### v0.0.57 — Self-Hosting Fixture Corpus
Added a sealed fixture corpus for self-hosting validation.

### v0.0.56 — BSBC Golden Parity Harness
Added a golden parity harness for BSharp Bytecode output.

### v0.0.55 — Compiler Subset Emits BSBC Bytecode
Extended the compiler subset so it could emit BSBC bytecode.

### v0.0.54 — Subset Symbol Table Contract
Defined and validated the small compiler subset symbol-table contract.

### v0.0.53 — Subset Scene Block Expansion
Expanded scene-block handling in the small compiler subset.

### v0.0.52 — Small Compiler Subset Error Contract
Defined the error contract for the self-hosting compiler subset.

### v0.0.51 — IR Golden Parity Harness
Added a golden parity harness for BSharp IR output.

### v0.0.50 — Small Compiler Subset IR Emitter
Added a dedicated IR emitter for the small compiler subset.

### v0.0.49 — Small Compiler Subset Parser
Added the parser for the bounded self-hosting compiler subset.

### v0.0.48 — Tokenizer Reader Implementation
Implemented the tokenizer/reader component defined by the prior contract.

### v0.0.47 — Tokenizer Reader Contract
Defined the tokenizer/reader boundary for the self-hosting runway.

### v0.0.46 — Plain-English Movement and Input Contract
Defined the creator-facing contract for plain-English movement and input.

### v0.0.45 — No Accepted Release Record Found
The current repository history does not contain an accepted release record for this numbered step. The number is retained so the version history remains complete.

### v0.0.44 — Self-Hosting Foundation and Rejected-Package Repair Record
Established the self-hosting foundation and preserved the repair record for an earlier rejected package rather than treating failed work as an accepted baseline.

### v0.0.43 — No Accepted Release Record Found
The current repository history does not contain an accepted release record for this numbered step. The number is retained so the version history remains complete.

### v0.0.42 — Trial by Fire Complete Fixture Repair
Completed a fixture-family repair uncovered by Trial by Fire validation.

### v0.0.41 — No Accepted Release Record Found
The current repository history does not contain an accepted release record for this numbered step. The number is retained so the version history remains complete.

### v0.0.40 — No Accepted Release Record Found
The current repository history does not contain an accepted release record for this numbered step. The number is retained so the version history remains complete.

### v0.0.39 — Plain-English OTHERWISE Branches and BSharp Profile 7
Added creator-facing `OTHERWISE` branching and BSharp meaning/bytecode Profile 7.

### v0.0.38 — Plain-English Compound IF Conditions and BSharp Profile 6
Added compound plain-English IF conditions and BSharp Profile 6.

### v0.0.37 — Plain-English Number Changes, Comparisons, and BSharp Profile 5
Added number-change and comparison behavior with BSharp Profile 5.

### v0.0.36 — Plain-English Platform Movement and BSharp Profile 4
Added platform-style movement behavior and BSharp Profile 4.

### v0.0.35 — Profile 3 and Direct BSBC Validation Repair
Completed Profile 3 work and repaired direct BSBC validation.

### v0.0.34 — No Accepted Release Record Found
The current repository history does not contain an accepted release record for this numbered step. The number is retained so the version history remains complete.

### v0.0.33 — No Accepted Release Record Found
The current repository history does not contain an accepted release record for this numbered step. The number is retained so the version history remains complete.

### v0.0.32 — Meaning Profile 2 Text Values and BSharp Bytecode Profile 2
Added creator-facing text values and the second meaning/bytecode profile.

### v0.0.31 — BSharp VM Preferred Runtime Transition and Shadow Parity
Moved the BSharp VM into the preferred-runtime position while retaining shadow parity verification against the reference runtime.

### v0.0.30 — VM Parity, BSharp Save, BSharp ASK, and Hardening
Strengthened VM parity and consolidated BSharp Save, BSharp ASK, and runtime hardening.

### v0.0.29 — First BSharp Virtual Machine and Profile 1 Execution
Introduced the first BSharp VM and executed the first stable meaning/bytecode profile.

### v0.0.28 — BSharp Bytecode Loader and Complete Structural Validation
Added the BSBC loader and complete structural bytecode validation.

### v0.0.27 — BSharp Bytecode Emitter and Deterministic Disassembly
Added deterministic BSBC emission and readable deterministic disassembly.

### v0.0.26 — BSharp Bytecode Architecture and Instruction Contract
Defined the BSharp Bytecode architecture and instruction contract.

### v0.0.25 — Canonical Company Bible Consolidation
Consolidated project governance into the single canonical Company Bible.

### v0.0.24 — Stable Meaning Specification and Conformance Profile 1
Defined the first stable meaning specification and conformance profile.

### v0.0.23 — ASK Introspection and Deterministic Answers
Added BSharp ASK-style runtime introspection with deterministic answers.

### v0.0.22 — BSharp Save Files and Deterministic World Restore
Added BSharp Save files and deterministic world restoration.

### v0.0.21 — Follow-Up Events and Deterministic Event Order
Added follow-up events and deterministic event ordering.

### v0.0.20 — BSharp IR Identity Migration
Moved the intermediate representation to the BSharp IR / BSIR identity.

### v0.0.19 — Whole-Number Values and Damage Amounts
Added whole-number values and numeric damage amounts.

### v0.0.18 — Multiple Selected Things and Deterministic Set Actions
Added deterministic actions over multiple selected things.

### v0.0.17 — Reactive IF Rules and Loop Protection
Added reactive IF behavior with loop protection.

### v0.0.16 — Kind-Family Stress and Hardening
Stress-tested and hardened Kind-family behavior.

### v0.0.15 — Inherited Kind Matching
Added inherited Kind matching.

### v0.0.14 — Technical Identity Migration and Company Bible Integration
Migrated the language from its earlier DKScript technical identity into BASIC# / BSharp terminology and integrated the Company Bible into active project governance.

### v0.0.13 — Focused Runtime Stress Test and Contract Hardening
Ran focused runtime stress testing and hardened the early runtime contract.

### v0.0.12 — Plain-Language Runtime Trace
Added a creator-readable plain-language runtime trace.

### v0.0.11 — BASIC Sharp Language Foundation and Historical BASIC Research
Established the BASIC Sharp language direction and recorded research into historical BASIC-family design ideas.

### v0.0.10 — No Accepted Release Record Found
The current repository history does not contain an accepted release record for this numbered step. The number is retained so the version history remains complete.

### v0.0.09 — First Runtime Execution
Added the first runtime execution path for the early language implementation.

### v0.0.08 — Body Structure and User Kinds
Added body structure and user-defined Kind support.

### v0.0.07 — Diagnostic Deduping and Cascade Cleanup
Reduced duplicate diagnostics and cleaned up cascading error output.

### v0.0.06 — Natural-Language Error Samples and Ambiguity Tests
Added natural-language diagnostic samples and ambiguity-focused tests.

### v0.0.05 — Semantic Diagnostics and IR File Output
Added semantic diagnostics and IR file output.

### v0.0.04 — Semantic Resolver and IR Output
Added the first semantic resolver and structured intermediate-representation output.

### v0.0.03 — Ruby Bootstrap Compiler Prototype
Created the first standalone bootstrap compiler prototype with lexer, parser, AST structures, dictionary support, diagnostics, sample source, and parser validation.

### v0.0.02 — Decision Ledger and Core Dictionary
The earliest compiler record identifies this as the documentation-only decision-ledger and core-dictionary base required by the first bootstrap compiler prototype.

### v0.0.01 — Initial Project Stage
The current repository does not contain an earlier accepted release commit for this numbered step. It is retained as the first version number in the complete history rather than being omitted or assigned invented technical changes.

## Additional Notes

The version technical history intentionally runs in full from **v0.0.84 through v0.0.01**, newest to oldest. Numbers without a surviving accepted release record are kept in sequence and identified plainly instead of being skipped or given invented implementation details.

## License / Legal

Copyright © 2026. All rights reserved.

BASIC# is publicly viewable for inspection and development review, but it is **not currently released under an open-source license**. Except for rights necessarily granted under GitHub's platform terms for hosting, viewing, and use of repository features, no permission is granted to copy, modify, distribute, sublicense, sell, commercially exploit, incorporate the project into another product, or distribute derivative works without prior written permission from the copyright holder or a separate written license.

Public availability of this repository does not place BASIC# in the public domain and does not waive copyright or other intellectual-property rights.

No trademark, branding, or endorsement rights are granted in the names **BASIC#**, **BSharp**, **BSharp Bytecode**, **BSharp VM**, or associated project names, logos, or identifiers.

Future releases may use different commercial, community, dual-license, or open-source terms. Those terms will apply only where expressly stated and will not retroactively alter the rights reserved here.

See the root `LICENSE` file for the current legal notice.
