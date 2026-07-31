# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> BSharp IR
-> deterministic reference Ruby runtime  [REFERENCE ORACLE]
-> BSharp Save and BSharp ASK
-> Stable Meaning Profile 1  [ACCEPTED: v0.1.24]
-> one canonical Company Bible  [ACCEPTED: v0.1.25]
-> BSharp Bytecode contract  [ACCEPTED: v0.1.26]
-> deterministic BSBC emitter  [ACCEPTED: v0.1.27]
-> complete BSBC loader and validator  [ACCEPTED: v0.1.28]
-> first BSharp Virtual Machine  [ACCEPTED: v0.1.29]
-> VM parity, BSharp Save, BSharp ASK, and hardening  [ACCEPTED: v0.1.30]
-> BSharp VM preferred runtime transition and shadow parity  [CURRENT CANDIDATE: v0.1.31]
-> owner validation and acceptance
-> expand BASIC# toward Profile 2 and self-hosting needs
-> game-engine bridge
-> BASIC# self-hosting compiler
-> BASIC# code editor
-> BASIC# IDE
```

## Current v0.1.31 lane

Formalize the permanent runtime direction already established by Derek:

- `.bsharp` and `.bsir.json` emit BSBC in memory and run through the validated BSharp VM;
- `.bsbc` continues directly through the validated BSharp VM;
- `BasicSharp::Runtime` becomes explicit reference-oracle machinery rather than the normal creator path;
- optional shadow verification compares both engines and stops on disagreement;
- no temporary bytecode artifacts leak from normal source or BSIR execution;
- no new creator-facing language meaning is added in this transition.

## Immediate continuation after v0.1.31 acceptance

The next numbered build may begin Profile 2. Choose the smallest capability that creates major creator value and also helps eventual self-hosting. General text values are the strongest current candidate because dialogue, messages, names, paths, diagnostics, and compiler work all need text. This remains a future proposal, not approved work.

## Completed foundation

- Five accepted Heads: KINDS, DEFINE, START, WHEN, and IF.
- Things, inherited Kind families, deterministic event matching, and set actions.
- Reactive IF rules with rearming, cascades, and loop protection.
- Whole-number values and deterministic explicit follow-up events.
- BSharp IR, BSharp Save, and BSharp ASK.
- Implementation-neutral `bsharp.meaning.v1` conformance fixtures.
- One canonical Company Bible and integrity audit.
- BSharp Bytecode Profile 1 architecture, emitter, disassembly, complete loader, direct VM, Save/ASK integration, and hardening.
- Preferred BSharp VM runtime path with explicit reference and shadow-parity modes.

## Shelved commercial lane

Private/proprietary distribution remains under consideration, but licensing and monetization are intentionally deferred. Future Creator pricing must include a reasonable monthly option, annual billing may only be an optional discount, and an eligible paid local version must remain usable permanently under the eventual qualifying terms.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- BASIC# is the language name; BSharp is used where `#` is unsafe.
- No new `DK`-prefixed name without Derek's explicit approval.
- Difficult machinery belongs under understandable creator-facing language.
- The BSharp VM is the preferred runtime; Ruby remains temporary bootstrap support and reference verification.
- Every build requires an exact accepted base, approval, validation, changed-files-only package, handshake, commit, and tag.
- The complete Company Bible is one file: `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`.
