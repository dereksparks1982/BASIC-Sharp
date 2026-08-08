# BASIC# Build Handshake v0.1.48

## Identity

- Version: v0.1.48
- Title: Tokenizer/Reader Implementation Under Ruby Referee
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_48_TOKENIZER_READER_IMPLEMENTATION_CHANGED_FILES_ONLY.zip`

## Required base

- Version: v0.1.47
- Commit: `3e0832f052b91507cfd0615be44e65960f38740f`
- Tag: `v0.1.47`
- Branch: `main`
- Working tree: clean

## Scope

This build adds the first BASIC# tokenizer/reader implementation file and locks it under Ruby referee validation.

## Added behavior

- `compiler/tokenizer_reader.rb` produces deterministic reader records, token records, and issue records.
- Reader records are compared against the existing Ruby `Lexer` referee.
- The implementation is tested and sealed by the Trial-by-Fire inventory.

## Explicit exclusions

No production parser migration, Profile 8, new syntax, runtime behavior change, BSharp IR change, BSharp Bytecode change, Save/ASK change, input-device change, web export, browser work, engine bridge, OpenAI outreach, or Ruby retirement.

## Rollback

The installer verifies the exact v0.1.47 base before mutation. If validation fails after mutation, it restores every modified v0.1.47 file and removes every added v0.1.48 path.

## Acceptance

v0.1.48 is accepted only after Derek's machine reports installer PASS, then Derek commits the tree and tags `v0.1.48`.
