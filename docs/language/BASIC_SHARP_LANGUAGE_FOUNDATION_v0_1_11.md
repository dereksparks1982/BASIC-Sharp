# BASIC# Language Foundation v0.1.11

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Name

The owner-selected public language name is:

```text
BASIC#
```

It is pronounced:

```text
Basic Sharp
```

The language stands on its own. The engine may retain its own name, but the language does not require a DK prefix.

The current repository and Ruby bootstrap still use the historical `DKScript` technical name. That technical rename is not part of v0.1.11.

## Purpose

BASIC# exists so a person can create with a computer without first becoming a computer mechanic.

A driver can:

- learn the controls;
- understand what the warning lights mean;
- perform simple repairs;
- enjoy the ride;

without designing the transmission.

BASIC# applies the same principle to programming:

```text
creator writes what should happen
compiler understands and checks it
runtime carries it out
engine handles the machinery
creator enjoys the result
```

## Surface rule

The creator-facing language must remain:

- readable;
- direct;
- consistent;
- forgiving where forgiveness does not create ambiguity;
- explainable without compiler jargon;
- predictable in the same situation.

The machinery underneath may be complex. That complexity does not belong in the creator's lesson.

## Current working example

```text
KINDS
[guard is a person].

DEFINE
[a guard named henry].

WHEN
[player attacks a guard
<then> (damage that guard].
```

A beginner should be able to understand the cause and effect without learning terms such as binding, scope, dispatch, or lowering.

## Settled rules carried forward

- A Body opens against its first word: `[guard`, not a separate `[` line.
- `].` closes the Body and ends the Head.
- `<then>` and `<than>` mean exactly the same thing.
- `there` and `their` mean exactly the same thing where that language rule applies.
- `<then>` is a Connector, not the result.
- `(damage` is an official word.
- Do not invent compound teaching terms such as `action target`.
- User-created Kinds and Things must be declared before the compiler can use them.
- No new official word enters the language without an explicit language decision.

## Error rule

A BASIC# error should tell the creator:

1. what the compiler understood;
2. what it could not understand;
3. where the problem is;
4. how to repair it.

Example:

```text
I do not know what “wyrm” means.

You used it here:
[a wyrm named ember].

Tell me what a wyrm is in KINDS first.
```

## Self-hosting direction

Ruby is temporary scaffolding.

The long road remains:

```text
Ruby bootstrap compiler
-> BASIC# compiler and runtime
-> bytecode
-> BASIC# virtual machine
-> BASIC# standard capabilities
-> BASIC# compiler written in BASIC#
```

BASIC# will not inherit Ruby syntax merely because Ruby is currently building the first compiler.

## Protection

v0.1.11 records the identity and doctrine. It does not perform the technical rename and it does not add syntax.
