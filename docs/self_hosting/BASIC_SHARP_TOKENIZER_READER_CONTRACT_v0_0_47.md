# BASIC# Tokenizer and Reader Contract v0.0.47

**Status:** contract only  
**Build:** v0.0.47
**Parent self-hosting spec:** `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`  
**Spec:** `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`  
**Tool:** `tools/tokenizer_reader_contract.rb`

## Purpose

v0.0.47 freezes the first self-hosting tokenizer/reader contract without replacing the Ruby bootstrap compiler.

The goal is to define how BASIC# source text becomes deterministic reader records before any future BASIC# implementation attempts to read the language by itself.

This is the next plank after the v0.0.44 self-hosting foundation and the v0.0.46 movement/input lane.

## Reader record

The accepted reader record has three visible fields:

```text
number = one-based source line number
raw    = comment-stripped source line without the trailing newline
text   = raw line trimmed at both ends
```

Blank `text` lines are omitted. Line numbers remain the original source line numbers.

## Comment law

BASIC# comments remain governed by the current Ruby bootstrap reader until a later implementation earns parity.

- `//` opens a BASIC# block comment when outside quoted text.
- `/.` closes a BASIC# block comment when outside quoted text.
- Commented characters are replaced with spaces so later columns stay stable.
- Newlines inside comments are preserved.
- `//` and `/.` inside quoted text are not comment markers.
- A closing marker without an open comment is a reader issue.
- A nested opening marker is a reader issue.
- An unclosed comment is a reader issue that names the opening line and column.

## Current Heads

The current Head words remain:

```text
KINDS
DEFINE
START
WHEN
IF
OTHERWISE
CONTROLS
HOVER
CONTEXT
```

The tokenizer/reader contract does not add a Head, alias, punctuation rule, Body shape, action word, condition, event, or runtime meaning.

## Future token records

A later implementation may produce deterministic token records, but only after Ruby referee comparison exists.

Future token records must preserve:

- token kind;
- one-based line;
- one-based column;
- exact creator-facing text;
- canonical normalized form only where an accepted existing rule already defines one.

## Explicit exclusions

This build does not:

- replace `compiler/lexer.rb` or `compiler/parser.rb`;
- claim BASIC# is self-hosted;
- add Profile 8;
- add creator-facing syntax;
- add loops, functions, reusable words, collections, interpolation, or multiline text;
- change BSharp IR, BSharp Bytecode, Save format, ASK, runtime behavior, input devices, graphics, engine bridge, browser work, or Ruby retirement.

## Acceptance

v0.0.47 is accepted only when:

1. `tools/tokenizer_reader_contract.rb` passes;
2. `tests/test_tokenizer_reader_contract.rb` passes;
3. the Trial-by-Fire validation inventory includes the new tool and test;
4. all existing Profiles 1 through 7 behavior remains validated.
