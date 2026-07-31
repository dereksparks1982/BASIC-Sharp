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
-> BSharp Bytecode Architecture and Instruction Contract 1  [ACCEPTED: v0.1.26]
-> BSharp Bytecode Emitter and Deterministic Disassembly 1  [CURRENT CANDIDATE: v0.1.27]
-> owner validation and acceptance
-> BSharp Bytecode loader and complete validator
-> first BSharp virtual machine
-> source/BSIR/BSBC runtime parity and hardening
-> game-engine bridge
-> BASIC# self-hosting compiler
-> BASIC# code editor
-> BASIC# IDE
```

## Current v0.1.27 lane

Create real deterministic execution artifacts without executing them:

- emit `bsharp.bytecode.v1` `.bsbc` files from `.bsharp` source or `.bsir.json`;
- require byte-identical source/BSIR output for equivalent normalized meaning;
- emit deterministic `.bsbc.txt` diagnostic disassembly;
- lock mandatory string-prefix and semantic traversal ordering;
- preserve Kind ancestors before descendants and Thing definition order;
- lower all current START records, WHEN patterns, IF conditions, selectors, and official actions;
- preserve the `sha256-bsir-meaning-v1` fingerprint as 32 raw bytes;
- reject errors, warnings, unsupported meaning, invalid output identities, and conflicting CLI modes;
- write binary and disassembly atomically;
- lock sample and Meaning Profile fixture hashes.

No arbitrary bytecode loader, VM, execution, optimization, compression, or Ruby-runtime replacement is authorized in this lane.

## Immediate continuation after v0.1.27 acceptance

The next eligible proposal is **BSharp Bytecode Loader and Complete Validation 1**. It should read arbitrary `.bsbc` files, validate every header, directory, section, reference, operand, fingerprint, and boundary rule before exposing a trusted in-memory model. It must remain non-executing unless Derek separately approves VM work.

The first VM, runtime parity lane, engine bridge, and self-hosting remain later builds.

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
- BSharp Bytecode Profile 1 architecture and machine-readable contract.

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
