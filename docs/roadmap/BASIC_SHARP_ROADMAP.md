# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> BSharp IR
-> Stable Meaning Profile 1  [ACCEPTED: v0.1.24]
-> one canonical Company Bible  [ACCEPTED: v0.1.25]
-> BSharp Bytecode Profiles 1-7 and BSharp VM  [ACCEPTED: v0.1.26-v0.1.39]
-> Trial by Fire complete repair and BSharp VM hardening  [ACCEPTED: v0.1.42]
-> v0.1.43 malformed self-hosting package  [REJECTED]
-> Self-Hosting Foundation  [ACCEPTED: v0.1.44]
-> v0.1.45 movement/input package  [REJECTED]
-> Plain-English Movement and Input Contract  [ACCEPTED: v0.1.46]
-> Tokenizer/Reader Contract  [ACCEPTED: v0.1.47]
-> tokenizer/reader implementation  [ACCEPTED: v0.1.48]
-> small compiler subset parser  [ACCEPTED: v0.1.49]
-> BSharp IR emitter  [ACCEPTED: v0.1.50]
-> IR golden parity harness  [ACCEPTED: v0.1.51]
-> plain-English error contract  [ACCEPTED: v0.1.52]
-> scene/block expansion  [ACCEPTED: v0.1.53]
-> symbol table contract  [ACCEPTED: v0.1.54]
-> BSBC emitter  [ACCEPTED: v0.1.55]
-> BSBC golden parity harness  [ACCEPTED: v0.1.56]
-> self-hosting fixture corpus  [ACCEPTED: v0.1.57]
-> small compiler subset runtime smoke  [ACCEPTED: v0.1.58]
-> Bootstrap Boundary Audit  [ACCEPTED: v0.1.59]
-> v0.1.60 Self-Hosting Milestone 1 candidate  [REJECTED: README error-contract reference missing; rollback verified]
-> Self-Hosting Milestone 1 Repair  [CURRENT CANDIDATE: v0.1.61]
-> expand the self-hosting subset only through separately approved, proof-backed lanes
-> staged Ruby retirement only after validation earns each boundary
-> BSharp web/app export contracts
-> BSharp native document app
-> game-engine bridge
-> independent BASIC# Semantic Oracle  [FUTURE CONCEPT]
-> staged BASIC# editor: Notepad -> Notepad++ -> Sublime-class
-> complete BASIC# IDE
-> BASIC#/BSharp-native browser only after web export and demand are real
```

## Current v0.1.61 lane

- Re-carry Self-Hosting Milestone 1 directly from accepted v0.1.59.
- Preserve Ruby as bootstrap compiler and referee.
- Repair the missing README reference to `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`.
- Keep the README Current Release Truth Gate.
- Preserve permanent evidence that v0.1.60 was rejected and restored to v0.1.59.
- Advance every active release surface and version-sensitive fixture to v0.1.61.
- Require the exact sealed installer to pass on a disposable clean v0.1.59 copy before delivery.
- Exclude full self-hosting claims, Ruby retirement, Profile 8, new syntax, production runtime changes, bytecode/BSBC renames, web/browser/editor work, and engine bridge work.

## v0.1.60 rejected candidate record

The v0.1.60 installer reached the Small Compiler Subset Error Contract after the complete 526-run / 8787-assertion suite and earlier self-hosting gates had passed. It failed because README.md omitted the required error-contract spec reference. The installer restored exact v0.1.59 and Derek verified the clean rollback. See `docs/audit/BASIC_SHARP_v0_1_60_REJECTED_BUILD_AUDIT.md`.

## Accepted v0.1.49 lane

- Add the first small compiler subset parser implementation.
- Parse accepted Head, Body, result marker, and official action word structure from TokenizerReader records.
- Compare subset parser records against the existing Ruby Parser referee.
- Keep the existing parser authority unchanged.
- Add executable parser tests and Trial-by-Fire inventory coverage.

## Accepted v0.1.48 lane

- Implement `compiler/tokenizer_reader.rb` as the first deterministic tokenizer/reader implementation.
- Keep the Ruby `Lexer` as referee and compare reader records exactly.
- Preserve current comment behavior and Head words.
- Emit deterministic token records for Heads, Body boundaries, result markers, action words, quoted text, and ordinary Body lines.
- Keep the existing parser authority unchanged.

## Accepted v0.1.47 lane

- Define the tokenizer/reader contract for the self-hosting runway.
- Freeze deterministic reader records: one-based line number, comment-stripped raw line, and trimmed text.
- Preserve current comment behavior and current Head words.
- Define future token-record shape without implementing a replacement tokenizer.
- Add executable contract, tests, and Trial-by-Fire inventory coverage.
- Record the BASIC# universal-standard and AI-tooling doctrine.

## Accepted v0.1.46 lane

- Define the input-device meaning layer for keyboard, mouse/keyboard, PS5, Xbox, and generic gamepad events.
- Preserve the existing creator-facing `CONTROLS for PLAYER` language.
- Add an executable contract and tests proving device events map to existing top-down and platform movement host commands.
- Repair the rejected v0.1.45 Xbox jump timing assertion without expanding scope.
- Exclude remapping UI, platform drivers, engine bridge, graphics, haptics, camera controls, Profile 8, and Ruby replacement.

## Accepted v0.1.44 lane

- Preserve v0.1.43 as rejected and do not reuse its number.
- Add a permanent rejected-package audit and installer NUL-byte package rule.
- Define BSharp Compiler Subset 0.
- Add self-hosting foundation documentation, JSON spec, validator tool, and focused test.
- Preserve Ruby as bootstrap compiler and reference authority.
- Preserve all accepted Profiles 1-7 meaning and Trial-by-Fire gates.
- Regenerate all current version-bearing runtime fixtures together.
- Add no creator syntax, Profile 8, runtime semantics, engine bridge, document app, or Ruby replacement.

## Future web/app/company lane

BASIC# / BSharp aims to become a universal creator-facing standard for websites, apps, games, tools, automation, and business systems.

The staged web strategy is compatibility first:

```text
BASIC# source
-> HTML for structure
-> CSS for style
-> JavaScript for browser behavior
-> WebAssembly or native targets later
-> BASIC#/BSharp-native browser only much later, after proven demand
```

The future sponsorship strategy is proof first. A future sponsor packet may target AI tooling support, API credits, founder attention, or partnership discussion only after the language has a clear demo, validation proof, and roadmap evidence.

## Continuation after v0.1.61

1. Install and complete owner-side native validation from exact accepted commit `936c01340c518af655fce21f11d9b99f1863f3f1` and tag `v0.1.49`.
2. Commit and tag v0.1.61 immediately after every gate passes, then capture the accepted full-project snapshot.
3. Next focused build should begin the small compiler subset BSBC bytecode emission lane only after subset-emitted BSharp IR remains stable under Ruby referee.
4. Ruby remains the referee until BASIC# compiler pieces reproduce approved output deterministically.
5. Web/app export and BSharp native documents remain valuable, but they wait until the self-hosting runway is credible.

## Shelved commercial lane

Private/proprietary distribution remains under consideration, but licensing and monetization are deferred. Future Creator pricing must include a reasonable monthly option, annual billing may only be an optional discount, and an eligible paid local version must remain usable permanently under the eventual qualifying terms.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- BASIC# is the language name; BSharp is used where `#` is unsafe.
- No new `DK`-prefixed name without Derek's explicit approval.
- Difficult machinery belongs beneath understandable creator-facing language.
- Compatibility before conquest; validation before replacement; performance before hype; creator clarity before programmer tradition.
- The BSharp VM is preferred; Ruby remains temporary bootstrap support and reference verification.
- Self-hosting is earned through staged contracts and parity, not declared early.
- Every build requires an exact accepted base, approval, validation, changed-files-only package, handshake, commit, and tag.
- The complete Company Bible is `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`.
- The active self-hosting contract is `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
- The active tokenizer/reader contract is `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`.
- The active small compiler subset parser contract is `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json`.
- The active small compiler subset IR emitter contract is `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`.
- The active input-device contract is `spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json`.

## v0.1.61 IR emitter lane guardrail

`spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json` governs the small compiler subset BSharp IR emitter. Ruby remains the production parser, resolver, and compiler authority.


## v0.1.61 IR golden parity lane guardrail

The v0.1.61 lane is governed by `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json`, `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v0_1_52.md`, and `compiler/small_compiler_subset_ir_parity_harness.rb`. It locks golden BSharp IR digests for sealed small compiler subset fixtures under the Ruby Parser plus SemanticResolver referee. It must not become the production compiler path and must not add Profile 8, new syntax, runtime changes, BSharp Bytecode changes, web export, browser work, engine bridge, or Ruby retirement.

## Continuation after v0.1.61

The next likely self-hosting build is the small compiler subset emits BSBC bytecode lane, still under Ruby referee control.


## v0.1.61 error contract lane guardrail

The v0.1.61 lane is governed by `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`, `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v0_1_52.md`, and `compiler/small_compiler_subset_error_contract.rb`. It locks stable, plain-English error IDs and messages for invalid small compiler subset examples under the Ruby referee. It must not become the production compiler path and must not add Profile 8, new syntax, runtime changes, BSharp Bytecode changes, web export, browser work, engine bridge, or Ruby retirement.

## Continuation after v0.1.61

The next likely self-hosting build is controlled subset expansion or the small compiler subset emits BSBC bytecode lane, still under Ruby referee control.


## Five Point Paradigm decision filter

Every future roadmap item should be checked against the BASIC# Five Point Paradigm:

1. Huge Human Problem
2. Radical Human Bridge
3. Breakthrough Machine
4. Proof Under Fire
5. Creator Ownership

The centre statement is: turn human intent into real software behaviour.

A roadmap item can be deferred when it is exciting but does not yet strengthen the current self-hosting bridge, validation proof, creator clarity, compatibility path, or ownership model.

## Documentation map

The documentation front door is `docs/BASIC_SHARP_DOCUMENTATION_MAP.md`. It gives the reading order for the Company Bible, handoff, roadmap, self-hosting contracts, validation records, build history, and runtime/bytecode contracts.


## v0.1.61 scene/block expansion lane guardrail

The v0.1.61 lane is governed by `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json`, `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v0_1_53.md`, and `compiler/small_compiler_subset_scene_block_expansion.rb`. It expands the sealed subset to larger ordered scene/block fixtures under Ruby Parser plus SemanticResolver referee.

It must not become the production compiler path and must not add Profile 8, new syntax, runtime changes, BSharp Bytecode changes, web export, browser work, engine bridge, or Ruby retirement.

## Continuation after v0.1.61

After v0.1.61 is accepted, the next likely self-hosting bridge build is v0.1.61 Subset Symbol Table Contract, unless validation shows a narrower parser/IR repair is needed first.


Symbol table contract spec: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json`.


ByteTide decision record: the name was considered as a creator-facing metaphor for bytecode flow, then passed on for now. Official system terms remain bytecode and BSBC.

Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v0_1_54.md`.


### v0.1.61 small compiler subset BSBC emission

BASIC# v0.1.61 adds the first small compiler subset lane that emits real BSBC bytecode under Ruby referee control. It proves source -> BSharp IR -> BSBC bytes -> bytecode loader for sealed fixtures without replacing Ruby and without claiming BASIC# is self-hosted.

Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json`.
Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v0_1_55.md`.


### v0.1.61 small compiler subset BSBC golden parity

BASIC# v0.1.61 adds the BSBC Golden Parity Harness under Ruby referee control. It locks approved subset source -> BSharp IR -> BSBC bytes -> bytecode loader summaries against sealed golden expectations without replacing Ruby and without claiming BASIC# is self-hosted.

Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json`.
Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v0_1_56.md`.


## v0.1.61 Self-Hosting Fixture Corpus

- Spec: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json`
- Doc: `docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v0_1_57.md`
- Implementation: `compiler/self_hosting_fixture_corpus.rb`
- Tool: `tools/self_hosting_fixture_corpus.rb`
- Test: `tests/test_self_hosting_fixture_corpus.rb`
- DKLab is retained as the internal workspace and lab name in homage to Demon Killer. Elderred Softworks LLC remains the official company identity.
## v0.1.61 Compiler Subset Runtime Smoke

Status: implemented in this build. Selected small compiler subset fixtures now reach the verifying runtime, run smoke events, snapshot, and save under Ruby referee control.


## v0.1.61 Bootstrap Boundary Audit

Status: implemented in this build. The audit records Ruby referee authority, BASIC# subset participation, runtime smoke evidence, protected production runtime boundaries, and the guarded path into v0.1.61 Self-Hosting Milestone 1.

## v0.1.61 Self-Hosting Milestone 1

Status: implemented in this build. BSharp Compiler Subset 0 now has sealed reader, parser, IR, BSBC, fixture corpus, parity, runtime smoke, bootstrap boundary, README truth, and milestone gates under Ruby referee control. This is not full self-hosting and does not retire Ruby.
