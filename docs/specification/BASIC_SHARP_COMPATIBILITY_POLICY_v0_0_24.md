# BASIC# Compatibility Policy v0.0.24

## Stable profile

BSharp Meaning Profile 1 is identified by:

```text
bsharp.meaning.v1
```

Once v0.0.24 is accepted, Profile 1 meaning is immutable.

## Compatible changes

A later implementation may improve:

- speed;
- memory use;
- internal organization;
- caching;
- diagnostics not explicitly locked;
- human report presentation;
- tooling and editor integration.

A later language version may add new features or friendlier input aliases when valid Profile 1 programs retain the same meaning.

Examples of potentially compatible additive work include capitalization tolerance, harmless spacing tolerance, accepted contraction variants, and spelling suggestions. They require their own approved builds and tests.

## Breaking changes

A change is breaking when an already valid Profile 1 program receives different normalized meaning, selection, event order, final world state, save meaning, or ASK answer data.

A breaking change requires:

1. Derek's explicit approval;
2. a new meaning-profile number;
3. a migration document;
4. new conformance fixtures;
5. artifact format changes when the artifact meaning truly changes.

Profile 1 remains preserved even after a later profile exists.

## Artifact boundaries

Profile 1 does not automatically freeze every JSON presentation field.

Current artifact contracts remain:

```text
BSharp IR: bsir.debug.json
BSharp Save: bsharp.save.json, version 1
BSharp ASK: bsharp.ask.json, version 1
```

Any future schema migration requires an explicit approved scope. v0.0.24 performs no schema migration.

## Implementation boundary

Ruby is the bootstrap implementation, not the permanent definition of BASIC#.

The following are not public language interfaces:

- Ruby classes and modules;
- Ruby Struct fields;
- private methods;
- internal hashes and sets;
- benchmark times;
- temporary files;
- machine paths;
- stack traces;
- cache layout.

Future bytecode and VM implementations prove compatibility by passing the Profile 1 fixtures, not by copying Ruby internals.
