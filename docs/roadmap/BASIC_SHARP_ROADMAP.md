# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> DKIR debug document
-> runtime execution
-> Trigger context and plain trace
-> inherited Kind matching
-> Kind-family hardening
-> reactive IF rules and loop protection
-> multiple selected Things and deterministic set actions
-> whole-number values and damage amounts  [CURRENT CANDIDATE: v0.1.19]
-> owner validation and acceptance
-> event ordering and queue design
-> save/load world state
-> ASK-style introspection
-> stable meaning specification
-> bytecode
-> BASIC# VM
-> DK Engine bridge
-> BASIC# self-hosting compiler
```

## Completed foundation

- Controlled Body structure.
- Kinds, Things, Facts, Triggers, Connectors, and official words.
- DKIR debug JSON.
- START world construction.
- Exact and inherited WHEN matching.
- Per-event singular `that Kind` context.
- Plain runtime trace and errors.
- BASIC# identity and Company Bible integration.
- Deep Kind-family hardening and stress.
- Reactive IF false-to-true wake-up, re-arming, cascades, and loop protection.
- Explicit `every Kind` action targeting.
- Deterministic direct/inherited set selection.
- Bounded human output with complete structured set results.
- Whole-number Thing values.
- Default and explicit damage amounts.
- Exact value assignment and exact-value reactive IF.
- Missing-value and overflow atomicity.
- Damage/health separation with no hidden combat formula.
- Source and saved-DKIR parity.

## Immediate continuation after v0.1.19 acceptance

The next roadmap lane is **Event Ordering and Queue Design** unless Derek changes direction.

The proposal must define, before implementation:

- what counts as a new event rather than a direct action result;
- whether world changes may create follow-up WHEN events;
- deterministic ordering between direct actions, IF settlement, and queued events;
- queue ownership, bounded processing, and loop protection;
- whether queued events preserve actor and selected-Thing context;
- plain trace wording that exposes cause and order without programmer jargon;
- source and saved-DKIR representation;
- compatibility with values, amounts, sets, and reactive IF;
- stress, rollback, files, exclusions, and package name.

No v0.1.20 implementation begins without the complete proposal and Derek's explicit approval.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- The compiler and engine do the heavy lifting.
- Difficult mathematics may live internally, but ordinary creators should normally express intent, quantities, and choices rather than formulas.
- Ruby remains scaffolding.
- No new official word enters casually.
- One Kind has one direct parent until explicitly changed.
- IF completes rule bodies before another IF check.
- `that Kind` remains singular until an explicit plural-context design is approved.
- `every Kind` is action-only until all/any condition meaning is explicitly designed.
- Damage and health remain independent unless Derek explicitly approves a combat rule.
- Timing and event queues remain separate future work until their ordering contract is approved.
