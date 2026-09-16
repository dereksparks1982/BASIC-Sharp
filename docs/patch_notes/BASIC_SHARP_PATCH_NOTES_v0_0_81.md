# BASIC# v0.0.81 Patch Notes

Self-Hosting Milestone 2 Slice 8 moves the first BASIC#-authored compiler component into the bounded independent parser path. When the parser encounters one of its nine accepted top-level block heads, it now consults BASIC# bytecode for the dispatch decision. A deliberately wrong native dispatcher causes visible failure instead of falling back to a Ruby routing table, and a controlled two-generation bootstrap must reach a byte-identical fixed point. No new creator-facing syntax is introduced, and Ruby remains the bootstrap compiler and separate referee authority.
