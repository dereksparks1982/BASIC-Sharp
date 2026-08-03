# BASIC# v0.1.43 Rejected Package Audit

## Status

v0.1.43 is rejected and must not be reused as a build number. The accepted base remains v0.1.42 commit `1d79a6221a388ffd6e372d6bfe21d9df1cb38c2c`, tag `v0.1.42`.

## Failure

The delivered v0.1.43 changed-files package stopped before project mutation with:

```text
ERROR: Manifest arrays have the wrong lengths.
```

The terminal command and filename were correct. The package was malformed. The installer script embedded literal NUL bytes in Ruby one-liners where escaped `\0` separators were intended. Bash stripped those bytes during command substitution, collapsing the manifest arrays and triggering the installer guard.

## Disposition

- v0.1.43 is permanently rejected.
- No v0.1.43 commit or tag is accepted.
- No v0.1.43 package should be run again.
- The self-hosting foundation scope is re-carried as v0.1.44.
- v0.1.44 packaging must prove the installer has zero literal NUL bytes before delivery.

## Rule carried forward

Every installable BASIC# package must check the installer script for literal NUL bytes before delivery. Manifest array transport must use escaped NUL separators (`\0`) or another explicit safe separator, never embedded binary NUL characters in a shell script.
