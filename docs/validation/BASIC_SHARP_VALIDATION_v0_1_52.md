# BASIC# Validation v0.1.55

## Package validation target

- Version: v0.1.55
- Base: v0.1.51 / `2962fa19b3e452e529ac7166ad3e751bf621cde4`
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_52_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_CHANGED_FILES_ONLY.zip`

## Required native validation

The installer must pass:

- exact commit, tag, branch, and clean tree
- base and payload hashes
- Ruby syntax
- JSON parsing
- sealed validation inventory
- complete test suite
- all tools listed in the Trial-by-Fire validation inventory
- full native Trial by Fire
- manifest scope check

Expected local package candidate floor:

```text
485 runs, 8295 assertions, 0 failures, 0 errors, 0 skips
```

The final source of truth is Derek's native installer PASS.

## Known repaired failure

The first v0.1.55 candidate failed at `tools/text_value_stress.rb` with `Save fixture hash: FAIL` and restored exact v0.1.51. The repaired candidate updates the v0.1.55 text-value Save fixture hash and must pass `tools/text_value_stress.rb` before acceptance.
