# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> BSharp IR debug document
-> deterministic Ruby runtime execution
-> inherited Kinds, reactive IF rules, values, set actions, and follow-up events
-> BSharp IR identity migration  [ACCEPTED: v0.1.20]
-> follow-up events and deterministic event order  [ACCEPTED: v0.1.21]
-> BSharp Save files and deterministic world restore  [ACCEPTED: v0.1.22]
-> ASK introspection and deterministic answers  [ACCEPTED: v0.1.23]
-> Stable Meaning Specification and Conformance Profile 1  [ACCEPTED: v0.1.24]
-> Canonical Company Bible Consolidation  [ACCEPTED: v0.1.25]
-> BSharp Bytecode Architecture and Instruction Contract 1  [CURRENT CANDIDATE: v0.1.26]
-> owner validation and acceptance
-> bytecode emitter and deterministic disassembly
-> BASIC# bytecode loader and VM
-> game-engine bridge
-> BASIC# self-hosting compiler
-> BASIC# code editor
-> BASIC# IDE
```

## Current v0.1.26 lane

Define before execution:

- BSharp Bytecode / BSBC identity;
- `.bsbc`, `BSBC` magic, `bsharp.bytecode.bin`, and `bsharp.bytecode.v1`;
- exact header and eight-section container;
- fixed Profile 1 instructions, selectors, and IF condition operators;
- deterministic string, Kind, Thing, event, IF, and code-block ordering;
- Profile 1 coverage for all 13 conformance cases;
- readable diagnostic disassembly grammar;
- complete pre-execution malformed-bytecode rejection;
- machine-readable validation independent of Ruby object layouts.

No emitter, `.bsbc` program output, loader, VM, or execution is authorized in this lane.

## Immediate continuation after v0.1.26 acceptance

The next eligible proposal is a **BSharp Bytecode Emitter and Deterministic Disassembly** build. It must lower normalized BSIR into byte-identical `.bsbc` files, emit readable disassembly, compare source/BSIR meaning fingerprints, and remain non-executing until separately approved.

The loader and VM remain later lanes.

## Completed foundation

- Five accepted Heads: KINDS, DEFINE, START, WHEN, and IF.
- Things, facts, inherited Kind families, and deterministic matching.
- Singular `that Kind` and deterministic `every Kind` actions.
- Reactive IF rules with re-arming, cascades, and loop protection.
- Whole-number values, damage amounts, exact assignment, and atomic validation.
- BSharp IR identity and retired-DKIR rejection.
- Explicit `(cause` follow-up events and deterministic order.
- Deterministic BSharp Save restore.
- Read-only deterministic ASK inspection.
- Implementation-neutral `bsharp.meaning.v1` conformance fixtures.
- One canonical Company Bible with repeatable integrity audit.

## Shelved commercial lane

Private/proprietary distribution remains under consideration, but licensing and monetization are intentionally deferred. Future Creator pricing must include a reasonable monthly option, annual billing may only be an optional discount, and an eligible paid local version must remain usable permanently under the eventual qualifying terms.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- BASIC# is the language name; BSharp is used where `#` is unsafe.
- BSharp IR, BSharp Save, BSharp ASK, BSharp Meaning Profile, BSharp Bytecode, and BSBC are approved identities.
- No new `DK`-prefixed name without Derek's explicit approval.
- The opening `(` in official words is a creator-facing visual guide.
- Complex machinery belongs under understandable creator-facing language.
- Every build requires an exact accepted base, proposal, approval, validation, changed-files-only package, handshake, commit, and tag.
- The complete Company Bible is one file: `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`.
