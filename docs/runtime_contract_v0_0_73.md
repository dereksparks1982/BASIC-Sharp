# BASIC# Runtime Contract v0.0.73

Object-interaction aliases do not create a parallel runtime path. `(open`, `(close`, and `(lock` resolve to existing state changes; `(take` resolves to existing carry behavior. Source, BSIR, BSBC, BSharp VM, and Ruby referee execution must remain behaviorally equivalent.
