# valid — name checks as values, then compose them

You name a reusable check once as a `Predicate` and combine checks with
`andPredicates`, `orPredicates`, and `notPredicate` instead of nesting
anonymous closures at every call site. Composition never mutates the
predicate list, and calling a combined predicate never mutates the
candidate — checks stay pure values you can store, test by name, and teach.

**Version:** Praxis `0.1.0`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';`. You hold candidates of
one type and the checks you want to combine.

## Quick path

1. Name each check: `final Predicate<int> isAdult = (int candidate) => candidate >= 18;`.
2. Combine every-must-hold checks: `andPredicates<int>(<Predicate<int>>[isAdult, isEvenCheck])`.
3. Combine any-may-hold checks: `orPredicates<int>(<Predicate<int>>[...])`.
4. Flip one check: `notPredicate<int>(isEvenCheck)`.

## Which function?

The package doc (`lib/src/valid.dart`) is the source; this table mirrors its
"Which function?" table:

| When you want to ...              | Reach for ...   |
| --------------------------------- | --------------- |
| Name one reusable check           | [Predicate]     |
| Hold only when every check holds  | [andPredicates] |
| Hold when any check holds         | [orPredicates]  |
| Flip one check                    | [notPredicate]  |
| A check that always holds         | [alwaysTrue]    |
| A check that always fails         | [alwaysFalse]   |

## Example

Runnable — asserted by `test/docs_guides_b_test.dart` (same outputs):

```dart
import 'package:praxis/praxis.dart';

void main() {
  final Predicate<int> isPositiveEven = andPredicates<int>(<Predicate<int>>[
    (int candidate) => candidate > 0,
    (int candidate) => candidate.isEven,
  ]);
  print(isPositiveEven(4)); // true
  print(isPositiveEven(-4)); // false

  final Predicate<int> isZeroOrEven = orPredicates<int>(<Predicate<int>>[
    (int candidate) => candidate == 0,
    (int candidate) => candidate.isEven,
  ]);
  print(isZeroOrEven(3)); // false
  print(isZeroOrEven(4)); // true

  final Predicate<int> isOdd = notPredicate<int>(
    (int candidate) => candidate.isEven,
  );
  print(isOdd(3)); // true
}
```

Expected output:

```text
true
false
false
true
true
```

`andPredicates` over an empty list holds vacuously (`true`, the
`alwaysTrue` identity); `orPredicates` over an empty list fails vacuously
(`false`, the `alwaysFalse` identity). Legs run left to right and stop at
the first decisive leg, so later legs never run after the verdict is known.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| Legs short-circuit left to right | In `andPredicates` the first `false` wins and later legs never run; in `orPredicates` the first `true` wins. Order legs cheapest-first. |
| Empty holds vacuously for And, fails vacuously for Or | `andPredicates` over `[]` reports `true`; `orPredicates` over `[]` reports `false`. The identities `alwaysTrue` and `alwaysFalse` name those edges. |
| Purity both ways | Composing never mutates the predicate list, and calling the combined predicate never mutates the candidate. Re-calling re-iterates a single-use source. |
| No throws for domain inputs | Below-range or empty input is a normal verdict (`true`/`false`), never an exception. |

> [!WARNING]
> A predicate never reports *why* a candidate failed — composition keeps the
> verdict, never the reason. When failures must carry messages, you have
> outgrown this package: collect `Result` values with `flowCollect` (see
> `docs/guides/flow.md`) instead of pressing predicates into reporting.

## When to use the stdlib directly

You stay with `dart:core` when the check is a one-off over plain values:
`&&`, `||`, and `!` already combine booleans inline, and a single-use
closure needs no name. You reach for `valid` when the same check travels —
stored in a list, passed to a combinator, reused across call sites, or
taught by name in course material.

## Next step

When a composed check must guard values that arrive with failure context
rather than bare candidates, collect one `Result` per input with
`flowCollect` instead — see `docs/guides/flow.md`.
