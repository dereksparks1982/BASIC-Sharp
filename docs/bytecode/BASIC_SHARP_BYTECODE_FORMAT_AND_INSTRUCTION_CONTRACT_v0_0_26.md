# BASIC# BSharp Bytecode Format and Instruction Contract v0.0.26

## Normative source

The machine-readable authority is:

```text
spec/bytecode_v1/BASIC_SHARP_BYTECODE_PROFILE_v1.json
```

This document explains that contract. When prose and the machine contract disagree, the candidate is invalid and must be repaired before acceptance.

## Header

The 32-byte little-endian header contains:

```text
0   4  magic = BSBC
4   2  binary format version = 1
6   2  profile format version = 1
8   4  header size = 32
12  4  section count = 8
16  4  section directory offset = 32
20  4  section directory entry size = 16
24  4  complete file size
28  4  reserved flags = 0
```

Each directory entry contains one four-character section identity, offset, length, and record count.

## Instruction record

```text
opcode:u8
operand_count:u8
reserved_zero:u16
operands:u32[]
```

CODE block boundaries are defined by the block directory. Diagnostic `END` is not an opcode.

## Starting-world instructions

```text
0x10 START_STATE
0x11 START_RELATION
0x12 START_VALUE
```

## Action instructions

```text
0x20 DAMAGE
0x21 CHANGE_STATE
0x22 CHANGE_VALUE
0x23 CARRY
0x24 UNLOCK
0x25 CAUSE_EVENT
```

Every instruction has a fixed operand list in the machine contract. Whole numbers are limited to 0 through 2,147,483,647.

## Selectors

```text
0x01 EXACT_THING
0x02 ONE_KIND
0x03 BOUND_THAT_KIND
0x04 EVERY_KIND
0xFF NO_REFERENCE
```

Selector contexts are explicit. A selector legal in a WHEN pattern is not automatically legal for a multi-target action.

## IF condition operators

```text
0x30 STATE_IS
0x31 STATE_ISNT
0x32 RELATION_EXISTS
0x33 VALUE_EQUALS
```

Reactive active-state bookkeeping belongs to the runtime world, not the immutable program bytecode.

## Execution meaning

The future VM must preserve Profile 1 event priority, inherited Kind matching, definition-order selections, singular `that Kind`, action-line ordering, false-to-true IF behavior, IF rearming, IF settlement before follow-up events, first-created first-run event order, and the 1,024-event guard.

## Rejection

A loader must reject the complete artifact before execution when any identity, size, offset, alignment, section, string, reference, selector, instruction, operand, condition, fingerprint, block boundary, or trailing-data rule is violated. Partial acceptance and partial execution are forbidden.

## Disassembly

Readable disassembly is diagnostic only:

```text
WHEN actor=THING[player] action=attack target=ONE_KIND[guard] BLOCK 3
BLOCK 3
    DAMAGE BOUND_THAT_KIND[guard] 1
    CAUSE_EVENT BOUND_THAT_KIND[guard] attack THING[player]
    CHANGE_STATE BOUND_THAT_KIND[guard] angry REMOVE calm
END
```

It is not creator-facing BASIC# source.
