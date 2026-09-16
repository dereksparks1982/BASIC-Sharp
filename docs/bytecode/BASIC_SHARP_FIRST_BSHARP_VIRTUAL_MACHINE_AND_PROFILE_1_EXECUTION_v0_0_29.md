# BASIC# v0.0.29 First BSharp Virtual Machine and Profile 1 Execution

## Purpose

v0.0.29 is the first build that executes validated BSharp Bytecode. The VM is Ruby-hosted bootstrap machinery, but it interprets the trusted BSBC model directly.

```text
.bsharp -> BSIR -> .bsbc -> BytecodeLoader -> BSharp Virtual Machine -> world
```

The VM does not reconstruct BSIR and does not call `BasicSharp::Runtime` to execute instructions.

## Trusted boundary

`BasicSharp::BytecodeVirtualMachine` accepts only a completed `BasicSharp::BytecodeLoader`. Arbitrary hashes and unvalidated bytes are rejected. The loader model remains deeply frozen. Every VM creates its own mutable world.

## Executed Profile 1 records

START:

- `START_STATE`
- `START_RELATION`
- `START_VALUE`

Actions:

- `DAMAGE`
- `CHANGE_STATE`
- `CHANGE_VALUE`
- `CARRY`
- `UNLOCK`
- `CAUSE_EVENT`

Conditions:

- `STATE_IS`
- `STATE_ISNT`
- `RELATION_EXISTS`
- `VALUE_EQUALS`

## Ordering

The VM preserves exact named-Thing matching before inherited-Kind matching, nearest ancestry before farther ancestry, source order for equal distances, Thing definition order for `every Kind`, complete action bodies before IF settlement, and first-created first-run follow-up events.

## Failure behavior

Multiple-Thing value actions preflight the complete selected set before mutation. Missing values and overflow reject that action line atomically. Failed action bodies discard staged follow-up events. IF chains and follow-up chains retain their accepted loop protection.

## CLI

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsbc --run "player attacks cinder"
```

Optional source-meaning verification may be combined with execution:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsbc \
  --against samples/first_room.bsharp \
  --run "player attacks cinder"
```

## Excluded

BSharp Save and ASK through the VM, replacement of the source/BSIR runtime, full VM-scale stress hardening, optimization, JIT, native code, new bytecode profiles, binary-layout changes, and new BASIC# language behavior remain outside v0.0.29.
