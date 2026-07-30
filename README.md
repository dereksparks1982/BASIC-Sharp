# BASIC# / DKScript Ruby Bootstrap Compiler v0.1.13

**Public language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Current technical bootstrap name:** DKScript

> A scripting language made for non-programmers, by non-programmers.

BASIC# is being built from scratch for people who do not already think like programmers. The creator describes what exists and what should happen. The compiler, runtime, future virtual machine, and engine carry the mechanical weight.

> The compiler and engine do the heavy lifting. The creator enjoys the ride.

The repository, command names, Ruby module names, package prefix, and current compiler banner remain `DKScript` in v0.1.13. Their technical rename remains a separate owner-approved migration.

## Current language shape

```text
KINDS
[dragon is a creature].

DEFINE
[a dragon named ember].

START
[ember is calm].

WHEN
[player attacks ember
<then> (damage ember].
```

The opening `[` belongs directly against the first Body word.

The opening `(` in an official word such as `(damage` is a creator-facing visual guide. It marks the point where BASIC# tells the world to do something. It was not added merely for compiler convenience.

```text
player attacks ember   what happened
<then>                 connects what happened to what follows
(damage ember          what BASIC# tells the world to do
```

## Current Heads

```text
KINDS
DEFINE
START
WHEN
IF
```

## Current official words

```text
(damage
(change
(carry
(unlock
```

The official word is `(damage`. A name such as `ember` follows it because the word needs to know which defined Thing it applies to.

## Compile the sample

```bash
ruby compiler/dks.rb samples/first_room.dks
```

## Run a Kind Trigger with a plain-language trace

```bash
ruby compiler/dks.rb samples/first_room.dks --run "player attacks henry"
```

Example trace:

```text
what matched:
  player attacks a guard
what I understood:
  a guard means henry
  that guard means henry
what happened:
  (damage henry
  henry damage is now 1
  (change henry to angry
  henry is now angry
```

## Run an exact event

```bash
ruby compiler/dks.rb samples/first_room.dks --run "player attacks ember"
```

## Run an existing DKIR file

```bash
ruby compiler/dks.rb samples/first_room.ir.json --run "player attacks henry"
```

Source and saved DKIR must produce the same trace and the same world.

## Run the normal test suite

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

## Run the focused runtime stress test

```bash
ruby tools/runtime_stress.rb
```

Default stress load:

```text
504 Things
10,002 events through source-built DKIR
10,002 events through saved DKIR
20,004 total event executions
```

The stress runner verifies:

- hundreds of defined Things;
- exact and direct-Kind Triggers together;
- repeated `(damage` and `(change`;
- `(carry` and startup `(unlock`;
- selected-Thing context staying inside one event;
- no state leaking between separate runtimes;
- deterministic results;
- source and saved-DKIR parity;
- unknown-Thing and wrong-Kind explanations.

Optional larger or smaller loads:

```bash
BASIC_SHARP_STRESS_GUARDS=500 \
BASIC_SHARP_STRESS_DRAGONS=250 \
BASIC_SHARP_STRESS_EVENTS=20000 \
ruby tools/runtime_stress.rb
```

These are developer stress controls, not BASIC# language syntax.

## DKIR contract

The first formal DKIR meaning contract is:

```text
docs/ir/DKIR_MEANING_CONTRACT_v0_1_13.md
```

DKIR remains readable debug JSON, not final bytecode. Ruby objects and Ruby conveniences are not allowed to define BASIC# meaning.

## What v0.1.13 adds

- Focused runtime stress testing.
- A reusable runtime stress runner.
- More than four thousand automated assertions.
- Duplicate Thing protection for manually altered DKIR.
- DKIR format and top-level list validation.
- A formal DKIR meaning contract.
- Claude review decision record.
- Lisp research relevant to BASIC#.
- The official-word visual-guide rule for `(`.
- No new creator syntax.
- No new official words.
- No Kind Families yet.

## Not included

- No multiple selected Things.
- No event queue.
- No values-and-amounts language feature.
- No time or repetition language feature.
- No ASK implementation.
- No capitalization or source-spacing behavior change.
- No bytecode, VM, DK Engine, or self-hosting implementation.
- No technical rename from DKScript to BASIC#.

## v0.1.13 corrected package status

The accepted base is:

```text
v0.1.12
commit 25c9265
tag v0.1.12
```

Earlier v0.1.13 archives are rejected. One passed the full runtime and stress tests but incorrectly included unchanged v0.1.12 files.

Use only:

```text
DKScript_Ruby_Bootstrap_Compiler_v0_1_13_FOCUSED_RUNTIME_STRESS_TEST_AND_CONTRACT_HARDENING_CORRECTED_CHANGED_FILES_ONLY.zip
```

Restore the repository to `v0.1.12` before applying it. Do not commit or tag v0.1.13 until the corrected archive passes owner-side validation.

Audit record:

```text
docs/audit/DKSCRIPT_v0_1_13_REJECTED_PACKAGE_AUDIT.md
```

Tomorrow/new-thread continuation:

```text
docs/hand_off/DKSCRIPT_v0_1_13_NEW_THREAD_HANDOFF.md
```
