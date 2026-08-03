# BASIC# Runtime Contract v0.1.44

v0.1.44 changes no creator-facing runtime meaning. Stable Meaning Profiles 1 through 7 and BSharp Bytecode Profiles 1 through 7 remain the accepted language/runtime surface.

This build adds the self-hosting foundation contract only. `BasicSharp::Runtime` remains the protected reference oracle, and the BSharp VM remains the preferred runtime for accepted source, BSIR, and BSBC execution.

The new executable contract is `tools/self_hosting_contract.rb`, backed by `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`. It forbids claiming self-hosting, replacing Ruby, adding Profile 8, adding new syntax, or starting the BSharp native document app in this build.

Every version-bearing runtime fixture is regenerated for `BasicSharp::VERSION == 0.1.44` and remains protected by the same stress gates introduced in v0.1.42.
