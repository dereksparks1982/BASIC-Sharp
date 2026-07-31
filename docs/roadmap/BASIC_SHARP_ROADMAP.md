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
-> ASK introspection and deterministic answers  [CURRENT CANDIDATE: v0.1.23]
-> owner validation and acceptance
-> stable meaning specification
-> bytecode
-> BASIC# VM
-> game-engine bridge
-> BASIC# self-hosting compiler
-> BASIC# code editor
-> BASIC# IDE
```

## Completed foundation

- Controlled Body structure.
- `KINDS`, `DEFINE`, `START`, `WHEN`, and `IF` Heads.
- Things, facts, inherited Kind families, and deterministic matching.
- Singular `that Kind` context and deterministic `every Kind` action selection.
- Reactive IF rules with false-to-true waking, re-arming, cascades, and loop protection.
- Whole-number values, damage amounts, exact assignment, and atomic validation.
- BSharp IR identity and retired-DKIR rejection.
- Explicit `(cause` follow-up events and deterministic ordering.
- Separate BSharp Save identity and settled-world restore.
- Program fingerprints, deterministic files, and atomic save/load safety.
- Read-only ASK inspection of Things, Kinds, event matching, IF rules, world state, and save origin.
- Deterministic human answers and complete `bsharp.ask.json` output.

## Immediate continuation after v0.1.23 acceptance

The next roadmap lane is **Stable Meaning Specification** unless Derek changes direction.

The next proposal must define before implementation:

- the exact normative meaning document and versioning policy;
- which source, BSIR, runtime, save, and ASK behaviors become stable contracts;
- compatibility promises and what may still change before 1.0;
- canonical terminology for Heads, Things, Kinds, facts, rules, actions, values, events, saves, and answers;
- conformance tests and machine-readable meaning fixtures;
- how later bytecode and VM implementations prove the same meaning;
- risks, rollback, validation, exact files, exclusions, and package name.

No v0.1.24 implementation begins without the complete proposal and Derek's explicit approval.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- BASIC# is the language name; BSharp is used where `#` is unsafe.
- BSharp Intermediate Representation is normally called BSharp IR or BSIR.
- BSharp Save is the separate world-state format.
- BSharp ASK is an inspection format, not a creator-world action.
- No new `DK`-prefixed BASIC# component is created without Derek's explicit approval.
- The compiler and runtime do the heavy lifting.
- Ruby remains scaffolding.
- No new official word enters casually.
- ASK observes and explains without changing the world.
- START builds a new world; loading a save restores one without replaying START.
- Saves represent only fully settled worlds.
- Follow-up events are explicit, first-created/first-run, and bounded.
- Source and saved BSIR must remain behaviorally equivalent.
- Warnings remain failures for build validation.
- One build at a time, changed-files-only by default, with exact base verification and rollback.
