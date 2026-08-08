# BASIC# Runtime Contract v0.1.49

v0.1.49 changes no runtime semantics.

The build adds `compiler/small_compiler_subset_parser.rb` as a self-hosting runway implementation under Ruby Parser referee control. Runtime execution, BSharp IR meaning, BSharp Bytecode, Save, ASK, input-device behavior, and game interaction behavior remain unchanged.

Ruby remains the production parser and reference referee. v0.1.49 does not route compiler parsing through the new small compiler subset parser.
