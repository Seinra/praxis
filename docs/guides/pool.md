# pool — reuse values instead of rebuilding them

You hold recyclables with a factory plus an optional reset plus a bounded
idle cap. `Pool.acquire` borrows a value, creating through the factory when
idle is empty; `Pool.release` resets the borrowed value and stores it when
room remains, or discards it when idle is full; `Pool.use` borrows for one
call with guaranteed release. Everything here is synchronous: waiting
acquirers, timeouts, and cross-isolate sharing stay out of scope.

**Version:** Praxis `0.1.0-dev`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';`. You hold a factory
that builds fresh values, an optional reset, and the idle cap.

## Quick path

1. Create the pool: `Pool(create: StringBuffer.new, reset: (StringBuffer borrowedValue) => borrowedValue.clear(), maxSize: 2)`.
2. Borrow: `final StringBuffer borrowedBuffer = bufferPool.acquire();`.
3. Return: `bufferPool.release(borrowedBuffer);`.
4. Borrow for one call: `bufferPool.use<String>((StringBuffer borrowedValue) { ... })`.

## Which function?

The package doc (`lib/src/pool.dart`) is the source; this table mirrors its
"Which function?" table:

| When you want to ...                          | Reach for ...   |
| --------------------------------------------- | --------------- |
| Hold recyclables with factory plus reset plus cap | [Pool]      |
| Borrow a value, creating when idle is empty   | [Pool.acquire] |
| Return a value for reuse                      | [Pool.release] |
| Borrow for one call with guaranteed release   | [Pool.use]     |
| Ask how many idle values wait                 | [Pool.idleCount] |
| Read the idle cap                             | [Pool.maxSize] |

## Example

```dart
final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
  create: StringBuffer.new,
  reset: (StringBuffer borrowedValue) => borrowedValue.clear(),
  maxSize: 2,
);
final StringBuffer borrowedBuffer = bufferPool.acquire();
borrowedBuffer.write('hi');
bufferPool.release(borrowedBuffer);
print(bufferPool.idleCount); // 1

final String greeting = bufferPool.use<String>(
  (StringBuffer borrowedValue) {
    borrowedValue.write('hi');
    return borrowedValue.toString();
  },
);
print(greeting); // hi
```

`acquire` reuses the most recently released value and never throws for lack
of idle: empty and exhausted idle both create through the factory. `use`
acquires one value, runs the action, and releases in a `finally` block, so
callers cannot leak the borrowed value on the happy path — and action throws
still release when reset succeeds.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| Empty idle creates, never throws | `acquire` builds through the factory when nothing waits; factory throws propagate with nothing stored. |
| Full idle discards | `release` past `maxSize` drops the value instead of growing unbounded: `idleCount` stays at `maxSize`. |
| Double-release throws `ArgumentError` | Releasing the same identity twice without an intervening `acquire` would hand one mutable value to two borrowers, so the second release fails while the value stays idle. |
| Reset errors discard | A value whose reset throws is never stored; full-idle values leave no idle entry, so the double-release guard does not track them. |
| Non-positive caps throw | `Pool` with a `maxSize` of zero or less throws `ArgumentError`: unlike runtimes with GC-dropped pools, this core names the idle cap explicitly. |

> [!WARNING]
> You drop your reference after `release`: re-releasing a stale reference
> after an intervening `acquire` would alias one mutable value across two
> borrowers. Treat `release` as handing the value back — never retain it, and
> never release the same identity twice.

## When to use the stdlib directly

You stay with `dart:core` and `dart:collection` when you need storage but
not a lifecycle: a plain `List` or `Queue` holds values with no factory for
empty idle, no reset hook, and no idle cap. You reach for `pool` when reuse
needs the full lifecycle — create-when-empty, reset-on-return, and a bound
that keeps idle storage from growing without limit.

## Next step

When borrowers are async tasks under a cap rather than sync call sites, you
fan the work out with `flowMap` instead of pooling (see
`docs/guides/flow.md`). When the pooled values are named services with
lazy builds and teardown, you register them instead — see
`docs/guides/di.md`.
