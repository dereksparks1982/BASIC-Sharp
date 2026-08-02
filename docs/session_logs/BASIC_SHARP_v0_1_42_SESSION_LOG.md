# BASIC# v0.1.42 Session Log

## Authorization

Derek approved the exact v0.1.42 corrective scope after the v0.1.41 native installer failed and restored accepted v0.1.39. The correction is a complete re-carry, not a partial continuation and not reuse of either failed version number.

## v0.1.40 native failure

- The installer verified exact commit `066e715`, tag `v0.1.39`, branch `main`, clean tree, and package hashes.
- Ruby syntax, JSON, sealed inventory, 448 runs, 8,012 assertions, and every phase before text-value stress passed.
- `tools/text_value_stress.rb` rejected a Save fixture still stamped for v0.1.39.
- The installer automatically restored exact v0.1.39. v0.1.40 remained unaccepted.

## v0.1.41 native failure

- The v0.1.41 installer again verified the exact base and installed 18 modified plus 28 added paths.
- The complete 448-run, 8,012-assertion suite passed, as did the repaired full-default text-value gate and every preceding required phase.
- `tools/number_change_stress.rb` then rejected its expected runtime result.
- Independent reproduction proved number-change behavior differed only at `$.save.created_by_basic_sharp`, from `0.1.39` to `0.1.41`.
- Complete downstream audit found compound IF and OTHERWISE carried the same stale version stamp and would have failed later.
- The installer automatically restored exact v0.1.39. v0.1.41 remained unaccepted.

## Work completed

- Re-carried the complete Trial-by-Fire scope from exact accepted `066e715 / v0.1.39` as v0.1.42.
- Regenerated the complete known version-sensitive runtime-fixture set together.
- Sealed text-value Save hash `b0e2436d54335e068a41c1cd0666a1696c8aa5fe0be75c76a9b22f7fc4f1b5ef`.
- Regenerated number-change expected result hash `ed76938a393bdfd700c9ef2e1dbad78f0aedc472da70ba7437690a04f3a5e47a`.
- Regenerated compound-IF expected result hash `00da07fa749683b8a7d2bb45e655bd769fa1840762984cbf45ee9e2308f51970`.
- Regenerated OTHERWISE expected result hash `a0f0a83b09794d9eff9231a357f287d38ae6aa863df10f54f88997718834adea`.
- Passed all four repaired stress gates at their full defaults in Ruby-WASM.
- Passed all 256 deterministic generated programs with results SHA-256 `0fceb3a61153a7df835948dbdb9d667effa9571dc1c912cc1edce1123eadfd22`.
- Rejected all 8,192 hostile source/BSIR/Save/BSBC artifacts and all 3,040 truncated principal BSBC prefixes in bounded Ruby-WASM processes.
- Passed the 16 non-prefix focused Trial-by-Fire tests with 16 assertions and zero failures, errors, or skips.
- Added the canonical Company Bible rule requiring complete version-bearing fixture audit and regeneration before packaging.
- Preserved both failed candidates and successful rollbacks as permanent evidence.
- Kept every established test, stress tool, protected artifact, and full native gauntlet mandatory.

## Environment limitation

Native Ruby is not available in the packaging workspace. Ruby-WASM cannot execute existing `Open3` and host-filesystem tests. Native v0.1.42 installer validation remains pending and is the only acceptance gate.

## Core defect result

No accepted Profile 1–7 semantic defect was found. Core behavior was not changed.
