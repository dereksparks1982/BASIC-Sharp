# BASIC# Changelog v0.0.78

## Self-Hosting Milestone 2 Slice 5

- Added the integrated `SmallCompilerSubsetPipeline` source-to-world proof path.
- Strengthened `TokenizerReader` so primary reader records do not invoke the production Lexer.
- Added constructor-disable independence proof for the production Lexer, Parser, SemanticResolver, BytecodeEmitter, BytecodeLoader, BytecodeVirtualMachine, and Runtime.
- Added exact compile/execution parity and deterministic replay gates.
- Preserved Profiles 1-7, BSBC format, production routing, and creator-facing syntax.
