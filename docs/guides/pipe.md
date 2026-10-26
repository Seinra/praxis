# pipe — two steps named as one function

You name a two-step pipeline that reads in application order with `pipe`,
and the same shape in mathematical order with `compose`. Both hand back
one reusable function value: stored, passed, or taught by name.

**Version:** Praxis `0.1.0-dev`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';` exposes `pipe` and
`compose`.

## Concept

Nested calls (`second(first(value))`) sequence one inline call site but
name no reusable value, so the pipeline cannot be stored, passed, or
taught by name. Cascades (`..`) chain methods on one object, `Iterable.map`
transforms collections, and `Result.mapValue`/`Result.andThen` chain
already-wrapped outcomes — none composes two plain total unary functions
into one named value. `pipe` and `compose` fill exactly that gap and
nothing else: no fallible steps, no arities beyond two in one call (nest
one `pipe` inside another), no async execution shapes.

## Quick path

1. Name the application-order pipeline: `pipe(addOne, doubleIt)`.
2. Or name the outside-in composition: `compose(doubleIt, addOne)`.
3. Call the named value: `addOneThenDouble(3)`.
4. Grow longer chains by nesting: `pipe(pipe(firstStep, secondStep),
   thirdStep)` stays typed through every bridge.

## Which type?

The package doc (`lib/src/pipe.dart`) is the source; this table mirrors
its "Which function?" table:

| When you want to ...                   | Reach for |
| --- | --- |
| Name a pipeline that reads left to right | [pipe]    |
| Name a composition that reads outside in | [compose] |

## Example

From `test/docs_guides_c_test.dart` (group `pipe guide`):

```dart
import 'package:praxis/praxis.dart';

void main() {
  final int Function(int) addOneThenDouble = pipe<int, int, int>(
    (int firstValue) => firstValue + 1,
    (int pipedValue) => pipedValue * 2,
  );
  print(addOneThenDouble(3)); // Output: 8

  final int Function(int) doubleAfterAddOne = compose<int, int, int>(
    (int outerValue) => outerValue * 2,
    (int innerValue) => innerValue + 1,
  );
  print(doubleAfterAddOne(3)); // Output: 8
}
```

Run it: `dart test test/docs_guides_c_test.dart -n 'pipe guide'`.

> [!WARNING]
> Compose pure total steps only. Fallible steps belong to
> `Result.mapValue` and `Result.andThen` over an already-wrapped outcome —
> piping a throwing leg merely propagates to the caller with later legs
> skipped, never as a typed failure. Longer chains nest (`pipe(pipe(a, b),
> c)`); do not wish for `pipe3`/`pipe4` generality the library kills on
> purpose.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| Composing runs nothing | `pipe` and `compose` return a function value; legs run exactly once per call of that value, never at composition time. |
| Re-calling re-runs both legs | Nothing is memoized: every call runs both legs fresh. |
| A leg failure propagates to the caller | Later legs never run after a failure; failures travel as throws from plain legs, never as typed outcomes. |
| Order is the only difference | `compose(outerStep, innerStep)` behaves as `pipe(innerStep, outerStep)` — same bridge, mirrored argument order. |
| Total functions only | Both legs are non-nullable, so a `null`-leg guard is unrepresentable and absent by compiler construction. |

## When to use the stdlib directly

Reach for nested calls (`second(first(value))`) for a one-off inline
sequence nobody needs to store, pass, or teach. Reach for cascades when
you chain methods on one object, and for `Iterable.map` when you
transform collections. Reach for `Result.mapValue`/`Result.andThen` when
the steps are fallible. Reach for `pipe`/`compose` when two plain total
steps deserve one reusable name.

## Next step

Store named-pipeline results under their identity with
[repo](repo.md) — one slot table from fetched or computed values to
addressable records.
