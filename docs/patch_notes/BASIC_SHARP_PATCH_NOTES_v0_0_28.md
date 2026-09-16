# BASIC# v0.0.28 Patch Notes

BASIC# can now open its own `.bsbc` bytecode files safely.

The loader checks the entire binary before trusting it, including section boundaries, strings, Kinds, Things, START facts, events, IF rules, code blocks, instructions, selectors, references, and counts. Validated bytecode can be summarized or disassembled, and it can be compared against matching source or saved BSIR meaning.

This release does not run bytecode. The first BSharp virtual machine remains the next separate build.
