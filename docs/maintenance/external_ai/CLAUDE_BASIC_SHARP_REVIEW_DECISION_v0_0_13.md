# Claude BASIC# Review Decision Record v0.0.13

## Source

Claude review supplied by Derek on 2026-07-30.

## Version examined

The review discussed the BASIC# project through the v0.0.12 candidate brief, while some suggested version numbers were already stale by the time the report was evaluated.

## Strong findings accepted

- Create a formal BSharp IR meaning contract while BSharp IR is still small.
- Keep Ruby literal, explicit, and replaceable.
- Do not allow Ruby closures, symbols, metaprogramming, or other conveniences to define BASIC# meaning.
- Use one direct parent per Kind when Kind Families are implemented.
- Keep contextual references inside the event that selected them.
- Standardize plain errors around:
  1. what went wrong;
  2. where it happened and what BASIC# understood;
  3. how to repair it.
- Formalize values before large systems silently depend on undeclared numeric behavior.
- Decide capitalization and harmless spacing rules before the language and documentation become too large to change cheaply.

## Findings accepted with correction

### Trigger ambiguity

The current runtime does not search the world and choose an arbitrary guard.

For:

```text
WHEN
[player attacks a guard
<then> (damage that guard].
```

the runtime event names the Thing:

```text
player attacks henry
```

The runtime asks whether Henry exists and whether Henry is a guard.

Another guard existing elsewhere does not make this event ambiguous.

### Context lifetime

`that guard` belongs only to the current event execution. It does not leak into later events or separate runtime sessions. v0.0.13 stress tests now prove this.

### Values

The runtime already records `damage=1`, so values are not purely future theory. They remain a future creator-facing language feature, but their internal meaning must be formalized before health, time, money, distance, and arithmetic grow.

## Finding rejected

Claude suggested that the opening `(` in `(damage` was a Lisp-like parser convenience that should be reconsidered.

Derek clarified that he chose `(` for himself as a visual guide.

It marks that BASIC# is telling the world to do something.

The official-word mark remains protected.

## Speculation not adopted as project truth

- an arbitrary multi-year estimate for the game-engine bridge;
- stale version recommendations;
- treating self-hosting as optional when it remains an owner goal.

## Build action

v0.0.13 includes:

- formal BSharp IR meaning contract;
- official-word visual-guide document;
- Lisp research;
- focused runtime stress testing;
- context isolation proof;
- duplicate BSharp IR Thing protection;
- BSharp IR format/list validation.

No syntax or new official word was added.
