# result — success or failure, with the cause attached

**Version:** praxis `0.1.0-dev` on Dart `^3.13.0`.
**Prereqs:** Dart SDK; `import 'package:praxis/src/result.dart'`. Read
[foundations](foundations.md) first if generic syntax is new.

> API source: `lib/src/result.dart` — doc comments are the reference; this
> guide is the bridge. Every runnable line here is asserted by
> `test/docs_guides_a_test.dart` — same outputs.

## Concept

`Result<OutcomeValue>` holds either a success (`Ok`) or a failure (`Failure`,
always with an `Exception` cause). You transform the success side while the
failure carries through untouched; you split both paths explicitly with
`when`. Failures travel inside the type, so the compiler keeps the failure
path visible instead of hiding it in a throw.

> [!WARNING]
> Never use `Result` for absence without a cause — that is `Opt`. You reach
> for `Result` when the caller must know *why* there is no value; a missing
> value with no explanation belongs in [opt](opt.md).

**When to use the stdlib directly:** a single `throw` at a function boundary
stays idiomatic when the failure never travels. You reach for `Result` when an
outcome moves through several transforms (`mapValue`/`andThen`) or crosses an
API boundary where throwing would hide the failure path from the type.

## Steps

1. Wrap: `Result.ok` holds success; `Result.failure` holds failure.
2. Ask or read: `isOk`/`isFailure` check the side; `when` splits both paths;
   `getOrElse` reads with a backup value.
3. Transform: `mapValue` converts the success side; failures carry through
   untouched without running the transform.
4. Chain: `andThen` feeds success into the next `Result`; a failure
   short-circuits and carries its original cause instance forward.

## Which function?

Source: `lib/src/result.dart` — this table mirrors the package Which-table
verbatim.

| If you hold ... | Reach for |
| --- | --- |
| a success-or-failure outcome | [Result] |
| a success value to wrap | [Result.ok] |
| a failure cause to wrap | [Result.failure] |
| a side to ask about | [Result.isOk], [Result.isFailure] |
| an outcome to split into one branch per side | [Result.when] |
| an outcome to read with a backup value | [Result.getOrElse] |
| a success to transform while failures pass through | [Result.mapValue] |
| a success to chain into the next outcome | [Result.andThen] |

The sides travel as `Ok` (carries `value`) and `Failure` (carries `cause`);
you build them through `Result.ok`/`Result.failure` and read them through the
rows above — never through casts.

## Example

Runnable — asserted by `test/docs_guides_a_test.dart` (same outputs):

```dart
import 'package:praxis/src/result.dart';

void main() {
  final Result<int> doubled = Result<int>.ok(21).mapValue(
    (int successValue) => successValue * 2,
  );
  print(doubled.getOrElse(0)); // 42

  final Result<int> offline = Result<int>.failure(Exception('offline'));
  print(offline.getOrElse(-1)); // -1

  final String label = doubled.when(
    ok: (int successValue) => 'ok:$successValue',
    failure: (Exception failureCause) => 'failure',
  );
  print(label); // ok:42
}
```

Expected output:

```text
42
-1
ok:42
```

## Contracts

| Contract | What it means for you |
| --- | --- |
| Failures carry through untouched | `mapValue` never runs its transform on failure; `andThen` never runs its next step on failure. |
| Cause identity holds | `andThen` carries the original `Failure.cause` instance into the chained outcome. |
| `getOrElse` substitutes on failure only | Success passes through untouched; the fallback never masks a success. |
| Cause is always an `Exception` | Callers with codes or ADTs wrap them in an `Exception`; generalizing the cause type stays a future ODD with a migration note. |

> [!WARNING]
> Never steer branches on `getOrElse` output alone — the fallback erases *why*
> the failure happened. You split with `when` when the cause matters, and you
> reserve `getOrElse` for boundaries where a backup value is the whole story.

## Next step

- Neighbor: [opt](opt.md) — absence without a cause; a missing value with no
  explanation lives there, never as a `failure`.
- Unbiased pairs: [either](either.md) — two plain sides with neither favoured;
  you bridge into `Result` with `toResult` only at the point a cause becomes known.
