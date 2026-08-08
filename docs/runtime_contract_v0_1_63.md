# BASIC# Runtime Contract v0.1.63

v0.1.63 does not change production runtime meaning.

The build hardens file reading by using explicit UTF-8 for source, BSharp IR JSON, BSharp Save JSON, and text fixtures where the project controls file reads. This prevents minimal/no-locale Ruby environments from crashing on non-ASCII creator text.

The new BSBC execution parity lane compares BSharp VM execution against the Ruby referee runtime for approved small compiler subset fixtures. It is a validation/referee lane, not a runtime semantics change.
