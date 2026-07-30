# BASIC# Runtime Contract v0.1.15

## Scope

v0.1.15 makes the direct parent relationships already stored in DKIR active during runtime matching.

## Kind family walking

For:

```text
wyrm -> dragon -> creature -> thing
```

A Thing whose direct Kind is `wyrm` matches all four Kind names.

The Runtime walks one parent at a time until it either finds the requested Kind or reaches the top of the stored family.

## Trigger priority

Matching order is:

1. Exact named-Thing Trigger.
2. Nearest compatible Kind Trigger.
3. Source order when two compatible Kind Triggers are equally near.

This preserves exact Trigger behavior and prevents a broad ancestor rule from swallowing a more specific direct-parent rule.

## Event context

The Trigger's written Kind remains the context key.

Example:

```text
WHEN
[player attacks a creature
<then> (damage that creature].
```

If `ember` is a `wyrm`, the event context is:

```json
{
  "creature": "ember"
}
```

`that creature` therefore resolves to `ember` for that event only.

## Plain-language failures

Unknown event Thing:

```text
event Thing 'ghost' is not defined
```

Incompatible Kind:

```text
north door is a door, not a creature
```

Broken saved DKIR parent:

```text
Kind family is broken: shade has unknown parent missing kind
```

Circular saved DKIR family:

```text
Kind family has a loop: creature -> thing -> wyrm -> dragon -> creature
```

## DKIR validation

The Runtime requires `kinds` to be a list, alongside the other runtime lists.

Each Kind entry must provide:

```text
name
parent
```

The Runtime rejects:

- an empty Kind name;
- a missing parent;
- more than one parent for the same Kind;
- an unknown parent;
- a circular parent chain.

## Compatibility

- Source-built and saved-DKIR execution must remain identical.
- The accepted v0.1.13 saved-DKIR fixture remains executable.
- Old DKIR receives only the ancestry it actually stores. The Runtime does not invent missing parents.

## Explicit exclusions

- No multiple inheritance.
- No event queue.
- No repeated IF system.
- No values or damage amounts beyond the accepted counter.
- No new official words.
- No bytecode or VM work.
