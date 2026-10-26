# task — one background computation, joined later

You start one computation now and join it later: `Task.spawn` runs the
work eagerly and hands back a handle, and `Task.join` reports its single
shared outcome as a typed `Result`.

**Version:** Praxis `0.1.0-dev`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';` exposes `Task` (and
`Result` for the joined outcome).

## Concept

A `Future` already joins later and shares one outcome across listeners,
but it carries failures as thrown objects outside the type — the same
sum-type gap `result` names over `dart:core`. `Task` owns the
eager-run-once plus `Result`-typed-join pair, so compute failures travel
inside the type and every joiner — before or after completion — receives
the identical outcome without re-running. Timeouts, cancellation scopes,
and groups stay out: cancellation belongs to `flow`'s `FlowScope`,
fan-out belongs to `flow`, per-key dedupe belongs to `singleflight`, and
lazy cold-starts stay plain `Future` closures.

## Quick path

1. Start the work now: `Task<int>.spawn(() async => 42)`.
2. Join it anywhere, any number of times: `await backgroundTask.join()`.
3. Branch the shared outcome: `outcome.getOrElse(0)`.
4. Shape the joined value with `Result` helpers (`mapValue`, `andThen`) —
   never with `Then`/`Map` combinators here.

## Which function?

The package doc (`lib/src/task.dart`) is the source; this table mirrors
its "Which function?" table:

| When you want to ... | Reach for |
| --- | --- |
| Hold one background computation with its shared outcome | [Task] |
| Start one computation now, join it later | [Task.spawn] |
| Join the computation and read its shared outcome | [Task.join] |

## Example

Example contents are asserted by `test/docs_guides_c_test.dart` (group `task guide`):

```dart
import 'package:praxis/praxis.dart';

Future<void> main() async {
  final Task<int> backgroundTask = Task<int>.spawn(() async => 42);
  final Result<int> outcome = await backgroundTask.join();
  print(outcome.getOrElse(0)); // Output: 42
  final Result<int> secondOutcome = await backgroundTask.join();
  print(identical(outcome, secondOutcome)); // Output: true
}
```

Expected output:

```text
42
true
```

Run it: `dart test test/docs_guides_c_test.dart -n 'task guide'`.

> [!WARNING]
> `join` never throws for a compute failure — it reports `Result.failure`
> instead. Do not await the raw computation beside the handle and re-add
> `try`/`catch` at every joiner; that rebuilds the exact scattering this
> package removes. Do not bolt `Then`/`Map` combinators onto the handle
> either: shape the joined outcome with `Result.mapValue` and
> `Result.andThen` over the value `join` already shares.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| Spawning runs the work exactly once | The computation starts before `spawn` returns — even when `join` never comes — and never re-runs. |
| Every join shares one outcome | Joiners before or after completion receive the identical `Result` instance; success arrives as `ok`, compute failures as `failure`. |
| Sync throws count as compute failures | A synchronous throw inside the computation becomes `failure` instead of escaping the constructor. |
| Non-`Exception` throwables arrive wrapped | `Exception` failures keep their identity; anything else arrives wrapped with its string form, because `Result` names `Exception` as its only failure value. |
| No cancellation, no groups, no laziness | `Task` runs one computation once and shares its outcome; it never dedupes keys and never caps concurrency. |

## When to use the stdlib directly

Reach for a raw `Future` when failures-as-throws fit the call site: one
`await` with a local `try`/`catch`, `Future.wait` for a fixed group, or a
lazy closure you only invoke on demand. Reach for `Task` when one eager
computation fans out to N joiners and every failure must travel as data.
Reach for `flow` when concurrency needs a cap, races need a first-success
win, or cancellation needs a scope.

## Checklist

- [ ] You can state the run-once rule in one sentence (the computation starts before `spawn` returns and never re-runs, even when `join` never comes).
- [ ] You can state the sharing rule in one sentence (every joiner receives the identical `Result` instance, before or after completion).
- [ ] You shape joined values with `Result` helpers instead of awaiting the raw computation beside the handle.

## Next step

Name the pure two-step shaping you apply to joined values with
[pipe](pipe.md) — one reusable function value instead of a nested call.
