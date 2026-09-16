# Preserved Copilot Review Brief

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


This is the project brief prepared for Copilot before the v0.0.11 documentation build. It is preserved as an outside-review request snapshot and may contain pre-v0.0.11 status wording.

# BASIC# Project Brief for Copilot Review

## What I want from you

Read this entire brief before responding.

I want an honest technical and design review of the language project so far. Do not write code yet. Do not rename anything. Do not assume BASIC# is compatible with traditional BASIC. Do not suggest copying BASIC, Ruby, JavaScript, C#, or any other language syntax.

BASIC# is a new language built from scratch. It takes inspiration from the original goal of BASIC, which was to make programming accessible to ordinary people, but BASIC# is free to speak and behave according to its own rules.

The target is simple:

> A person should be able to program without becoming a computer mechanic, just as a person can drive and enjoy a car without understanding the engine.

The compiler, runtime, virtual machine, and game engine should do the heavy lifting. The creator should be able to understand what they are writing, make simple repairs, and enjoy creating.

The language must be simple enough that a child or complete beginner can understand it.

---

# Language name

The intended language name is:

## BASIC#

Pronounced:

> Basic Sharp

BASIC# is not traditional BASIC and is not intended to be compatible with it.

The current repository and bootstrap compiler still use the older DKScript project name internally because the rename has not yet been performed.

The engine itself may still be called DK Engine, but the language does not need “DK” in its name.

---

# Current project path

```text
/home/dereksparks1982/DKLab/Projects/DKScript
```

The current compiler is written in Ruby only as a temporary bootstrap.

Long-term direction:

```text
Ruby bootstrap compiler
↓
BASIC# compiler and runtime mature
↓
BASIC# bytecode and virtual machine
↓
BASIC# becomes capable of compiling BASIC#
↓
Ruby is no longer the permanent compiler
↓
BASIC# becomes the native language of DK Engine
```

BASIC# will not use Ruby syntax.

---

# Accepted language shape

The old language structure was removed.

The current official shape is:

```text
HEAD
[first Body line
next Body line].
```

The opening `[` belongs directly against the first Body word.

Correct:

```text
KINDS
[creature is a thing
dragon is a creature
wyrm is a dragon].

DEFINE
[a wyrm named ember].

WHEN
[player attacks ember
<then> (damage ember].
```

Incorrect:

```text
KINDS
[
creature is a thing
].
```

The closing `].` closes the Body and ends the Head.

---

# Current Heads

Implemented:

```text
KINDS
DEFINE
START
WHEN
IF
```

Current purposes:

- `KINDS` says what kinds of Things exist.
- `DEFINE` creates Things.
- `START` describes the starting world.
- `WHEN` reacts to something happening.
- `IF` checks whether something is true.

---

# Current official language words

The following are official BASIC# words, not merely Ruby implementation details:

```text
(damage
(change
(carry
(unlock
```

For example:

```text
WHEN
[player attacks ember
<then> (damage ember].
```

The official word is:

```text
(damage
```

The whole phrase is not the name of the word.

`ember` is a previously defined Thing that the word applies to.

Do not invent extra creator-facing labels such as:

```text
Action Target
Action Statement
Command Tag
Order
Result Modifier
```

Those terms were rejected because they make the language harder to understand.

---

# Connector rule

Current connector:

```text
<then>
```

Accepted equivalent:

```text
<than>
```

They mean exactly the same thing.

No warning.
No correction.
No different behavior.

Likewise:

```text
there = their
```

The compiler bends toward the person instead of punishing common spelling confusion.

Important terminology correction:

`<then>` is not itself the result.

Example:

```text
WHEN
[player attacks ember
<then> (damage ember].
```

- `player attacks ember` is what happens first.
- `<then>` connects that to what follows.
- `(damage` is the official word that causes damage.
- Ember being damaged is the result.

---

# User-created Kinds

Implemented:

```text
KINDS
[dragon is a creature].
```

Then:

```text
DEFINE
[a dragon named ember].
```

Unknown Kinds produce errors.

A future Kind-family feature should allow:

```text
KINDS
[creature is a thing
dragon is a creature
wyrm is a dragon
drake is a dragon].
```

So the compiler understands:

```text
wyrm → dragon → creature → thing
drake → dragon → creature → thing
```

Use examples where the relationship actually needs to be taught. Do not use a lazy example such as “red dragon is a dragon,” because the name already says dragon.

---

# Defined Things

Implemented:

```text
DEFINE
[a dragon named ember
a guard named henry
a door named north door].
```

The compiler records each Thing’s name and Kind.

References to unknown Things produce errors.

---

# Starting world information

Implemented:

```text
START
[ember is angry
north door is locked
brass key is on oak table].
```

The compiler and runtime can store starting states and relationships.

Avoid meaningless examples such as declaring Ember “alive” unless that fact is relevant to what is being demonstrated.

---

# Current compiler and runtime status

## Accepted baseline

BASIC# was still internally named DKScript at this point.

Accepted version:

```text
v0.0.09 First Runtime Execution
```

Validated:

```text
35 runs
138 assertions
0 failures
0 errors
0 skips
```

v0.0.09 can:

- read source
- reject malformed source
- build BSharp IR
- save BSharp IR as JSON
- load source into the runtime
- load saved BSharp IR into the runtime
- create defined Things
- apply `START`
- receive an exact event
- match a `WHEN`
- follow `<then>`
- execute the current official words
- print the resulting world state

Validated example:

```text
player attacks ember
```

Result:

```text
(damage ember
(change ember to angry
```

World state showed:

```text
ember: kind=dragon; states=angry; damage=1
```

Source execution and saved BSharp IR execution produced the same result.

That source-to-BSharp IR-to-runtime separation is intentional.

---

# v0.0.10 status

A changed-files-only package for:

```text
v0.0.10 Runtime Trigger Context
```

has been built, but the user has not yet supplied terminal validation output proving it is accepted.

Planned behavior:

```text
KINDS
[guard is a person].

DEFINE
[a guard named henry].

WHEN
[player attacks a guard
<then> (damage that guard].
```

Runtime event:

```text
player attacks henry
```

Required behavior:

```text
a guard matches henry
that guard means henry
(damage damages henry
```

v0.0.10 is meant to:

- match a concrete Thing against a Kind in a Trigger
- remember the Thing selected by the Trigger
- allow `that guard` to mean the same selected Thing
- preserve exact event matching
- reject unknown Things
- reject Things of the wrong Kind
- add source, BSharp IR, runtime, and command-line tests

No new syntax or official words were supposed to be added.

---

# Current architecture

```text
BASIC# source
↓
parser
↓
meaning checks
↓
BSharp IR
↓
runtime
↓
world state changes
```

Current BSharp IR is JSON-based and should remain language-neutral.

Ruby-specific objects or tricks should not become part of the language’s meaning.

The Ruby compiler should be treated as a bootstrap and reference implementation, not as BASIC# syntax.

---

# Long-term roadmap

```text
Language structure
↓
Kinds and Things
↓
Starting world
↓
Triggers
↓
Official words
↓
BSharp IR
↓
First runtime
↓
Contextual Trigger matching
↓
Kind families
↓
Expanded conditions and events
↓
Multiple selected Things
↓
Event queue
↓
World changes creating events
↓
Values and amounts
↓
Time
↓
Repetition
↓
Groups and collections
↓
Creation and removal during runtime
↓
Saving and loading the world
↓
Runtime recovery
↓
Bytecode
↓
BASIC# VM
↓
Memory system
↓
Standard BASIC# library
↓
game-engine bridge
↓
DK Engine
↓
BASIC# self-hosting compiler
```

---

# Important philosophy

BASIC# should be easy for the creator even when the machinery underneath is complicated.

The creator should not need to understand:

- parsing
- bindings
- scopes
- ASTs
- bytecode
- garbage collection
- event queues
- dispatch
- lowering
- compiler passes

Those things may exist internally.

The creator should see plain language and obvious cause-and-effect.

Example:

```text
WHEN
[player attacks a guard
<then> (damage that guard].
```

The creator should understand this without being taught “contextual binding.”

---

# Error-message philosophy

Errors should explain what happened in ordinary language.

Bad:

```text
unresolved contextual reference
```

Better:

```text
I do not know which guard you mean.

I found Henry and Thomas.

Use their name or make the situation clearer.
```

Another example:

```text
I do not know what “wyrm” means.

You used it here:
[a wyrm named ember].

Tell me what a wyrm is in KINDS first.
```

The compiler should explain:

- what it understood
- what it did not understand
- where the problem happened
- how to repair it

---

# Interesting ideas found in historical BASIC manuals

Two manuals were reviewed:

1. The 1965 General Electric / Dartmouth Time-Sharing BASIC reference manual.
2. The 1987 ANSI Full BASIC standard.

The useful ideas are not their syntax. The useful ideas are their feature map and beginner-first intent.

## 1. BASIC eventually supported serious systems

Full BASIC included areas for:

- graphics
- real-time programs
- scheduling
- events
- shared data
- message passing
- files
- debugging
- exception recovery
- editing

This proves that a language with a beginner-first identity can still grow into a serious engine language.

## 2. Event-oriented concepts existed

Full BASIC included words such as:

```text
WHEN
EVENT
MESSAGE
SEND
RECEIVE
TIMEOUT
SHARED
SIGNAL
WAIT
PROCESS
PORT
```

BASIC# should not copy their syntax, but these concepts fit its future engine role.

## 3. ASK-style introspection

Full BASIC had an `ASK` concept that could question the system.

A future BASIC# Studio could support questions such as:

```text
ask why ember became angry
ask what can open north door
ask which guard was selected
ask what happened after player attacked henry
```

This could let creators inspect the machine without becoming mechanics.

No final BASIC# syntax for this has been approved.

## 4. Visible execution tracing

Full BASIC included debugging, breaks, and tracing.

BASIC# should eventually show a plain-language trace such as:

```text
player attacked henry
player attacks a guard matched
that guard became henry
(damage changed henry
henry damage is now 1
```

This would be a glass hood over the engine.

## 5. Recovery instead of immediate failure

Full BASIC included retrying, continuing, and handling runtime problems.

BASIC# will eventually need plain-language recovery for:

- missing save data
- vanished Things
- impossible movement
- failed resources
- network problems
- recursive events

The behavior is worth studying. The old terminology and syntax are not.

## 6. Modular internals

Full BASIC separated its core from graphics, real-time behavior, files, fixed decimal work, and editing.

BASIC# could eventually have internal areas such as:

```text
BASIC# Core
BASIC# World
BASIC# Graphics
BASIC# Sound
BASIC# Time
BASIC# Files
BASIC# Network
```

The creator should not be forced to manage these as technical modules. The compiler can activate what is needed behind the scenes.

## 7. Forgiving capitalization and spacing

Historical Full BASIC treated upper- and lowercase keywords as equivalent and ignored many harmless spaces.

BASIC# should consider whether these should mean the same thing:

```text
WHEN
When
when
```

The editor may still display the official form as `WHEN`.

Harmless spacing should not break the program.

No final rule has been approved yet.

## 8. Teach by making

The 1965 manual taught through complete programs, running them, seeing mistakes, correcting them, listing them, and saving them.

BASIC# beginner documentation should follow:

```text
Make something.
Run it.
See what happened.
Change one thing.
Run it again.
```

The formal specification is for compiler development. Beginners should meet working examples first.

---

# What BASIC# should not copy from traditional BASIC

Do not recommend bringing back:

```text
line numbers
GOTO
GOSUB
cryptic variable names
A$
DIM
file channel numbers
dense mathematical punctuation
errors like ILLEGAL FORMULA IN 5
```

Traditional BASIC was easy for its hardware and era.

BASIC# should preserve the invitation to ordinary people while replacing the ancient machinery.

---

# Project rules

- The project owner is the final decision-maker.
- Do not build or change code from an inferred approval.
- Do not rename the repository or language files without explicit approval.
- Every build uses the next unused numeric version.
- Every version surface must match.
- Changed-files-only ZIP is the normal package format.
- Documentation is required for every build.
- Tests and warnings must be clean.
- A build handshake and cumulative handoff are required.
- Rejected builds are not accepted baselines.
- Git commit and tag happen only after the owner accepts the build.
- Do not add new official words casually.
- Do not reopen settled language rules unless the owner chooses to.

---

# Questions for Copilot

Please answer these directly and honestly.

## 1. Overall design

Does BASIC# currently have a coherent identity as a from-scratch beginner-first language, or does any part of it still feel like disguised conventional programming?

## 2. Simplicity

Which current or planned features are most likely to make BASIC# too technical for a child or complete beginner?

## 3. Runtime direction

Is the current path from source to BSharp IR to runtime to later bytecode and VM technically sound?

## 4. Ruby bootstrap

What should be done now to ensure Ruby remains temporary scaffolding and does not leak its assumptions into BASIC#?

## 5. Self-hosting

What capabilities must BASIC# gain before rewriting its compiler in BASIC# becomes realistic?

Do not argue that self-hosting is unnecessary. It is a long-term project goal.

## 6. Trigger context

Review the v0.0.10 idea:

```text
WHEN
[player attacks a guard
<then> (damage that guard].
```

What edge cases must be solved without exposing technical concepts to the creator?

## 7. Kind families

What is the safest simple behavior for:

```text
KINDS
[creature is a thing
dragon is a creature
wyrm is a dragon].
```

How should wrong or circular Kind families be explained to a beginner?

## 8. Error messages

Suggest a consistent beginner-friendly format for compiler and runtime errors.

## 9. Historical BASIC ideas

Which of these ideas should eventually enter the roadmap?

- ASK-style introspection
- visible execution tracing
- runtime recovery
- internal modules hidden from the creator
- capitalization tolerance
- spacing tolerance
- teaching by tiny complete examples

## 10. Next build

v0.0.10 has been built but not yet user-validated.

After it is validated and accepted, what should v0.0.11 logically be?

Choose one tightly scoped build. Do not propose a giant rewrite.

## 11. Missing foundation

Is there any essential language-construction step missing from the roadmap before bytecode and the VM?

## 12. Final verdict

Give a blunt assessment:

- what is strong
- what is weak
- what is premature
- what should happen next
- what should be protected at all costs

Remember:

> The compiler and engine do the heavy lifting. The creator enjoys the ride.
