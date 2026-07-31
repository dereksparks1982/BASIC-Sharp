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
-> BSharp Bytecode Emitter and Deterministic Disassembly 1  [ACCEPTED: v0.1.27]
-> BSharp Bytecode Loader and Complete Structural Validation 1  [CURRENT CANDIDATE: v0.1.28]
-> owner validation and acceptance
-> first BSharp virtual machine
-> source/BSIR/BSBC runtime parity and hardening
-> game-engine bridge
-> BASIC# self-hosting compiler
-> BASIC# code editor
-> BASIC# IDE
```

## Current v0.1.28 lane

Read real `.bsbc` artifacts safely without executing them:

- validate the complete 32-byte header and eight-entry section directory;
- validate section order, bounds, alignment, zero padding, and exact file size;
- validate deterministic UTF-8 strings and canonical first-encounter order;
- validate META identities, fingerprint shape, and all section counts;
- validate Kind ancestry, Things, START, WHEN, IF, CODE, selectors, references, operands, and whole numbers;
- reconstruct a deeply frozen trusted in-memory bytecode program only after complete success;
- reproduce committed `.bsbc.txt` disassembly directly from binary records;
- optionally compare the meaning fingerprint against matching `.bsharp` or `.bsir.json` input;
- reject all 41 malformed-bytecode rules through deterministic in-memory corruptions;
- reject every truncated prefix without exposing a partial model.

No VM, bytecode execution, runtime replacement, world mutation, ASK against BSBC, optimization, compression, or language change is authorized in this lane.

## Immediate continuation after v0.1.28 acceptance

The next eligible proposal is **First BSharp Virtual Machine 1**. It should execute validated trusted BSBC models while preserving Meaning Profile 1 event matching, action ordering, IF settlement, follow-up event order, loop protection, and deterministic final worlds.

The first VM must remain a separate owner-approved build. Runtime parity hardening follows afterward.

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
- Deterministic BSBC emitter and diagnostic disassembly.

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
