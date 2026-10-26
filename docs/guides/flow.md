# flow — bounded parallel map, or the first success wins

You run a transform over inputs with at most `maxInflight` concurrent
runners. `flowMap` returns every result in input order; `flowFirst` races
for the first success while ignoring failures; `flowCollect` streams one
typed `Result` per input in completion order. You share one caller-owned
`FlowScope` for cooperative cancellation across each call: the combinator stops
starting new work on its terminal event, and you stop it from the outside
with `FlowScope.stop`. In-flight futures always run to completion because
Dart futures are not preemptible.

**Version:** Praxis `0.1.0`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';` and
`import 'dart:async';`. You hold a finite input iterable, a `maxInflight`
cap above zero, and a transform that honors the scope.

## Quick path

1. Write the transform: `(int candidateInput, FlowScope scope) async => candidateInput * 2`.
2. Every value in order: `flowMap(inputs, maxInflight: 2, transform: ...)`.
3. Any single success: `flowFirst(inputs, maxInflight: 2, transform: ...)`.
4. One outcome per input as each finishes: `flowCollect(inputs, maxInflight: 2, transform: ...).toList()`.

## Which function?

The package doc (`lib/src/flow.dart`) is the source; this table mirrors its
"Which function?" table:

| When you want to ... | Reach for |
| --- | --- |
| Transform every input with a cap, keeping input order | [flowMap] |
| The first success, ignoring failures until all fail | [flowFirst] |
| One outcome per input as each finishes | [flowCollect] |
| A stop signal shared by one call | [FlowScope] |

## Example

Runnable — asserted by `test/docs_guides_b_test.dart` (same outputs):

```dart
import 'package:praxis/praxis.dart';

Future<void> main() async {
  final List<int> doubledOutputs = await flowMap<int, int>(
    <int>[1, 2, 3],
    maxInflight: 2,
    transform: (int candidateInput, FlowScope scope) async =>
        candidateInput * 2,
  );
  print(doubledOutputs); // [2, 4, 6]

  final int winnerOutput = await flowFirst<int, int>(
    <int>[1, 2, 3],
    maxInflight: 2,
    transform: (int candidateInput, FlowScope scope) async {
      if (candidateInput != 1) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      return candidateInput * 10;
    },
  );
  print(winnerOutput); // 10

  final List<Result<int>> collectedOutcomes = await flowCollect<int, int>(
    <int>[1, 2],
    maxInflight: 2,
    transform: (int candidateInput, FlowScope scope) async =>
        candidateInput * 2,
  ).toList();
  print(collectedOutcomes.length); // 2
  print(collectedOutcomes.every((Result<int> outcome) => outcome.isOk)); // true
}
```

Expected output:

```text
[2, 4, 6]
10
2
true
```

The inputs iterable must be finite: each combinator reads it once up front
into a private list. A `maxInflight` of zero or less throws `ArgumentError`
— unlike runtimes that probe core counts, a platform-neutral core names the
cap explicitly. Empty `flowMap` and `flowCollect` inputs succeed without
running work; empty `flowFirst` inputs throw `ArgumentError` because no
success is possible.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| First failure wins in `flowMap` | The first task failure stops new work, stops the scope, and completes the returned future with that failure once started tasks settle. Synchronous throws inside the transform count as task failures. |
| `flowFirst` survives failures | Failures only record the first error and free their slot; the first success completes the future immediately and stops the scope. All-failed runs complete with the first chronological error — the gap against `Future.any`, which settles on the first value *or* error. |
| `flowCollect` never throws per-task | Failures ride beside successes as `Result.failure` values and never stop siblings. The stream closes after every started task settles. |
| Stopping is advisory, never preemptive | `scope.stop()` (or cancelling the `flowCollect` subscription) starts no new work; started futures still run to their own settlement. |
| One scope per call | When you omit `scope`, each call creates one internal scope that stays private to that call. |

> [!WARNING]
> A transform already in flight still runs to completion — Dart cannot preempt
> it, and a transform that ignores the scope runs on too. Honor the scope
> inside your transform (stop early when `scope.isStopped` turns true) for
> prompt shutdown; extra work stays bounded by the runner count.

> [!WARNING]
> In `flowFirst`, failures never cancel siblings — runners keep racing until
> the first success or until every input fails. You reach for `flowFirst` when
> any single success is enough and input order does not matter; you reach for
> `flowMap` when you need every value in order.

## When to use the stdlib directly

You stay with `dart:async` when it already owns the shape: `Future.wait`
joins an unbounded set you want fully joined, `Future.any` settles on the
first value or error, `Stream.fromFutures` forwards unbounded
completion-order futures, and a plain `async` loop runs single-flight work
with no cap. You reach for `flow` when you need a bounded in-flight cap
with input-order results, a first-success race that survives failures, or a
typed `Result` per input that composes with the `result` helpers instead of
`try`/`catch` at the listener.

## Next step

When the problem is duplicate suppression rather than parallel transform —
concurrent callers stampeding one backend behind the same key — you share
one in-flight execution per key instead of racing. See
`docs/guides/singleflight.md`. For the first-success shape end to end, run
recipe (b) in [cookbook](../cookbook.md).
