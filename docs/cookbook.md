# Praxis cookbook — three standalone recipes

Each recipe is a standalone program: drop it into a scratch package wired with the [quickstart](quickstart.md) install, run it with `dart run`, and compare with the expected output.

**Version:** 0.1.0 on Dart ^3.13.0.
**Prereqs for every recipe:** Dart `^3.13.0` and a scratch package holding the [quickstart](quickstart.md) install (`dart pub add praxis`).

## (a) The absence ladder — (value, present) → opt → result

You hold a loose value that may be missing (your own boundary: the `(value, present)` record), an absence to chain or transform (`Opt`), and a failure with a cause (`Result`). Climb only as far as the caller needs.

```dart
import 'package:praxis/src/lists.dart';
import 'package:praxis/src/opt.dart';
import 'package:praxis/src/result.dart';

void main() {
  final List<String> lessons = <String>[
    'generics-intro',
    'slices-deep',
    'maps-fast',
  ];
  // Rung 1: the (value, present) record at your own boundary.
  final ({String? value, bool present}) found = findElement(
    lessons,
    (String candidate) => candidate == 'slices-deep',
  );
  print('${found.value} ${found.present}');
  final ({String? value, bool present}) missed = findElement(
    lessons,
    (String candidate) => candidate == 'nope',
  );
  print('${missed.value == null} ${missed.present}');
  // Rung 2: Opt<String> to chain or transform the absence.
  final Opt<String> maybe = Opt<String>.present(found.value ?? 'nobody');
  print(maybe.valueOr('nobody'));
  print(const Opt<String>.absent().valueOr('nobody'));
  // Rung 3: Result<String> when absence becomes a failure with a cause.
  final Opt<String> missing = Opt<String>.absent();
  final Result<String> outcome = missing.isPresent
      ? Result<String>.ok(missing.valueOr('nobody'))
      : Result<String>.failure(Exception('lesson not found'));
  print(outcome.getOrElse('fallback-lesson'));
}
```

Expected output:

```text
slices-deep true
true false
slices-deep
nobody
fallback-lesson
```

> [!WARNING]
> Climb only as far as the caller needs: never trust the value without `present`, never use `Opt` for failures with causes, and never use `Result` for plain absence.

> [!NOTE]
> Praxis names no `Opt`-to-`Result` bridge: you branch on `isPresent` at the boundary, so the crossing stays visible in the code.

## (b) First success wins — flowFirst race over mirrors

You query several mirrors and keep the first success. Failures only free their slot while the race continues; a dead mirror never stops it.

```dart
import 'package:praxis/src/flow.dart';

Future<void> main() async {
  const String fastLesson = 'lesson from fast-mirror';
  final List<String> mirrors = <String>[
    'slow-mirror',
    'fast-mirror',
    'dead-mirror',
  ];
  final String winner = await flowFirst<String, String>(
    mirrors,
    maxInflight: 3,
    transform: (String mirror, FlowScope scope) {
      if (mirror == 'fast-mirror') {
        return Future<String>.value('lesson from $mirror');
      }
      return Future<String>.error(Exception('mirror unreachable: $mirror'));
    },
  );
  print('$winner ${winner == fastLesson}');
}
```

Expected output:

```text
lesson from fast-mirror true
```

> [!NOTE]
> The recipe fails two mirrors immediately instead of with timers, so the run stays deterministic — same winner, same output. The companion test (`test/docs_cookbook_test.dart`) pins this exact line.

## (c) Wired store — ServiceContainer plus Repository

You hold a store behind a named singleton: `register` the constructor once, `resolve` the shared store from any caller, and every caller sees the same records.

```dart
import 'package:praxis/src/di.dart';
import 'package:praxis/src/repo.dart';

/// A course lesson addressed by its slug.
final class Lesson {
  /// Creates a lesson with [slug] identity and [title] content.
  Lesson(this.slug, this.title);

  /// The identity address for the store.
  final String slug;

  /// The display title.
  final String title;
}

/// Extracts the slug identity; the store never reads the record itself.
String lessonKeyOf(Lesson candidate) => candidate.slug;

void main() {
  final ServiceContainer services = ServiceContainer();
  services.register<Repository<Lesson, String>>(
    'lessons',
    () => Repository<Lesson, String>(keyOf: lessonKeyOf),
  );
  final Repository<Lesson, String> lessons =
      services.resolve<Repository<Lesson, String>>('lessons');
  lessons.put(Lesson('generics-intro', 'Intro to Generics'));
  final Lesson fetched = lessons
      .get('generics-intro')
      .valueOr(Lesson('fallback', 'Fallback'));
  print(fetched.title);
  final Repository<Lesson, String> again =
      services.resolve<Repository<Lesson, String>>('lessons');
  print(identical(again, lessons));
}
```

Expected output:

```text
Intro to Generics
true
```

> [!NOTE]
> The final `true` proves the singleton: the second `resolve` returns the identical store, not a rebuild. Swap the registration in tests with `unregister` plus `register` (the first registration still wins until you drop it).

See the [di](guides/di.md) and [repo](guides/repo.md) guides for the contracts behind each half.

## Checklist

- [ ] Each recipe prints its expected output with no edits
- [ ] You can state when to stop climbing the absence ladder (only as far as the caller needs)
- [ ] You can state what the final `true` in recipe (c) proves (the second `resolve` returns the identical store)

## Next step

Pick the guide that matches what you hold next: [di](guides/di.md), [repo](guides/repo.md), and [flow](guides/flow.md) carry the contracts behind these recipes. New to generics syntax? Start with [foundations](guides/foundations.md).
