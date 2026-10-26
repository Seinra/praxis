# di — name services once, build them lazily

You hold one lazy singleton per service name behind explicit factories. You
`register` each factory with an optional dispose hook, `resolve` the shared
singleton (built once on first use and cached), `unregister` one
registration for tests, and `reset` every registration in reverse order for
test isolation. Factories stay sync; scopes, hierarchies, and auto-wiring
stay out of scope.

**Version:** Praxis `0.1.0-dev`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';`. You hold the service
names and the factories that build them. You create a fresh container per
test instead of sharing one.

## Quick path

1. Create the container: `ServiceContainer()`.
2. Name a factory: `services.register<String>('greeting', () => 'hello');`.
3. Read the singleton: `services.resolve<String>('greeting')`.
4. Tear down for tests: `services.unregister('greeting')` or `services.reset()`.

## Which function?

The package doc (`lib/src/di.dart`) is the source; this table mirrors its
"Which function?" table:

| When you want to ...                                  | Reach for ...                 |
| ----------------------------------------------------- | ----------------------------- |
| Hold one key space of named singletons                | [ServiceContainer]            |
| Name a lazy factory plus an optional dispose hook     | [ServiceContainer.register]   |
| Read the shared singleton, building once on first use | [ServiceContainer.resolve]    |
| Drop one registration, disposing when built           | [ServiceContainer.unregister] |
| Tear every registration down in reverse order         | [ServiceContainer.reset]      |

## Example

Runnable — asserted by `test/docs_guides_b_test.dart` (same outputs):

```dart
import 'package:praxis/praxis.dart';

void main() {
  final ServiceContainer services = ServiceContainer();
  services.register<String>('greeting', () => 'hello');
  services.register<int>('answer', () => 42);
  print(services.resolve<String>('greeting')); // hello
  print(services.resolve<int>('answer')); // 42

  services.unregister('greeting');
  print(services.resolve<int>('answer')); // 42
  services.reset();
}
```

Expected output:

```text
hello
42
42
```

Resolving `greeting` after `unregister` throws `StateError`, and resolving
anything after `reset` throws `StateError` — both are programmer errors,
never domain failures. There is no global registry: every test creates a
fresh container instead of sharing one.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| First registration wins | A second `register` under the same name throws `StateError` and leaves the original untouched. A test-seed swap is `unregister` plus `register` — no replace halfway state. |
| Build once, retry on failure | The first `resolve` runs the factory and later resolves share the cached value; a throwing factory leaves nothing cached, so the next `resolve` retries instead of serving the failure. |
| Dispose runs on teardown, newest first | `unregister` removes first, then runs the dispose hook with the built value; never-built registrations dispose nothing. `reset` disposes built singletons in reverse registration order so later registrations release before their dependencies, and every built singleton is disposed even when a hook throws. |
| Types are checked at the crossing | Resolving under a supertype of the registered type shares the same singleton; resolving under an unrelated type throws `StateError` without evicting the cached value. |
| Empty and missing names throw | An empty service name throws `ArgumentError`; resolving or unregistering a missing name throws `StateError`. |

> [!WARNING]
> A factory that transitively resolves its own service recurses — cycle
> detection is a programmer error, never a checked failure, so you keep the
> dependency graph acyclic by construction. And factories stay synchronous by
> design: when a service needs an async build, that design belongs to a
> future package, not to this container.

## When to use the stdlib directly

You stay with `dart:core` when you need keyed storage but not a lifecycle:
a plain `Map` stores values with no lazy-once build, no failing-build
retry, and no reverse-order dispose. Constructor injection covers most call
sites with no container at all. You reach for `di` when several services
share one key space of named singletons with lazy builds and teardown that
a bare map cannot express.

## Next step

When service work fans out with a cap — many inputs through one resolved
dependency — you resolve once and hand the singleton to `flowMap` instead
of resolving per input. See `docs/guides/flow.md`. To hold a store behind
a named singleton, run recipe (c) in [cookbook](../cookbook.md).
