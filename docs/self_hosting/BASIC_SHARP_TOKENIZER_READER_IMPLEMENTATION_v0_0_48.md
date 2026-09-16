# BASIC# Tokenizer and Reader Implementation v0.0.48

**Build:** v0.0.48  
**Status:** Implementation under Ruby referee  
**Spec:** `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`  
**Self-hosting foundation:** `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`  
**Implementation:** `compiler/tokenizer_reader.rb`

## Purpose

v0.0.48 begins the first BASIC# tokenizer/reader implementation on the self-hosting runway.

This is not Ruby retirement. The existing Ruby `compiler/lexer.rb` and `compiler/parser.rb` remain the production authority. The new implementation exists beside them and must prove that its reader records match the Ruby referee before any later build can route compiler work through it.

## Implemented records

The implementation exposes three deterministic record groups:

```text
reader_records
  line number, raw comment-stripped line, and trimmed text

token_records
  first future-facing token records for Heads, Body boundaries,
  result markers, action words, quoted text, and ordinary Body lines

issues
  comment and reader issues mirrored from the Ruby Lexer referee
```

## Ruby referee rule

Every fixture in `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json` is read two ways:

```text
Ruby Lexer referee
compiler/tokenizer_reader.rb implementation
```

The reader records must match exactly. If they do not, the implementation is wrong. Ruby remains the referee.

## Token records in this build

v0.0.48 implements these token kinds only:

```text
head
body_open
body_close
body_line
result_line
result_marker
action_word
quoted_text
```

These records are future-facing and deterministic. They do not create new syntax. They do not change parser behavior. They do not authorize Profile 8.

## Explicit non-authority

`compiler/tokenizer_reader.rb` is not the production parser authority in v0.0.48.

The existing parser still uses the existing Ruby `Lexer` directly. This build creates a checked implementation under referee supervision, not a parser migration.

## Exclusions

No Profile 8.

v0.0.48 does not include:

- Profile 8;
- new creator-facing syntax;
- loops, functions, reusable words, collections, interpolation, or multiline text;
- runtime behavior changes;
- BSharp IR changes;
- BSharp Bytecode changes;
- Save or ASK changes;
- input-device behavior changes;
- web export;
- browser work;
- engine bridge work;
- Ruby retirement;
- self-hosting claims.

## Acceptance

v0.0.48 is accepted only when:

1. the complete test suite passes;
2. `tools/tokenizer_reader_contract.rb` passes;
3. the Trial-by-Fire validation inventory includes the implementation files;
4. the full native Trial-by-Fire gauntlet passes;
5. Derek commits the exact accepted tree and tags `v0.0.48`.
