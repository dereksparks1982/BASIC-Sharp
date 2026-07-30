# Company Bible Addendum - Failed Patch Retry Rule v0.1.19

If Derek reports that a patch did not take or that nothing changed, the next corrective patch must carry the missed changes forward again instead of assuming the previous patch landed.

Corrective patch rule:
- Re-include the requested missed feature/fix.
- Add a visible or inspectable verification marker when reasonable.
- Preserve all prior working systems.
- Document the failure report and the retry in patch notes, changelog, session log, and CODEX if system behaviour is affected.
