# BASIC# Validation v0.0.48

## Build

- Version: v0.0.48
- Title: Tokenizer/Reader Implementation Under Ruby Referee
- Required base: v0.0.47 commit `3e0832f052b91507cfd0615be44e65960f38740f`
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_0_48_TOKENIZER_READER_IMPLEMENTATION_CHANGED_FILES_ONLY.zip`

## Local candidate validation

Candidate validation was run in the build workspace with Ruby 3.3.8 and UTF-8 locale.

```text
Ruby syntax: PASS
JSON parsing: PASS
complete test suite: PASS (468 runs, 8089 assertions, 0 failures, 0 errors, 0 skips)
tools/tokenizer_reader_contract.rb: PASS
tools/self_hosting_contract.rb: PASS
tools/company_bible_audit.rb: PASS
```

The hosted workspace could not complete the full native Trial-by-Fire gauntlet inside the available execution window. The installer remains configured to run the full native gauntlet on Derek's machine.

Confirmed build-specific gates:

```text
compiler/tokenizer_reader.rb syntax: PASS
tools/tokenizer_reader_contract.rb syntax: PASS
tests/test_tokenizer_reader_contract.rb: PASS
tests/test_tokenizer_reader_implementation.rb: PASS
Ruby Lexer referee comparison: PASS
Tokenizer/reader implementation token records: PASS
Parser authority unchanged: PASS
No Profile 8, syntax, runtime, web export, or browser work: PASS
```

A reduced-count Trial-by-Fire smoke gauntlet passed in the build workspace:

```text
Counts: events=100/path frames=100 ASK=100 saves=10 worlds=8 programs=8 mutations=16/boundary
results_sha256: 1ed5c61ea8b1d6c793fa47aca6903e573756552a4c551edf45bf718c391d97b4
BASIC# v0.0.48 TRIAL BY FIRE: PASS
```

## Version-bearing fixture hashes

```text
Text-value Save:       da2a35af163cf07fb4a951ebe5f8f5c6807c19db45e2a35f26f8c46c5f6319ce
Number-change result: f13edee43c0fa64fa2956719032a81895d0b4b853d170da6436c962b1c706117
Compound-IF result:   acb9f8ce8924dc7fe680ea4067c6036ba00ddc0e282dfbc5870d9cd0db027980
OTHERWISE result:     5a9a3e55d871fad34e24a569e7c6ab4c7b632d57a357bb08ca022daf796ffe74
Trial-by-Fire BSIR:   2874918eaf23a9147e8069c6f926d0da902adbc8e81a98d59e02230e472fd763
```

## Owner-side required validation

Derek's installer must run from exact clean v0.0.47 commit `3e0832f052b91507cfd0615be44e65960f38740f` and tag `v0.0.47`.

The package is not accepted until the installer reports full native PASS on Derek's machine.
