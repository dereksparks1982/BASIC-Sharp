# BASIC# Small Compiler Subset Parser v0.1.49

**Build:** v0.1.49  
**Lane:** Small Compiler Subset Parser Under Ruby Referee

## Purpose

v0.1.49 adds the first small compiler subset parser implementation for the self-hosting runway. It parses deterministic subset records from `compiler/tokenizer_reader.rb` reader records, then compares those records against the existing Ruby Parser referee.

This build does not make BASIC# self-hosted. The existing Ruby parser remains the production parser authority.

## Added implementation

`compiler/small_compiler_subset_parser.rb` reads accepted source shape through TokenizerReader and records:

- accepted Head words
- Head detail for `WHEN`, `IF`, `CONTROLS`, `HOVER`, and `CONTEXT`
- Body open and Body close line locations
- Body child text
- accepted `|then` result markers
- official action words such as `(change` and `(say`

The output format is `bsharp.small_compiler_subset.parser.record`.

## Ruby Parser referee

The subset parser must match the existing Ruby Parser referee for the approved fixture structures. This protects the project from pretending the new parser is authoritative before it has earned that role.

## Not the production parser authority

`compiler/small_compiler_subset_parser.rb` is not the production parser authority in v0.1.49. Normal compilation still routes through `compiler/parser.rb`.

## Exclusions

No Profile 8, no new creator-facing syntax, no runtime behavior change, no BSharp IR change, no BSharp Bytecode change, no Save or ASK change, no input-device behavior change, no web export, no browser work, no engine bridge, and no Ruby retirement.

## Acceptance

v0.1.49 is accepted only when:

1. `tools/small_compiler_subset_parser.rb` passes.
2. `tests/test_small_compiler_subset_parser.rb` passes.
3. Existing tokenizer/reader, self-hosting, Company Bible, and Trial-by-Fire inventory gates pass.
4. The full native Trial-by-Fire gauntlet passes on Derek's machine.
5. Derek commits the exact accepted tree and tags `v0.1.49`.

## Governing self-hosting spec

This lane is carried by `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json` and its build-specific parser spec `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json`.

## v0.1.58 continuation

The parser lane is the required input for the next self-hosting bridge record: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`. The v0.1.58 emitter may consume parser records, but the parser remains non-production and Ruby remains the referee.
