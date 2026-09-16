# BASIC# Preferred Runtime Transition Test v0.0.31

The transition lane proves:

- source defaults to BSharp VM;
- saved BSIR defaults to BSharp VM;
- direct BSBC remains BSharp VM;
- source/BSIR use bytecode only in memory;
- no temporary bytecode artifacts leak;
- reference runtime requires explicit opt-in;
- default execution works with reference construction disabled;
- startup, event, world, IF, follow-up, ASK, Save, restore, and replay shadow parity;
- mismatch detection stops with a bounded plain-language report;
- repeated preferred execution is deterministic.

Command:

```bash
ruby tools/runtime_transition.rb
```
