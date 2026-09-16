# BASIC# Runtime-Transition Version Binding Test v0.0.35

The standalone transition audit must compare direct `.bsbc` output with `BSharp Virtual Machine v#{BasicSharp::VERSION}` and explicit reference output with `BASIC# Runtime v#{BasicSharp::VERSION}`. The automated regression test rejects a hard-coded numeric runtime banner in that audit. Direct `.bsbc` CLI coverage also requires the exact active BSharp VM version, not merely the presence of a generic VM label.
