# BASIC# v0.1.63 UTF-8 Source Reading Contract

## Status

Implemented in v0.1.63 candidate.

## Purpose

BASIC# source files, BSharp IR JSON, BSharp Save JSON, and text fixtures must be read as UTF-8 where the project controls file reads. A minimal/no-locale Ruby environment must not crash when creator text contains non-ASCII characters.

## Proof

The contract runs selected UTF-8-bearing files with:

```text
LC_ALL=C
LANG=
RUBYOPT=-W2
```

The proof includes `samples/text_values.bsharp` and `samples/text_values.bsir.json`, both containing `OPEN — RubyVM!`.

## Guardrails

This hardening does not change creator syntax, parser meaning, runtime meaning, bytecode format, BSBC naming, or Ruby referee authority.

## Files

```text
spec/governance/BASIC_SHARP_UTF8_SOURCE_READING_CONTRACT_v1.json
tools/utf8_source_reading_contract.rb
tests/test_utf8_source_reading_contract.rb
```
