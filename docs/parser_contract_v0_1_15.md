# BASIC# Parser Contract v0.1.15

## Scope

v0.1.15 does not add a new `KINDS` grammar. It completes the meaning of the already accepted direct-parent form:

```text
KINDS
[creature is a thing
dragon is a creature
wyrm is a dragon].
```

## One direct parent

Each Kind may have one direct parent.

A known built-in Kind that does not yet have a declared parent may receive one through the same existing form. This allows `creature is a thing` without inventing new syntax.

A second parent is rejected:

```text
kind 'creature' already has parent 'thing'
```

## Parent order

A parent must already be known when the child line is read. This keeps the Body readable from top to bottom and preserves the existing compiler behavior.

Unknown parent example:

```text
unknown parent kind 'beast'
```

## Circular families

A new parent may not create a loop. The diagnostic shows the complete loop instead of speaking in compiler jargon.

Example:

```text
Kind family has a loop: thing -> dragon -> creature -> thing
```

## Resolver behavior

Kind selectors now include descendant Things.

If the compiler knows:

```text
wyrm -> dragon -> creature -> thing
```

then a Thing whose direct Kind is `wyrm` can appear among the candidates for:

```text
a wyrm
a dragon
a creature
a thing
the creature
```

Existing ambiguity rules remain in force. `the creature` still requires exactly one compatible Thing.

## Preserved language rules

- `[` touches the first Body word.
- Bodies still end with `].`.
- `<then>` remains a Connector.
- `then` and `than` remain accepted equivalents.
- Official words retain their creator-facing opening `(`.
- No standalone `thing` line is added. `thing` is already a known root Kind.
- No multiple inheritance is added.
