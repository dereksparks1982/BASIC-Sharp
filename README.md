# BASIC# Ruby Bootstrap Compiler v0.1.17

**Language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Ruby namespace:** `BasicSharp`  
**Creator source extension:** `.bsharp`

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists and what should happen without first becoming a conventional programmer. The compiler and runtime carry the mechanical weight.

v0.1.17 makes existing `IF` rules reactive. An IF rule now wakes when its condition changes from false to true after START or after a complete matched WHEN action list.

## Reactive IF example

```text
DEFINE
[a creature named ember
 a door named north door].

START
[ember is calm
 north door is locked].

WHEN
[player attacks ember
<then> (change ember to angry].

IF
[ember is angry
<then> (unlock north door].
```

Running `player attacks ember` changes Ember first. BASIC# then settles eligible IF rules and unlocks the north door.

A true IF does not repeat after every unrelated event. It re-arms only after its condition becomes false, and it may wake again on a later false-to-true transition.

## Execution order

```text
Create Things
Apply START information
Settle IF rules
Receive one event
Run the complete matched WHEN action list
Settle IF rules
Report the result
```

BASIC# never checks IF halfway through a multi-action WHEN body.

## Loop protection

Mutually waking IF rules are stopped deterministically. The runtime reports the recent condition trail in plain language and keeps the current world state visible instead of hanging or exposing a Ruby stack trace.

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

## Compile the sample

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
```

## Run the reactive sample path

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks cinder"
```

The inherited creature Trigger changes Cinder to angry. The reactive IF then damages the player.

## Run the complete test suite

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

Current validated floor:

```text
95 runs
4,546 assertions
0 failures
0 errors
0 skips
```

## Stress lanes

```bash
ruby tools/runtime_stress.rb
ruby tools/kind_family_stress.rb
ruby tools/if_rule_stress.rb
```

The focused IF lane proves a 128-rule cascade, 1,000 unrelated events after settling, 100 false-to-true reactivation cycles, source and saved-DKIR parity, runtime isolation, deterministic replay, and loop protection.

Timing is observational only. A slower correct machine does not fail.

## Saved-DKIR compatibility

Valid accepted fixtures from v0.1.13, v0.1.15, and v0.1.16 remain executable.

## Company Bible

The complete imported DK LAB Company Bible set is stored at:

```text
docs/company_bible/
```

Read it end-to-end before proposing or building the next BASIC# version.

## Contracts

```text
docs/parser_contract_v0_1_17.md
docs/runtime_contract_v0_1_17.md
docs/ir/DKIR_MEANING_CONTRACT_v0_1_17.md
```

## Not included

- No `OTHERWISE`, `AND`, or `OR`.
- No multi-condition IF syntax.
- No numeric comparisons, values, or amounts.
- No Kind selectors or `that Kind` inside IF.
- No event queue, time system, repetition syntax, save/load, ASK, bytecode, VM, engine bridge, or self-hosting work.
