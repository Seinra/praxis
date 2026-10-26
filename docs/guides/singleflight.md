# singleflight — share one execution across same-key callers

You stop concurrent callers from stampeding one backend behind the same key.
A `SingleflightGroup` holds one in-flight `Future` per key:
`SingleflightGroup.call` runs the leader's action once and hands the
identical future to late joiners, and completion forgets the key so the next
sequential call re-executes. Errors ride the shared future to every sharer;
callers retry explicitly with a fresh call.

**Version:** Praxis `0.1.0`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';` and
`import 'dart:async';`. You hold the request key and the async action to run
once while shared.

## Quick path

1. Create the key space: `SingleflightGroup<String, int>()`.
2. Share one execution: `flightGroup.call('user:7', () async => 42)`.
3. Retry explicitly: a fresh `call` after failure re-executes.

## Which function?

The package doc (`lib/src/singleflight.dart`) is the source; this table
mirrors its "Which function?" table:

| When you want to ...                            | Reach for ...          |
| ----------------------------------------------- | ---------------------- |
| Hold one key space with shared in-flight calls  | [SingleflightGroup]    |
| Share one execution across same-key callers     | [SingleflightGroup.call] |

## Example

Runnable — asserted by `test/docs_guides_b_test.dart` (same outputs):

```dart
import 'package:praxis/praxis.dart';

Future<void> main() async {
  final SingleflightGroup<String, int> flightGroup =
      SingleflightGroup<String, int>();
  int executionCount = 0;
  Future<int> loadUser() => flightGroup.call('user:7', () async {
    executionCount += 1;
    return 42;
  });
  final List<int> sharedResults = await Future.wait(<Future<int>>[
    loadUser(),
    loadUser(),
  ]);
  print(sharedResults); // [42, 42]
  print(executionCount); // 1
}
```

Expected output:

```text
[42, 42]
1
```

The check-then-store runs synchronously with no `await` between, so late
joiners attach atomically on the single-threaded event loop. Different keys
run independently; the map never grows past the live keys because settlement
forgets each key on success and on failure.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| One execution per key while in flight | Concurrent same-key callers receive the identical future instance; the action runs once. |
| Settlement forgets the key | Success and failure both release the key through an identity check, so a settled entry never blocks the next sequential call — and never evicts its replacement. |
| Failures reach every sharer | The shared future completes with the identical error instance for all sharers. Sequential calls re-execute by design: this package dedupes concurrency, it never caches outcomes. |
| Sync throws stay caller-local | A synchronously throwing action becomes an error future for that caller only: nothing was stored, nothing was shared, and the key stays free. |
| No waiting queues or timeouts | There are no `Timer` deadlines here. Slow leaders keep every sharer waiting until they settle. |

> [!WARNING]
> Every sharer holds the identical future — and the identical outcome. When
> the outcome is a shared mutable value, every sharer must treat it as
> read-only, or one caller's mutation leaks into the others. And when you
> need the value to persist past settlement with a TTL, you need a cache
> (a future package), not this one: sequential calls here always
> re-execute.

## When to use the stdlib directly

You stay with `dart:async` when keys never overlap: `Future.wait` joins an
already-known set of futures where every future runs whether or not keys
match, and `Stream.fromFutures` shares one subscription across listeners,
not one execution across callers. You reach for `singleflight` when
concurrent callers converge on the same key and only one execution must run
while the key is live.

## Next step

When the problem is parallel transform rather than duplicate suppression —
every input needs its own run under a cap — you fan out with `flowMap`
instead of sharing. See `docs/guides/flow.md`.
