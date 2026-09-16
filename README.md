# BASIC# Ruby Bootstrap Compiler

BASIC# is a scripting language made for non-programmers, by non-programmers. The current work is pushing the compiler toward self-hosting without changing creator-facing syntax or pretending Ruby has already been retired.

## Current release state

**Accepted base:** v0.1.83, Native Symbol Resolution Integration  
**Current candidate:** v0.1.84, Self-Hosting Milestone 2 Slice 11: Native Action Routing Integration  
**Candidate status:** **NOT ACCEPTED YET**

v0.1.84 keeps the v0.1.81 native parser-dispatch boundary, v0.1.82 native semantic-routing boundary, and v0.1.83 native symbol-resolution boundary active, then moves accepted official action-word family routing into a BASIC#-authored BSBC component.

The candidate routes accepted official action words into the existing damage, change, number-change, cause, object-interaction, or generic resolver families through:

```text
compiler/small_compiler_subset_native_action_routing.rb
compiler/native/first_bsharp_action_router.bsharp
compiler/native/first_bsharp_action_router.bsbc
compiler/native/first_bsharp_action_router.bsbc.txt
```

Contradictory native action routing must fail closed instead of falling back to a hidden Ruby verb-family answer table. Ruby remains the bootstrap compiler and separate referee authority while BASIC# takes over bounded compiler decisions one slice at a time.

## v0.1.84 validation status

The first v0.1.84 candidate run proved the compiler work itself through the native authority chain and full automated suites:

```text
Native Parser Dispatch Integration: PASS
Native Semantic Routing Integration: PASS
Native Symbol Resolution Integration: PASS
Native Action Routing Integration: PASS
Normal suite: 692 runs, 10,190 assertions, 0 failures, 0 errors, 0 skips
No-locale suite: 692 runs, 10,190 assertions, 0 failures, 0 errors, 0 skips
```

The candidate then failed the Company Bible audit because the active roadmap did not contain the canonical Company Bible path required by the governance audit:

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

The installer rolled the project back to the accepted v0.1.83 bytes. That failure did **not** create a new version. The repair remains **v0.1.84** until the same candidate reaches `FINAL PASS` and is explicitly accepted.

## Version discipline

A failed candidate keeps its assigned numeric version until it is fixed and accepted or explicitly abandoned. There is no v0.1.85 merely because a v0.1.84 validation attempt failed.

```text
Accepted version: 0.1.83
Candidate version: 0.1.84
Version under validation: 0.1.84
```

## v0.1.84 active gates

```text
spec/self_hosting/BASIC_SHARP_NATIVE_ACTION_ROUTING_INTEGRATION_v1.json
compiler/small_compiler_subset_native_action_routing.rb
compiler/native/first_bsharp_action_router.bsharp
compiler/native/first_bsharp_action_router.bsbc
compiler/native/first_bsharp_action_router.bsbc.txt
docs/self_hosting/BASIC_SHARP_NATIVE_ACTION_ROUTING_INTEGRATION_v0_1_84.md
tools/native_action_routing_integration.rb
tests/test_native_action_routing_integration.rb
```

The previous self-hosting boundaries remain active and protected:

```text
v0.1.81  Native Parser Dispatch Integration
v0.1.82  Native Semantic Routing Integration
v0.1.83  Native Symbol Resolution Integration
v0.1.84  Native Action Routing Integration candidate
```

## Self-hosting status

BASIC# is **not fully self-hosted yet**. The project currently uses a Ruby bootstrap/referee layer while BASIC#-authored components increasingly own real compiler decisions. The goal is to remove Ruby only after BASIC# can reproduce the required compiler work and validation proves the replacement is correct.

No Profile 8 is approved. Profiles 1 through 7 remain sealed. v0.1.84 adds no new creator-facing syntax, changes no BSBC layout, and does not change accepted runtime meaning.

## Current runtime path

```text
.bsharp source
    -> Ruby bootstrap plumbing / referee
    -> BASIC#-authored bounded compiler authority where integrated
    -> BSharp IR / BSIR
    -> BSharp Bytecode / BSBC
    -> validated BSharp VM
```

## Main validation commands

```bash
ruby tools/native_parser_dispatch_integration.rb
ruby tools/native_semantic_routing_integration.rb
ruby tools/native_symbol_resolution_integration.rb
ruby tools/native_action_routing_integration.rb
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
ruby tools/company_bible_audit.rb
ruby tools/release_forensic_overlay.rb
ruby tools/release_package_preflight.rb
ruby tools/deterministic_fixture_hash_sweep.rb
ruby tools/trial_by_fire_gauntlet.rb
```

## Canonical records

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md
docs/roadmap/BASIC_SHARP_ROADMAP.md
docs/BASIC_SHARP_DOCUMENTATION_MAP.md
spec/release/BASIC_SHARP_RELEASE_FORENSIC_OVERLAY_v1.json
spec/release/BASIC_SHARP_RELEASE_PACKAGE_PREFLIGHT_v1.json
spec/release/BASIC_SHARP_DETERMINISTIC_FIXTURE_HASH_SWEEP_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json
```

## Project identity

```text
Language: BASIC#
Pronunciation: Basic Sharp
Safe technical form: BSharp / basic_sharp
Source: .bsharp
Intermediate representation: BSharp IR / BSIR
World save: BSharp Save
Inspection: BSharp ASK
Bytecode: BSharp Bytecode / BSBC / .bsbc
Preferred runtime: BSharp Virtual Machine / BSharp VM
Reference oracle: BasicSharp::Runtime
Meaning profiles: bsharp.meaning.v1 through bsharp.meaning.v7
Bytecode profiles: bsharp.bytecode.v1 through bsharp.bytecode.v7
Parent company: Elderedd Softworks LLC
Laboratory: Elderedd Laboratory
Internal shorthand: ELDL
Service layer: BCS, BSharp Creator Services
DKLab status: compatibility, rollback, migration, and archival history only
Canonical future path: ~/Elderedd/Projects/BASIC#
Legacy compatibility path: ~/DKLab/Projects/BASIC#
```

## Current repair target

Repair v0.1.84 itself. The immediate governance defect is the missing canonical Company Bible path in the active roadmap/current-reference surface. After that repair, v0.1.84 must rerun the full native validation, complete normal and no-locale suites, sealed tool lane, Trial by Fire, and release gates. Only a complete `FINAL PASS` makes v0.1.84 eligible for acceptance.

## Universal standard doctrine

```text
Compatibility before conquest.
Validation before replacement.
Performance before hype.
Creator clarity before programmer tradition.
```

## v0.1.84 release note

v0.1.84 is the current self-hosting candidate. It adds BASIC#-authored native action routing, preserves the prior three native compiler boundaries, keeps Ruby as bootstrap/referee authority for now, and remains on the same version while the rejected Company Bible/current-reference defect is repaired and revalidated.
