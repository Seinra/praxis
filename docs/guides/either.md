# either — two typed sides, neither favoured

**Version:** praxis `0.1.0-dev` on Dart `^3.13.0`.
**Prereqs:** Dart SDK; `import 'package:praxis/praxis.dart'`. Read
[foundations](foundations.md) first if generic syntax is new.

> API source: `lib/src/either.dart` — doc comments are the reference; this
> guide is the bridge. Every runnable line here is asserted by
> `test/docs_guides_a_test.dart` — same outputs.

## Concept

`Either<LeftValue, RightValue>` holds exactly one side: a first-side value
(`Left`) or a second-side value (`Right`). Unlike `Result`, neither side
carries success or failure meaning — both sides are plain payloads, so two
values of the same type stay distinguishable by side instead of collapsing
into one. You ask the side with `isLeft`/`isRight`, split it with `when`,
move one side forward with `mapRight`/`mapLeft`, exchange the sides with
`swap`, or bridge into a `Result` with `toResult`.

> [!WARNING]
> Never assign success-or-failure meaning to the sides. A locked reason on the
> left and a granted title on the right are both plain payloads — the moment
> one side means failure with a cause, the value belongs in
> [result](result.md).

**When to use the stdlib directly:** an ad-hoc record `(A, B)` stays yours for
a pair a single function produces and consumes inline. You reach for `Either`
when the pair travels as a value across calls and every split must stay
exhaustive — bare `Object?` with hand-written `is`-checks cannot promise the
compiler checks every branch.

## Steps

1. Wrap: `Either.left` holds the first side; `Either.right` holds the second.
2. Ask: `isLeft`/`isRight` report the side the pair already proved is held.
3. Split: `when` runs one branch per side and returns one shared type, so the
   split stays exhaustive and typed.
4. Transform: `mapRight` moves the second side while the first passes through
   untouched; `mapLeft` mirrors it.
5. Exchange: `swap` re-sides the payload without touching it; swapping twice
   returns to the original sides.
6. Bridge: `toResult` turns the second side into `Ok` and maps the first side
   into a `Failure` through your caller-supplied mapping.

## Which function?

Source: `lib/src/either.dart` — this table mirrors the package Which-table
verbatim.

| If you hold ... | Reach for |
| --- | --- |
| two typed sides, neither favoured | [Either] |
| a first side to wrap | [Either.left] |
| a second side to wrap | [Either.right] |
| a side to ask about | [Either.isLeft], [Either.isRight] |
| a pair to split into one branch per side | [Either.when] |
| a second side to transform while the first passes through | [Either.mapRight] |
| a first side to transform while the second passes through | [Either.mapLeft] |
| two sides to exchange | [Either.swap] |
| a pair to bridge into a success-or-failure outcome | [Either.toResult] |

## Example

Runnable — asserted by `test/docs_guides_a_test.dart` (same outputs):

```dart
import 'package:praxis/praxis.dart';

void main() {
  final Either<String, int> granted = Either<String, int>.right(7);
  print(granted.when(
    onLeft: (String lockReason) => 'locked: $lockReason',
    onRight: (int slotCount) => 'ready: $slotCount slots',
  )); // ready: 7 slots

  final Either<String, int> locked = Either<String, int>.left(
    'season pass missing',
  ).mapLeft((String lockReason) => 'LEFT:$lockReason');
  print(locked.isLeft); // true

  final Result<int> outcome = granted.toResult(
    (String lockReason) => Exception(lockReason),
  );
  print(outcome.getOrElse(0)); // 7
}
```

Expected output:

```text
ready: 7 slots
true
7
```

## Contracts

| Contract | What it means for you |
| --- | --- |
| Exactly one side, always | A pair holds `Left` or `Right`, never both, never neither — the sealed type proves it. |
| Untouched sides pass through | `mapRight` never runs its transform on a `Left`; `mapLeft` never runs its transform on a `Right`. |
| `toResult` maps lazily | Your `failureOf` mapping never runs on the second side; a `Right` bridges straight into `Ok`. |
| Swaps round-trip | `swap` on a swapped pair returns the original sides with the payload untouched. |

> [!WARNING]
> Never branch on `isLeft`/`isRight` and then cast the payload — `when` keeps
> both branches beside the type, while a cast reintroduces the untyped shape
> `Either` exists to replace.

## Checklist

- [ ] You split with `when` instead of branching on `isLeft`/`isRight` plus
  a cast.
- [ ] You can state which side each transform carries through untouched.
- [ ] You bridge with `toResult` only at the point a failure cause becomes
  known.
- [ ] You never assign success-or-failure meaning to the sides.

## Next step

- Neighbor: [result](result.md) — the bridge target; you cross with `toResult`
  only at the point a failure cause becomes known.
- Absence without a cause: [opt](opt.md) — a missing value with no explanation
  lives there, never as a `Left`.
