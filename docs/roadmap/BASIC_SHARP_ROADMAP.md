# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> BSharp IR
-> deterministic reference Ruby runtime
-> BSharp Save and BSharp ASK
-> Stable Meaning Profile 1  [ACCEPTED: v0.1.24]
-> one canonical Company Bible  [ACCEPTED: v0.1.25]
-> BSharp Bytecode contract  [ACCEPTED: v0.1.26]
-> deterministic BSBC emitter  [ACCEPTED: v0.1.27]
-> complete BSBC loader and validator  [ACCEPTED: v0.1.28]
-> first BSharp Virtual Machine  [CURRENT CANDIDATE: v0.1.29]
-> owner validation and acceptance
-> source/BSIR/BSBC runtime parity and hardening
-> BSharp Save and ASK through the VM
-> game-engine bridge
-> BASIC# self-hosting compiler
-> BASIC# code editor
-> BASIC# IDE
```

## Current v0.1.29 lane

Execute trusted `bsharp.bytecode.v1` programs for the first time:

- accept only a completed `BytecodeLoader` as the VM program boundary;
- create an independent mutable world from validated START records;
- interpret Profile 1 actions and conditions directly from BSBC records;
- preserve exact-Thing, inherited-Kind, and source-order event priority;
- preserve `that Kind`, `every Kind`, action-line ordering, atomic set validation, reactive IF settlement, follow-up FIFO order, and loop guards;
- keep the loaded model deeply frozen and unchanged;
- prove that execution still works while the reference `BasicSharp::Runtime` constructor is disabled;
- expose deterministic snapshots and canonical plain-language VM reporting;
- allow `.bsbc --run "event"` through the bootstrap CLI.

No BSharp Save or ASK integration through the VM, reference-runtime replacement, full VM stress hardening, optimization, JIT, native code, new bytecode profile, binary-layout change, or creator-facing language change is authorized in this lane.

## Immediate continuation after v0.1.29 acceptance

The next eligible proposal is **Source, BSIR, and BSBC Runtime Parity and Hardening**. It should run all established stress lanes through the VM, integrate BSharp Save and ASK at the validated VM boundary, harden failure recovery, and define when the BSBC path can become the preferred runtime path.

## Completed foundation

- Five accepted Heads: KINDS, DEFINE, START, WHEN, and IF.
- Things, inherited Kind families, deterministic event matching, and set actions.
- Reactive IF rules with rearming, cascades, and loop protection.
- Whole-number values and deterministic explicit follow-up events.
- BSharp IR, BSharp Save, and BSharp ASK.
- Implementation-neutral `bsharp.meaning.v1` conformance fixtures.
- One canonical Company Bible and integrity audit.
- BSharp Bytecode Profile 1 architecture, emitter, disassembly, and complete loader.

## Shelved commercial lane

Private/proprietary distribution remains under consideration, but licensing and monetization are intentionally deferred. Future Creator pricing must include a reasonable monthly option, annual billing may only be an optional discount, and an eligible paid local version must remain usable permanently under the eventual qualifying terms.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- BASIC# is the language name; BSharp is used where `#` is unsafe.
- No new `DK`-prefixed name without Derek's explicit approval.
- Difficult machinery belongs under understandable creator-facing language.
- Every build requires an exact accepted base, proposal, approval, validation, changed-files-only package, handshake, commit, and tag.
- The complete Company Bible is one file: `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`.
