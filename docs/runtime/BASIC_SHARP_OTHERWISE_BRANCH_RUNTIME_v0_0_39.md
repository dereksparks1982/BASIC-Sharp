# BASIC# OTHERWISE Branch Runtime v0.0.39

Each two-sided IF rule stores its last settled Boolean result. On first settlement, the runtime evaluates the complete condition and runs exactly one branch. A later false-to-true transition runs the IF actions; true-to-false runs OTHERWISE actions. No action runs while the result is unchanged.

The chosen action list completes atomically under the existing action rules before reactive settlement resumes. Source order, follow-up event order, iteration limits, repeated-state detection, and loop diagnostics remain authoritative. Reference runtime and BSharp VM must agree exactly.
