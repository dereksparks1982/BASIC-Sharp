# BASIC# ASK Contract v0.0.32

BSharp ASK remains read-only and deterministic. v0.0.32 adds typed text visibility without changing accepted questions or mutation guarantees.

- Thing answers report exact text values without lowercasing or escaping them into a different meaning.
- World summaries count whole-number values and text values separately.
- Save summaries report the active meaning profile, fingerprint algorithm, Save format version, and typed value readiness.
- IF inspection renders exact quoted text conditions.
- JSON ASK output preserves the same semantic data as plain output.
- ASK before and after a question must leave snapshots, event history, IF state, and Save readiness unchanged.

Unknown Things, Kinds, questions, malformed input, and question-count limits keep their accepted deterministic errors. Profile 1 answers remain compatible.
