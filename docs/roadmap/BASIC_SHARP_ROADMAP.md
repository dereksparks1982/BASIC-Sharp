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
-> first BSharp Virtual Machine  [ACCEPTED: v0.1.29]
-> VM parity, BSharp Save, BSharp ASK, and hardening  [CURRENT CANDIDATE: v0.1.30]
-> owner validation and acceptance
-> decide when BSBC becomes the preferred runtime path
-> expand BASIC# toward Profile 2 and self-hosting needs
-> game-engine bridge
-> BASIC# self-hosting compiler
-> BASIC# code editor
-> BASIC# IDE
```

## Current v0.1.30 lane

Complete and harden the Profile 1 bytecode runtime milestone:

- BSharp Save write and restore through the VM;
- no START replay when restoring a VM world;
- preserved IF active state and deterministic replay;
- BSharp ASK through the VM without mutation;
- source, saved BSIR, and validated BSBC world parity;
- repeated save/restore/replay cycles;
- independent VM worlds over one frozen loader model;
- atomic malformed-save rejection and recovery;
- bounded VM stress and performance reporting;
- continued proof that the VM executes without the reference runtime.

No new creator-facing language behavior is authorized in this lane.

## Immediate continuation after v0.1.30 acceptance

The bytecode runtime milestone is substantially complete. The next proposal should first decide whether the validated BSBC path becomes the preferred runtime path, then choose the smallest Profile 2 capability needed to move toward useful programs and eventual self-hosting. No transition removes the reference runtime without Derek's explicit approval and parity evidence.

## Completed foundation

- Five accepted Heads: KINDS, DEFINE, START, WHEN, and IF.
- Things, inherited Kind families, deterministic event matching, and set actions.
- Reactive IF rules with rearming, cascades, and loop protection.
- Whole-number values and deterministic explicit follow-up events.
- BSharp IR, BSharp Save, and BSharp ASK.
- Implementation-neutral `bsharp.meaning.v1` conformance fixtures.
- One canonical Company Bible and integrity audit.
- BSharp Bytecode Profile 1 architecture, emitter, disassembly, complete loader, and direct VM.

## Shelved commercial lane

Private/proprietary distribution remains under consideration, but licensing and monetization are intentionally deferred. Future Creator pricing must include a reasonable monthly option, annual billing may only be an optional discount, and an eligible paid local version must remain usable permanently under the eventual qualifying terms.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- BASIC# is the language name; BSharp is used where `#` is unsafe.
- No new `DK`-prefixed name without Derek's explicit approval.
- Difficult machinery belongs under understandable creator-facing language.
- Every build requires an exact accepted base, approval, validation, changed-files-only package, handshake, commit, and tag.
- The complete Company Bible is one file: `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`.
