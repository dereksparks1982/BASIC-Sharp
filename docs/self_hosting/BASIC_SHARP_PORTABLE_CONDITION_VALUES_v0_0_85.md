# BASIC# v0.0.85 Candidate: Portable Condition and Value Interpretation

**Status:** Unaccepted source-only development on GitHub main.
**Previous GitHub head:** a0fa05eaacf1ebfac1767f32c26bf313914b17f7.
**Rollback:** Revert the development commit; accepted release/tag and Ruby
production files are unchanged. No local installer, download or SSH action.

## Goal

Reduce Ruby dependence through a separate browser-capable compilation path,
while preserving established creator syntax and meaning Profiles 1 through 7.

## Implemented in source

1. The portable source-to-BSIR compiler recognizes IF comparisons:
   "at least", "more than", "at most" and "less than" with whole numbers,
   and keeps existing compound "and"/"or" behavior.
2. START can define exact quoted text values such as
   @gate has "North  Gate!" title. IF can compare quoted values without
   changing spaces, punctuation, or case.
3. The existing (change value of @Thing to "text" and
   (change value of @Thing to 8 actions are parsed into typed BSIR.
4. Built-in Kinds now match the original CoreDictionary more closely. Unique
   definite "the #Kind" references are resolved using inherited Kinds.
   Ambiguous or missing definite Kind references fail visibly.
5. The portable compiler lowers (take to (carry and (open, (close, (lock
   to state-changing BSIR actions, mirroring accepted Ruby resolver meaning.
6. Browser sandbox validation, START, IF, and action execution interpret
   these values and comparisons. Existing primitive event simulation remains.
7. Browser console includes "Score and IF thresholds" and
   "Text values and Kind references" examples.
8. Unexecuted tests record expected compiler, IR, and browser behavior.

## Limits

Only a bounded source-to-BSIR + browser interpreter is present. The accepted
BSharp VM executes real BSBC bytecode, which this web interpreter does not.
Unimplemented features, including arbitrary selectors, every #Kind,
context-sensitive "it", (cause events, world movement, CONTROLS, HOVER and
CONTEXT must continue to fail rather than appear supported. Complete profile
parity, binary emission/loading, save semantics and native self-hosting are
not established. No creator-facing syntax changes or Profile 8.

## Validation and release truth

The owner instructed source-only GitHub development. No compilation, test
execution, release acceptance, GitHub Actions or local installation was run.
The tests under tests/portable_bsharp_* are future regression definitions.
The accepted v0.0.84 code and tag remain as-is; this work is a repairable
v0.0.85 candidate, not a numbered accepted release.

Next: implement remaining semantic selectors and caused-event binding safely,
then independent BSBC emission/VM and full parity when testing resumes.
