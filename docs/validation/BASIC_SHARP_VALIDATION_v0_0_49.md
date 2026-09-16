# BASIC# Validation v0.0.49

## Build

- Version: v0.0.49
- Title: Small Compiler Subset Parser Under Ruby Referee
- Required base: v0.0.48 commit `c67c74251aaa58e4f2fcded1144ea5187eebfb25`
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_0_49_SMALL_COMPILER_SUBSET_PARSER_CHANGED_FILES_ONLY.zip`

## Local candidate validation

Candidate validation was run in the build workspace with Ruby and UTF-8 locale.

```text
Ruby syntax: PASS
JSON parsing: PASS
complete test suite: PASS (473 runs, 8111 assertions, 0 failures, 0 errors, 0 skips)
tools/small_compiler_subset_parser.rb: PASS
tools/tokenizer_reader_contract.rb: PASS
tools/self_hosting_contract.rb: PASS
tools/company_bible_audit.rb: PASS
```

Confirmed build-specific gates:

```text
compiler/small_compiler_subset_parser.rb syntax: PASS
tools/small_compiler_subset_parser.rb syntax: PASS
tests/test_small_compiler_subset_parser.rb: PASS
TokenizerReader input: PASS
Ruby Parser referee comparison: PASS
Production parser authority unchanged: PASS
No Profile 8, syntax, runtime, web export, or browser work: PASS
```

A reduced-count Trial-by-Fire smoke gauntlet passed in the build workspace:

```text
Counts: events=100/path frames=100 ASK=100 saves=10 worlds=8 programs=8 mutations=16/boundary
results_sha256: be2ff26f8642e04a580e9c9f4ad0c3243df41ec1bc75e2eb34395e5242fba041
BASIC# v0.0.49 TRIAL BY FIRE: PASS
```

The hosted workspace does not replace Derek's owner-side full native validation. The installer remains configured to run the full native Trial-by-Fire gauntlet on Derek's machine.

## Version-bearing fixture hashes

```text
Text-value Save:       c0332647e46830575fa0e70645001616b2ecb9306c799e6e456a921a328157aa
Number-change result: ea4a706be3709154de23587844e034d90351e980f113d5f0a97a1887868f93da
Compound-IF result:   add0604276b9fd025d1685201a8268a34a74e4bb890d082ea2c2fb7c208a12ce
OTHERWISE result:     7fa56723fdb6cb3aee4be5d4daa6f3fdd27a441eed41736fed7c4141760f7a80
Trial-by-Fire BSIR:   93212c24f48f1613a8596048fd7c441a1cd02aba564186c53435a0756290ec53
Trial-by-Fire Save:   2bab95985302638a662985fb23a8e6b7ab03307cc99667c543b08e0cf9bb34b6
```

## Owner-side required validation

Derek's installer must run from exact clean v0.0.48 commit `c67c74251aaa58e4f2fcded1144ea5187eebfb25` and tag `v0.0.48`.

The package is not accepted until the installer reports full native PASS on Derek's machine.
