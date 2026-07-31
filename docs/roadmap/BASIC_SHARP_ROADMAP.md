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
-> BSharp Save files and deterministic world restore  [CURRENT CANDIDATE: v0.1.22]
-> owner validation and acceptance
-> ASK-style introspection
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
- BSharp IR identity, `.bsir.json` files, and retired-DKIR rejection.
- Explicit `(cause` follow-up events with complete-body and complete-IF settlement.
- First-created, first-run event order, nested append-to-end behavior, fresh contexts, and 1,024-event protection.
- Separate BSharp Save identity using `.bsave.json`.
- Settled-world saving and deterministic atomic restore.
- Program fingerprints shared by source and equivalent saved BSIR.
- Preservation of Thing order, Kinds, states, relationships, values, damage, and IF activity.
- No START, startup IF, or startup event replay when restoring.
- Atomic failed-load and failed-write protection.

## Immediate continuation after v0.1.22 acceptance

The next roadmap lane is **ASK-style introspection** unless Derek changes direction.

The next proposal must define before implementation:

- the exact creator-facing spelling and purpose of ASK;
- whether ASK is a Head, command, toolchain query, or separate inspection surface;
- what can be asked about Things, Kinds, values, rules, events, and saves;
- plain-language answers and ambiguity handling;
- whether ASK reads source meaning, live runtime state, BSharp IR, BSharp Save, or combinations;
- deterministic output and machine-readable results;
- safety boundaries so ASK observes without secretly changing the world;
- tests, stress, rollback, files, exclusions, and package name.

No v0.1.23 implementation begins without the complete proposal and Derek's explicit approval.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- BASIC# is the language name; BSharp is used where `#` is unsafe.
- BSharp Intermediate Representation is normally called BSharp IR or BSIR.
- BSharp Save is the separate world-state format.
- No new `DK`-prefixed BASIC# component is created without Derek's explicit approval.
- The compiler and runtime do the heavy lifting.
- Difficult mathematics may live internally while creators express intent, quantities, and choices.
- Ruby remains scaffolding.
- No new official word enters casually.
- START builds a new world; loading a save restores one without replaying START.
- Saves represent only fully settled worlds.
- IF completes rule bodies before another IF check.
- A current event body and IF settlement finish before a follow-up event runs.
- Follow-up events are explicit, first-created/first-run, and bounded.
- Source and saved BSIR must remain behaviorally equivalent.
- Warnings remain failures for build validation.
- One build at a time, changed-files-only by default, with exact base verification and rollback.
