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
-> BSharp IR identity migration  [CURRENT CANDIDATE: v0.1.20]
-> owner validation and acceptance
-> event ordering and queue design
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
- BSharp IR format marker `bsir.debug.json`.
- `.bsir.json` saved debug files.
- BSharp IR wording throughout current code, tests, tools, samples, contracts, and documentation.
- Retired DKIR rejection with an exact creator-facing recovery message.
- BASIC#-named patch manifest and package format.

## Immediate continuation after v0.1.20 acceptance

The next roadmap lane returns to **Event Ordering and Queue Design** unless Derek changes direction.

The next proposal must define, before implementation:

- what counts as a new event rather than a direct action result;
- whether world changes may create follow-up WHEN events;
- deterministic ordering between direct actions, IF settlement, and queued events;
- queue ownership, bounded processing, and loop protection;
- whether queued events preserve actor and selected-Thing context;
- plain trace wording that exposes cause and order without programmer jargon;
- BSharp IR representation;
- compatibility with values, amounts, sets, and reactive IF;
- stress, rollback, files, exclusions, and package name.

No v0.1.21 implementation begins without the complete proposal and Derek's explicit approval.

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
- `that Kind` remains singular until an explicit plural-context design is approved.
- `every Kind` remains action-only until all/any condition meaning is explicitly designed.
- Damage and health remain independent unless Derek explicitly approves a combat rule.
