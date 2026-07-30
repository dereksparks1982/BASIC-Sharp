# BASIC# v0.1.19 New Thread Handoff

## Candidate

- **Build:** v0.1.19 Whole-Number Values and Damage Amounts
- **Required base:** accepted v0.1.18
- **Base commit:** `05eaf68`
- **Base tag:** `v0.1.18`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_19_WHOLE_NUMBER_VALUES_AND_DAMAGE_AMOUNTS_CHANGED_FILES_ONLY.zip`
- **Status:** built and internally validated; owner installation and acceptance pending

## Meaning added

- `Thing has NUMBER value` under START.
- `(damage target by NUMBER`, with omitted amount still meaning one.
- `(change value of target to NUMBER`.
- Exact-value IF conditions.
- Atomic set preflight for missing values and overflow.
- Whole-number range 0 through 2,147,483,647.

## Meaning explicitly not added

No equations, variables, decimals, percentages, hidden health subtraction, death system, armor formula, event queue, time, save/load, ASK, bytecode, VM, engine bridge, or self-hosting.

## Validation

135 runs, 4,717 assertions, zero failures/errors/skips. All five stress lanes pass.

## Rollback

Commit `05eaf68`, tag `v0.1.18`.

## Continuation

After Derek installs and accepts, commit and tag v0.1.19. Then read all current records and present the v0.1.20 proposal before implementation.
