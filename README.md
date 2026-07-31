# BASIC# Ruby Bootstrap Compiler v0.1.21

**Language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Safe written form:** BSharp  
**Ruby namespace:** `BasicSharp`  
**Creator source extension:** `.bsharp`  
**Intermediate representation:** BSharp Intermediate Representation, normally **BSharp IR** or **BSIR**

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists and what should happen without first becoming a conventional programmer. The compiler and runtime carry the mechanical weight.

## v0.1.21 follow-up events

v0.1.21 adds explicit follow-up events through `(cause`. A creator can now finish one event body, settle reactive IF rules, and deliberately make another event happen next.

```text
DEFINE
[a guard named henry
 a guard named mara
 a device named brass bell].

START
[henry is calm
 mara is calm].

WHEN
[player attacks a guard
<then> (damage that guard
<then> (cause that guard attacks player
<then> (change that guard to angry].

IF
[henry is angry
<then> (cause mara sounds brass bell].

WHEN
[a guard attacks player
<then> (damage player].
```

When the player attacks Henry, BASIC# performs the complete first body, settles IF rules, then runs the caused events.

```text
player attacks henry
-> damage henry
-> prepare henry attacks player
-> change henry to angry
-> settle IF rules
-> prepare mara sounds brass bell
-> run henry attacks player
-> run mara sounds brass bell
```

## Deterministic event order

BASIC# uses this fixed order:

```text
1. Match one WHEN rule.
2. Finish its complete action list in source order.
3. Settle reactive IF rules completely.
4. Run the first follow-up event.
5. Settle IF rules again.
6. Continue first-created, first-run until no follow-up events remain.
```

An event caused by a follow-up event joins the end of the existing line. It does not jump ahead of events already waiting.

## `(cause` is explicit

```text
(cause henry attacks player
```

Damage, state changes, carrying, and unlocking do not secretly invent events. A new event happens only when the creator writes `(cause`.

A caused event must identify specific Things by name or use a singular `that Kind` selected by the current WHEN:

```text
(cause that guard attacks player
```

`every Kind` is not supported inside `(cause` in this build.

## Failed bodies discard staged events

A caused event waits until its complete action body succeeds. If a later action in the same body fails, the staged event is discarded and the trace says why. World changes that already completed keep their existing accepted behavior.

A runtime error inside a follow-up event stops later waiting events. An event that simply matches no WHEN rule is not a fatal error, so later waiting events continue.

## Event-loop protection

One externally supplied event may run at most 1,024 follow-up events. BASIC# stops a self-feeding chain with:

```text
Events kept causing more events.

BASIC# stopped this chain after 1,024 follow-up events so it would not run forever.
```

The human trace remains bounded while structured results retain every event that actually ran.

## Compiler flow

```text
BASIC# source
    -> Ruby bootstrap parser and resolver
    -> BSharp IR debug document
    -> BASIC# runtime
    -> deterministic world changes and plain-language trace
```

## Current language foundation

- `KINDS`, `DEFINE`, `START`, `WHEN`, and `IF` Heads.
- Things and inherited Kind families.
- Exact and Kind-based event matching.
- Singular `that Kind` event context.
- `every Kind` deterministic action selections.
- Reactive IF rules with re-arming, cascades, and loop protection.
- Explicit follow-up events with deterministic first-created, first-run order.
- Whole-number Thing values from 0 through 2,147,483,647.
- Default and explicit damage amounts.
- Exact value assignment.
- Exact-value IF conditions.
- Atomic set validation for missing values and overflow.
- Damage and health remain independent unless a creator explicitly connects them.

## Current executable official words

```text
(damage
(change
(carry
(unlock
(cause
```

## Compile samples

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/every_guard.bsharp
ruby compiler/basic_sharp.rb samples/values_and_amounts.bsharp
ruby compiler/basic_sharp.rb samples/follow_up_events.bsharp
```

## Emit BSharp IR

```bash
ruby compiler/basic_sharp.rb samples/follow_up_events.bsharp \
  --emit-ir \
  --out samples/follow_up_events.bsir.json
```

A current debug document begins with:

```json
{
  "version": "0.1.21",
  "format": "bsir.debug.json"
}
```

## Run source or saved BSIR

```bash
ruby compiler/basic_sharp.rb samples/follow_up_events.bsharp --run "player attacks henry"
ruby compiler/basic_sharp.rb samples/follow_up_events.bsir.json --run "player attacks henry"
```

## Retired DKIR files

There is no DKIR compatibility layer. A retired-format document receives exactly:

```text
This file uses the retired DKIR format.
BASIC# v0.1.20 uses BSharp IR.
Recompile the original .bsharp source to create a new BSIR file.
```

Recompile the original `.bsharp` source to create a current `.bsir.json` file.

## Validation

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

Current validated floor:

```text
157 runs
4,841 assertions
0 failures
0 errors
0 skips
```

Stress lanes:

```bash
ruby tools/runtime_stress.rb
ruby tools/kind_family_stress.rb
ruby tools/if_rule_stress.rb
ruby tools/multiple_selection_stress.rb
ruby tools/value_amount_stress.rb
ruby tools/follow_up_event_stress.rb
```

The follow-up-event lane proves a 386-event ordered chain, direct and nested first-created/first-run behavior, IF ordering, unmatched continuation, captured context, source/saved-BSIR parity, deterministic replay, runtime isolation, the 1,024-event boundary, and bounded human trace.

Timing is observational only. A slower correct machine does not fail.

## Company Bible

The imported DK LAB Company Bible is stored under:

```text
docs/company_bible/
```

Read it end-to-end before proposing or building another BASIC# version. Those imported files preserve their historical names and are not active BASIC# component branding.

## Current contracts

```text
docs/parser_contract_v0_1_21.md
docs/runtime_contract_v0_1_21.md
docs/ir/BSIR_MEANING_CONTRACT_v0_1_21.md
```

## Not included

- No automatic events from damage, change, carry, or unlock.
- No `every Kind` caused events.
- No delayed, timed, prioritized, parallel, or scheduled events.
- No negative numbers, decimals, fractions, percentages, or arithmetic expressions.
- No greater-than, less-than, ranges, AND, or OR.
- No save/load or ASK system.
- No bytecode or virtual machine.
- No GUI editor or IDE.
- No game-engine bridge.
- No self-hosting compiler.
