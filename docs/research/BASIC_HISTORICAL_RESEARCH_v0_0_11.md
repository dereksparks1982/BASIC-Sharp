# Historical BASIC Research and BASIC# Roadmap v0.0.11

## Sources reviewed

- 1965 General Electric / Dartmouth *Time-Sharing BASIC Language Reference Manual*.
- 1987 ANSI X3.113-1987 *Full BASIC* standard.

These sources are research references. BASIC# does not copy their syntax.

## Important finding

The beginner-first BASIC family eventually covered far more than calculator exercises. Full BASIC included substantial areas for:

- graphics;
- files;
- debugging;
- exception handling;
- real-time programs;
- scheduling;
- events;
- shared data;
- message passing;
- resource management;
- editing.

This supports the BASIC# goal: a simple creator-facing language can sit above a powerful engine.

## Future lane: ASK-style introspection

The creator should eventually be able to ask the system why something happened or what the world currently knows.

Possible Studio questions:

```text
ask why ember became angry
ask what can open north door
ask which guard was selected
ask what happened after player attacked henry
```

No BASIC# ASK syntax is approved in v0.0.11.

## Future lane: visible execution tracing

The system should eventually show a plain sequence such as:

```text
player attacked henry
player attacks a guard matched
that guard became henry
(damage changed henry
henry damage is now 1
```

This is a glass hood over the engine: enough visibility to understand and repair the ride without dismantling it.

## Future lane: plain recovery

The runtime will eventually need understandable ways to recover from:

- missing save information;
- a Thing that no longer exists;
- impossible movement;
- failed resources;
- network problems;
- event loops.

The historical behavior is worth studying. The old wording and syntax are not.

## Future lane: internal areas hidden from the creator

The implementation may eventually separate capabilities such as:

```text
Core
World
Graphics
Sound
Time
Files
Network
```

These are internal engineering areas. The creator should not be forced to manage technical modules merely to make ordinary things happen.

## Future language review: capitalization and spacing

Historical BASIC allowed upper- and lowercase keywords and ignored many harmless spaces.

BASIC# should later decide whether these forms are identical:

```text
WHEN
When
when
```

Harmless spacing tolerance should also be considered.

These are proposed design questions only. v0.0.11 does not implement them.

## Teaching doctrine

The 1965 manual taught by making complete programs, running them, observing mistakes, correcting them, and running them again.

BASIC# beginner material should follow:

```text
Make something.
Run it.
See what happened.
Change one thing.
Run it again.
```

Formal contracts remain necessary for the compiler team. They should not be the beginner's front door.

## Machinery not carried forward

BASIC# should not revive old machinery merely because it appeared in BASIC:

```text
line numbers
GOTO
GOSUB
A$ naming
DIM as beginner ceremony
file channel numbers
dense mathematical punctuation
messages such as ILLEGAL FORMULA IN 5
```

The invitation to ordinary people is valuable. The obsolete dashboard is not.

## Roadmap action

The following are now documented later lanes:

- ASK-style introspection;
- visible execution tracing;
- plain runtime recovery;
- internal capability separation hidden from the creator;
- capitalization tolerance review;
- spacing tolerance review;
- example-first teaching.

None of these has been implemented by v0.0.11.
