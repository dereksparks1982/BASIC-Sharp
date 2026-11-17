# BASIC# Ruby-removal work: source-only development

Status: unaccepted experiment. No compiler runs, no tests, no GitHub Actions, no release.

This branch introduces a Ruby-independent source-to-BSharp-IR path in
compiler/portable/bsharp_compiler.mjs and a Node CLI in
compiler/portable/bsharp_cli.mjs. These are working source implementations
for a bounded subset, not a full language implementation.

The compiler parses the established Heads, Bodies, comments, Kind and Thing
declarations, state and numeric START facts, basic WHEN rules, simple and
compound IF rules, OTHERWISE, and selected action words. It preserves the
creator-facing visual grammar and rejects unimplemented features instead of
silently delegating to Ruby or pretending to have emitted correct bytecode.

compiler/native/first_bsharp_condition_router.bsharp carries the next native
BASIC# authored IF connector logic, but has not been compiled into BSBC.
tests/portable_bsharp_compiler.test.mjs contains future checks, not run now.

Remaining: full selector/reference resolution, text values, movement,
CONTROLS, HOVER, CONTEXT, full parity, Ruby-free BSBC emitter, Ruby-free VM,
self-hosted compiler orchestration, and a validated production cutover.

Do not claim self-hosting or Ruby retirement. The accepted local v0.1.84
release and the GitHub main branch remain untouched. The previous local
v0.1.85 installer failure and rollback are not accepted-release evidence.
