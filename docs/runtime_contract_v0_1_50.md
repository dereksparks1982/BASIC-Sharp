# BASIC# Runtime Contract v0.1.50

v0.1.50 changes no runtime semantics.

The build adds a non-production small compiler subset BSharp IR emitter for the self-hosting runway. The existing Ruby parser, resolver, runtime, BSharp VM, Save, ASK, movement/input behavior, and bytecode behavior remain unchanged.

Normal BASIC# compilation still routes through `compiler/parser.rb` and `compiler/resolver.rb`; `compiler/small_compiler_subset_ir_emitter.rb` is not the production compiler path.
