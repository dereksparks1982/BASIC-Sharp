# BASIC# Runtime Contract v0.0.81

v0.0.81 changes bounded compiler implementation ownership, not creator-facing runtime meaning. The independent parser now obtains its top-level dispatch decisions by executing the BASIC#-authored compiler BSBC component through the independent loader and BSharp VM.

Profiles 1 through 7, BSharp Bytecode layout, Save meaning, ASK output, input behavior, event ordering, creator-facing syntax, and accepted game-making behavior remain unchanged. The production Ruby compiler/runtime route remains a separate referee and bootstrap authority. v0.0.81 is not full self-hosting and does not retire Ruby.
