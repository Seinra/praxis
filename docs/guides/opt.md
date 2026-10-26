# opt — a maybe-present value, with the flag beside it

**Version:** praxis `0.1.0-dev` on Dart `^3.13.0`.
**Prereqs:** Dart SDK; `import 'package:praxis/praxis.dart'`. Read
[foundations](foundations.md) first if generic syntax is new.

> API source: `lib/src/opt.dart` — doc comments are the reference; this guide
> is the bridge. Every runnable line here is asserted by
> `test/docs_guides_a_test.dart` — same outputs.

## Concept

`Opt<Held>` holds either a present value (`Some`) or absence (`None`). Absence
is a normal outcome here, never a failure: for failures with a cause, you reach
for [result](result.md). The sealed `Some`/`None` hierarchy keeps every split
exhaustive — the compiler rejects a `switch` that forgets one side, so absence
never slips past silently.

> [!WARNING]
> Never trust the value without the flag. A present `null` still reports
> `true`: only `split` (or the `isPresent`/`isAbsent` pair) tells a held
> `null` from absence. You read presence first, every time.

**When to use the stdlib directly:** a nullable `Held?` with `??` stays
idiomatic for a single local lookup. You reach for `Opt` when a maybe-present
value travels through transforms and chains (`mapValue`/`andThen`), mirrors
the Axiom `(T, bool)` OrNull contract, or must distinguish "lookup ran, slot
empty" from "lookup never ran" — a bare `null` cannot say that.

## Steps

1. Wrap: `Opt.present` holds a value; `Opt.absent` expresses absence.
2. Ask: `isPresent`/`isAbsent` report the flag, never the value.
3. Split: `split` opens the `(heldValue, presentFlag)` record — the Axiom
   OrNull shape, pinned exactly.
4. Transform: `mapValue` converts the held value; absence carries through
   untouched without running the transform.
5. Chain: `andThen` feeds the held value into the next `Opt`;
   `orElse` falls back to another `Opt` when absent.
6. Read: `valueOr` reads with an explicit fallback; `valueOrElse` reads with a
   lazy fallback that never runs on the happy path.

## Which function?

Source: `lib/src/opt.dart` — this table mirrors the package Which-table
verbatim.

| When you want to ...               | Reach for ...        |
|------------------------------------|----------------------|
| Hold a present value               | [Opt.present]        |
| Express absence                    | [Opt.absent]         |
| Ask whether a value is held        | [Opt.isPresent]      |
| Ask whether nothing is held        | [Opt.isAbsent]       |
| Split to the `(value, present)` record | [Opt.split]      |
| Transform the held value           | [Opt.mapValue]       |
| Chain to the next [Opt]            | [Opt.andThen]        |
| Read with an explicit fallback     | [Opt.valueOr]        |
| Read with a lazy fallback          | [Opt.valueOrElse]    |
| Fall back to another [Opt]         | [Opt.orElse]         |

## Example

Runnable — asserted by `test/docs_guides_a_test.dart` (same outputs):

```dart
import 'package:praxis/praxis.dart';

void main() {
  const Opt<int> presentScore = Opt<int>.present(4);
  print(presentScore.valueOr(0)); // 4
  print(presentScore.mapValue((int heldValue) => heldValue + 1).valueOr(0)); // 5

  const Opt<int> missingScore = Opt<int>.absent();
  print(missingScore.valueOr(9)); // 9
  print(missingScore.isAbsent); // true

  final (int? heldValue, bool presentFlag) = presentScore.split;
  print('$presentFlag:$heldValue'); // true:4
}
```

Expected output:

```text
4
5
9
true
true:4
```

## Contracts

| Contract | What it means for you |
| --- | --- |
| Absence short-circuits | `mapValue` and `andThen` never run their function on `None`; absence carries through untouched. |
| `valueOrElse` stays lazy | The fallback never runs when the value is present, so expensive defaults cost nothing on the happy path. |
| First present side wins | `orElse` keeps the receiver when present; absence plus absence stays absent. |
| Presence is the flag, not the value | `Opt.present(null)` still reports `isPresent`; `split` on `None` yields `(null, false)`. |

> [!WARNING]
> Never use `Opt` for failures with a cause — a bare absence cannot explain
> *why* there is no value. The moment a cause becomes known, the value belongs
> in [result](result.md).

## Checklist

- [ ] You check presence (`isPresent`/`isAbsent` or `split`) before you
  trust the value.
- [ ] You can state which combinators short-circuit on absence (`mapValue`,
  `andThen`) and which fallback wins (`orElse` keeps the first present
  side).
- [ ] You can state the laziness rule (`valueOrElse` never runs its fallback
  when the value is present).
- [ ] You never use `Opt` for failures with a cause.

## Next step

- Cookbook recipe (a): [The absence ladder](../cookbook.md) — chain or
  transform absence with `Opt`, and climb to `Result` only at the point a
  cause becomes known.
- Neighbor: [result](result.md) — success or failure with the cause attached;
  absence grows into a `Result` only at the point a cause becomes known.
- Search lists with presence flags: [lists](lists.md) — `findElement`,
  `minElement`, and `maxElement` report the same `(value, present)` shape.
