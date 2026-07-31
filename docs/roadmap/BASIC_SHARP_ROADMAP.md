# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> BSharp IR debug document
-> deterministic runtime execution
-> inherited Kinds, reactive IF rules, values, set actions, and follow-up events
-> BSharp IR identity migration  [ACCEPTED: v0.1.20]
-> explicit follow-up events and deterministic event order  [ACCEPTED: v0.1.21]
-> BSharp Save files and deterministic world restore  [ACCEPTED: v0.1.22]
-> ASK introspection and deterministic answers  [ACCEPTED: v0.1.23]
-> Stable Meaning Specification and Conformance Profile 1  [CURRENT CANDIDATE: v0.1.24]
-> owner validation and acceptance
-> bytecode design
-> BASIC# VM
-> game-engine bridge
-> BASIC# self-hosting compiler
-> BASIC# code editor
-> BASIC# IDE
```

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

## Immediate continuation after v0.1.24 acceptance

The next eligible lane is **Bytecode Design** unless Derek changes direction.

The bytecode proposal must define before implementation:

- instruction identity and versioning;
- how Profile 1 semantic structures lower into instructions;
- deterministic event, IF, selection, save, and ASK behavior;
- readable disassembly;
- validation and malformed-bytecode rejection;
- Ruby runtime comparison strategy;
- future VM boundaries;
- exact files, risks, exclusions, rollback, and package name.

No bytecode implementation begins without a complete proposal and Derek's explicit approval.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- BASIC# is the language name; BSharp is used where `#` is unsafe.
- BSharp IR, BSharp Save, BSharp ASK, and BSharp Meaning Profile are approved identities.
- No new `DK`-prefixed name without Derek's explicit approval.
- The opening `(` in official words is a creator-facing visual guide.
- Complex machinery belongs under understandable creator-facing language.
- Every build requires an exact accepted base, proposal, approval, validation, changed-files-only package, handshake, commit, and tag.
