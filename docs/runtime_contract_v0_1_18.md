# BASIC# Runtime Contract v0.1.18

## Set selection

For an action target `every K`, the runtime selects every loaded Thing whose direct Kind or inherited Kind family matches K.

Selection order is `objects` order in DKIR, normally creator DEFINE order. The built-in player remains first if it is a valid member.

Serialized `candidates` are ignored as authority. Selection is recalculated from loaded Things and the validated Kind-distance index.

## Action-line ordering

Each official-word line takes one ordered selection snapshot when the line begins.

The action is applied to every selected Thing before the next official-word line begins.

Supported set actions in v0.1.18:

```text
damage
change
carry
unlock
```

## Singular context

A plural action does not write to event context. `that Kind` continues to name the one Thing bound by the matched WHEN Trigger.

## Empty sets

A known Kind with zero selected Things is valid. The structured result records an empty target list and a plain notice. Later action lines continue.

An unknown Kind is invalid.

## Trace and result data

Event results add:

```text
selections
```

Each set selection records:

```text
set
text
kind_name
targets
count
```

The complete ordered target list and complete per-target steps remain in structured results.

Human reports show all entries through twelve targets/results, then a deterministic remainder count.

IF trace entries may also contain `selections` when an IF action uses `every Kind`.

## Validation before mutation

Saved DKIR rejects malformed set references, unsupported selectors, missing/non-text/empty Kind names, unknown Kinds, and set references in unsupported positions before START facts mutate the world.

## Compatibility

Valid saved DKIR fixtures from v0.1.13, v0.1.15, v0.1.16, and v0.1.17 remain executable.
