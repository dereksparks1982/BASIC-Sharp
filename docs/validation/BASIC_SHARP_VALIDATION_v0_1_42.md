# BASIC# Validation v0.1.42

## Sealed native gate

- Exact accepted base: commit `066e715`, tag `v0.1.39`, clean `main`.
- Exact discovered suite: 448 tests.
- Native floor: 448 runs and 8,012 assertions.
- Required result: zero failures, errors, skips, warnings, and stderr.
- Required tools and hashes: `spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json`.
- Required full gauntlet counts: 100,000 events per path; 100,000 frames; 25,000 ASK questions; 1,000 checkpoints; 256 worlds; 256 generated programs; 2,048 mutations per artifact boundary; follow-up boundaries 1,023/1,024/1,025; every principal BSBC prefix.

## Failed native evidence

v0.1.40 passed the complete 448-run/8,012-assertion suite and every required phase before `tools/text_value_stress.rb`. That gate correctly rejected a stale v0.1.39 Save hash, and automatic rollback restored exact v0.1.39.

v0.1.41 passed the repaired text-value stress gate and all preceding phases, then `tools/number_change_stress.rb` correctly rejected its stale v0.1.39 expected result. Audit proved number changes, compound IF, and OTHERWISE each differed only in the version-owned `created_by_basic_sharp` field. Automatic rollback again restored exact v0.1.39.

## v0.1.42 workspace evidence

The complete four-fixture regeneration produced:

```text
Text-value Save:       b0e2436d54335e068a41c1cd0666a1696c8aa5fe0be75c76a9b22f7fc4f1b5ef
Number-change result: ed76938a393bdfd700c9ef2e1dbad78f0aedc472da70ba7437690a04f3a5e47a
Compound-IF result:   00da07fa749683b8a7d2bb45e655bd769fa1840762984cbf45ee9e2308f51970
OTHERWISE result:     a0f0a83b09794d9eff9231a357f287d38ae6aa863df10f54f88997718834adea
```

Ruby-WASM passed all four owning stress tools at full defaults: 10,000 text events per runtime path, 25 shadow-parity events, 100 typed Save/restore cycles, 10,000 increases plus 10,000 decreases, 5,000 compound-IF cycles, and 10,000 OTHERWISE cycles. No fixture validator was weakened or skipped.

The v0.1.42 preflight passed all 256 generated programs across Profiles 1–7 with results SHA-256 `0fceb3a61153a7df835948dbdb9d667effa9571dc1c912cc1edce1123eadfd22`. It also rejected all 8,192 hostile artifacts and all 3,040 truncated principal BSBC prefixes in bounded Ruby-WASM processes. The 16 non-prefix focused tests passed with 16 assertions, zero failures, errors, or skips; the prefix test was proven separately across the complete 3,040-prefix set. All 14 protected Profile 1–7 artifact hashes match v0.1.39.

WASI cannot execute 35 existing native process/filesystem tests (`Open3`, atomic replace, and host `chdir`). Native Ruby is unavailable in the build workspace, so this document does not claim owner acceptance.

## Acceptance rule

Only the v0.1.42 changed-files installer’s complete native rerun on Derek’s machine may accept the candidate. It must rerun the entire gauntlet from the beginning. Any failure restores v0.1.39 exactly. After PASS, Derek commits and tags v0.1.42 and creates the accepted full-project snapshot.
