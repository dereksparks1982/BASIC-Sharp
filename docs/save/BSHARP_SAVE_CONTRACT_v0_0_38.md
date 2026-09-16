# BSharp Save Contract v0.0.38

Save format 6 supports `bsharp.meaning.v6` with fingerprint algorithm `sha256-bsir-meaning-v6`. It preserves the settled world and one active Boolean per complete compound IF rule. Restore requires matching format, meaning profile, fingerprint algorithm/value, object identities, typed values, and IF-rule count before mutation.

Restore does not replay START. A restored true/active group stays quiet; it must first become false before a later false-to-true result may wake it again. Failed validation leaves the current world unchanged. Save output remains deterministic and atomic.
