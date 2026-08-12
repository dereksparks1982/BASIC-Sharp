# BASIC# Validation v0.1.81

Required acceptance validation:

- native parser dispatch source, spec, documentation, tool, and regression;
- independent load and execution of the BASIC#-authored dispatch artifact;
- all nine accepted block heads produce exact locked parser decisions;
- native dispatch invocation count is observable;
- invalid/unmatched head rejection;
- wrong-dispatch sabotage fails visibly with no Ruby routing fallback;
- production Parser and compiler constructors unavailable on the primary proof path;
- Ruby Runtime unavailable on the primary proof path;
- independent source-to-BSBC compilation and independent BSBC execution;
- accepted v0.1.80 bootstrap artifact produces v0.1.81 generation #1;
- generated v0.1.81 artifact produces generation #2;
- generation #1 and #2 are byte-identical and disassembly-identical;
- production and Ruby referee parity;
- Profiles 1-7 compatibility and no new creator-facing syntax;
- complete normal test suite;
- complete no-locale test suite;
- sealed validation inventory and every required stress/tool lane;
- deterministic fixture hash sweep;
- release forensic overlay and package preflight;
- whole-language gauntlet and full native Trial by Fire;
- final installed version check.

Accepted v0.1.80 floor: 660 runs, 9,998 assertions, 0 failures, 0 errors, 0 skips across 83 test files, with 71 required tools, 325 sealed artifacts, and 14 protected artifacts.

Build-side v0.1.81 complete normal and no-locale suites: 670 runs, 10,052 assertions, 0 failures, 0 errors, 0 skips across 84 test files. Native installer validation remains authoritative for release acceptance.

Build-side full-count Trial by Fire was also validated at the locked counts: 128,000 events on each of four execution paths, 128,000 platform frames, 32,000 ASK questions, 64,000 combined input/movement frames, 1,250 Save checkpoints, 320 isolated worlds, follow-up boundaries 1023/1024/1025, 384 deterministic generated programs, and 3,072 mutations per boundary (12,288 hostile artifacts plus 3,040 truncated bytecode prefixes). Because the build host imposes a per-command execution ceiling, the canonical Trial by Fire phases were run in exact-count isolated processes; the release installer runs the canonical unsharded gauntlet natively before FINAL PASS.
