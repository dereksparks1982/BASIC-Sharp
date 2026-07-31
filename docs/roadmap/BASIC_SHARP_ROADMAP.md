# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> BSharp IR debug document
-> runtime execution
-> Trigger context and plain trace
-> inherited Kind matching
-> Kind-family hardening
-> reactive IF rules and loop protection
-> multiple selected Things and deterministic set actions
-> whole-number values and damage amounts
-> BSharp IR identity migration  [ACCEPTED: v0.1.20]
-> explicit follow-up events and deterministic event order  [CURRENT CANDIDATE: v0.1.21]
-> owner validation and acceptance
-> save/load world state
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
- Kinds, Things, Facts, Triggers, Connectors, and official words.
- START world construction.
- Exact and inherited WHEN matching.
- Singular `that Kind` context.
- Deterministic `every Kind` action selection.
- Reactive IF rules with false-to-true wake-up, re-arming, cascades, and loop protection.
- Whole-number Thing values, damage amounts, and exact value assignment.
- Missing-value and overflow atomicity.
- BSharp IR identity, `.bsir.json` files, and retired-DKIR rejection.
- Explicit `(cause` follow-up events.
- Complete-body and complete-IF settlement before follow-up events.
- First-created, first-run ordering with nested events appended to the end.
- Captured context, fresh event matching, unmatched continuation, fatal-error stop, and 1,024-event protection.

## Immediate continuation after v0.1.21 acceptance

The next roadmap lane is **Save/Load World State** unless Derek changes direction.

The next proposal must define, before implementation:

- exactly what world state is saved;
- whether pending follow-up events may be saved or only settled worlds;
- file identity, versioning, and corruption handling;
- Thing identity and definition-order preservation;
- Kind, state, relation, value, damage, IF-active, and startup-state behavior;
- whether creator source and BSharp IR are required when loading a save;
- deterministic restore and replay guarantees;
- human-readable recovery messages;
- BSharp IR or separate save-document representation;
- tests, stress, rollback, files, exclusions, and package name.

No v0.1.22 implementation begins without the complete proposal and Derek's explicit approval.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- BASIC# is the language name; BSharp is used where `#` is unsafe.
- BSharp Intermediate Representation is normally called BSharp IR or BSIR.
- No new `DK`-prefixed BASIC# component is created without Derek's explicit approval.
- The compiler and runtime do the heavy lifting.
- Difficult mathematics may live internally, while creators normally express intent, quantities, and choices.
- Ruby remains scaffolding.
- No new official word enters casually.
- One Kind has one direct parent until explicitly changed.
- IF completes rule bodies before another IF check.
- A complete IF settlement finishes before the next follow-up event.
- `(cause` is explicit; ordinary world changes do not generate hidden events.
- Follow-up events remain first-created, first-run until explicitly changed.
- `that Kind` remains singular until an explicit plural-context design is approved.
- `every Kind` remains action-only and is not allowed inside `(cause` until plural event meaning is explicitly designed.
- Damage and health remain independent unless Derek explicitly approves a combat rule.
