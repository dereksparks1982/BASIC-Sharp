# BASIC# v0.0.81 Session Log

Scope approved: Self-Hosting Milestone 2 Slice 8, Native Parser Dispatch Integration.

The build began from accepted v0.0.80 at commit `62b8a3ffc2eb80d785f80e5b6ba61fa210c5a336`, annotated tag `v0.0.80`. The uploaded accepted tree was independently baseline-tested before modification at 660 runs / 9,998 assertions / 0 failures / 0 errors / 0 skips.

`compiler/small_compiler_subset_native_dispatch.rb` was added as the bridge from the bounded parser to `compiler/native/first_bsharp_compiler_component.bsbc`. The parser now asks the BASIC# artifact for each top-level routing decision. The old accepted-head Ruby dispatch table was removed from the bounded route.

The integration test locks all nine accepted heads, observes native invocation counts, rejects invalid heads, fences production constructors, and performs a sabotage case. In the sabotage case a temporary native component deliberately maps `KINDS` to the wrong parser decision. Parsing must fail visibly. There is no Ruby fallback path that restores the correct answer.

For bootstrap control, the exact accepted v0.0.80 native artifact was preserved outside the candidate tree. It compiled the v0.0.81 native source to generation #1. Generation #1 then compiled the same source to generation #2. The two generated BSBC artifacts and readable disassemblies are byte-identical. The BSBC SHA-256 remains `cbebf931b65acc7d8ff75409a08d78624bdd9589b60c9c06cbbf66270a19d297`; the disassembly SHA-256 remains `fbd05ee0cbe94fd4a0fa17e4b257afbd2faa6a1df4ebda0dc2fd9b431ae1c20c`.

Version-sensitive BSharp IR and Save hashes were regenerated as a family only after exact production/Ruby referee parity showed that semantic and BSBC binary behavior remained stable.

Build-side complete normal and no-locale suites both pass at 670 runs and 10,052 assertions with zero failures, errors, or skips. The native parser dispatch integration tool passes against the preserved v0.0.80 bootstrap artifact, including sabotage, constructor fences, independent compile/execute, fixed point, and referee parity.

No Profile 8, new creator-facing syntax, BSBC layout change, production routing replacement, full-self-hosting claim, or Ruby retirement is introduced.

Build-side full-count Trial by Fire was also validated at the locked counts: 128,000 events on each of four execution paths, 128,000 platform frames, 32,000 ASK questions, 64,000 combined input/movement frames, 1,250 Save checkpoints, 320 isolated worlds, follow-up boundaries 1023/1024/1025, 384 deterministic generated programs, and 3,072 mutations per boundary (12,288 hostile artifacts plus 3,040 truncated bytecode prefixes). Because the build host imposes a per-command execution ceiling, the canonical Trial by Fire phases were run in exact-count isolated processes; the release installer runs the canonical unsharded gauntlet natively before FINAL PASS.
