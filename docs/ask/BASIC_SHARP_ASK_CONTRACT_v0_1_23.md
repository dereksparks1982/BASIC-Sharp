# BASIC# ASK Contract v0.1.23

## Identity

- Human command: `--ask "question"`
- Machine mode: `--ask-json`
- Format: `bsharp.ask.json`
- Format version: 1
- Maximum questions: 256 per command

ASK is a bootstrap-tool inspection surface. It is not a Head, official word, event, or world action.

## Supported questions

```text
what is <Thing-or-Kind>
what is Thing <name>
what is Kind <name>
what Kind is <Thing>
what states does <Thing> have
what values does <Thing> have
what relationships does <Thing> have
what Things are <Kind-plural>
what happens when <event>
what IF rules are true
what is the world
what is the save
```

Questions are case-insensitive. Creator-defined names are reported canonically. Ambiguous Thing/Kind names require an explicit question.

## Observation boundary

ASK must not:

- run an inspected event;
- execute actions or IF rules;
- create follow-up events;
- change Thing state, values, or relationships;
- change IF active state;
- change save readiness;
- write a save after an invalid question.

## Event inspection

Event questions use the runtime's accepted priority order:

1. exact named-Thing rule;
2. nearest matching Kind;
3. source order for equal distance.

The selected WHEN rule, contextual understanding, and action texts are reported. Outcomes are not simulated.

## Output

Human output shows at most 50 Things or 50 true IF rules per answer. Machine output remains complete and deterministic.

The JSON document contains no timestamps, random identifiers, machine paths, or unstable ordering.
