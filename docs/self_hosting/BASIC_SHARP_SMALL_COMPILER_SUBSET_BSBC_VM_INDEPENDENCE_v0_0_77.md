# BASIC# v0.0.77 Small Compiler Subset BSharp VM Execution Independence

## Contract

This build advances BSharp Compiler Subset 0 through Self-Hosting Milestone 2 Slice 4 by giving the bounded subset lane its own `SmallCompilerSubsetBSBCVirtualMachine` execution engine.

The canonical self-hosting contract remains:

`spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`

The Slice 4 contract is:

`spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_VM_INDEPENDENCE_v1.json`

## Independent bounded path

The proving path is now:

`TokenizerReader -> SmallCompilerSubsetParser -> SmallCompilerSubsetSemanticResolver -> BSharp IR -> SmallCompilerSubsetBSBCEncoder -> SmallCompilerSubsetBSBCLoader -> SmallCompilerSubsetBSBCVirtualMachine`

`SmallCompilerSubsetBSBCVirtualMachine` accepts the trusted model produced by the independent subset loader. It does not require, instantiate, inherit from, or call the production `BytecodeVirtualMachine`.

## Referees

The production `BytecodeVirtualMachine` remains a separate exact-execution referee. `BasicSharp::Runtime` remains the Ruby semantic referee. The independent VM must match both referees for event results, final world state, BSharp Save output, action ordering, selector binding, IF/OTHERWISE settlement, follow-up events, and loop protection.

The production Ruby compiler and runtime path remain unchanged. This is not full self-hosting, and Ruby remains the bootstrap compiler and referee authority.

## Profiles and behavior

The Slice 4 lane covers the already accepted Profile 1 through Profile 7 meaning. It does not add Profile 8, change the BSBC binary format, add creator-facing syntax, or change normal production runtime behavior.

The dedicated v0.0.77 fixture crosses the full independent bounded path and combines Kind inheritance, text values, whole-number values, open/close/lock/take object interaction, exact and Kind selectors, IF/OTHERWISE, multiple instructions, and follow-up events.

## High-volume proof

The VM independence gate requires exact deterministic parity for 1,024 repeated events. It also proves the 1,024 follow-up-event loop-protection boundary against both the production `BytecodeVirtualMachine` referee and the Ruby runtime referee.

A direct dependency audit fails if `compiler/small_compiler_subset_bsbc_virtual_machine.rb` starts requiring, instantiating, inheriting from, or wrapping the production VM.

## Acceptance

The build is acceptable only when the dedicated VM-independence regression, full normal suite, full no-locale suite, all self-hosting validation tools, deterministic fixture sweep, release gates, whole-language gauntlet, and full Trial by Fire all pass.
