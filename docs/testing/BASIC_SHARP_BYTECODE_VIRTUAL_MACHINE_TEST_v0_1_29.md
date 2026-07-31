# BASIC# v0.1.29 BSharp Virtual Machine Test

The focused VM tests verify:

- validated-loader-only construction;
- six sample START-world comparisons;
- sample event-sequence parity with the accepted Runtime;
- exact and inherited event priority;
- `that Kind` and `every Kind` behavior;
- value atomicity;
- reactive IF rearming;
- follow-up FIFO order;
- frozen loaded-program preservation;
- separate VM isolation;
- all twelve valid Meaning Profile startup worlds;
- CLI execution and excluded-mode rejection;
- direct execution while `BasicSharp::Runtime.new` is disabled.

Focused file:

```bash
ruby tests/test_bytecode_virtual_machine.rb
```

Standalone lane:

```bash
ruby tools/bytecode_virtual_machine.rb
```
