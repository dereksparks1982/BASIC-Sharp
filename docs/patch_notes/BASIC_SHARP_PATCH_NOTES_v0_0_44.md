# BASIC# Patch Notes v0.0.44

v0.0.44 re-carries the self-hosting lane after the rejected v0.0.43 malformed package and begins it the right way: with a contract, not a fake victory flag.

BASIC# is still compiled by the Ruby bootstrap in this build. The new work defines **BSharp Compiler Subset 0**, records what future compiler-writing work may use, and locks down what it may not claim yet. Ruby remains the referee until BASIC# can reproduce approved compiler outputs under validation.

It also records v0.0.43 as rejected and adds a hard package check for literal NUL bytes in installer scripts.

This build adds no new creator syntax, no Profile 8, no runtime meaning, no engine bridge, and no BSharp document app. It also carries the full v0.0.42 lesson forward by regenerating all version-bearing runtime fixtures together for `0.0.44`.
