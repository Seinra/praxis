# repo — one identity-addressed record store

You hold one record per identity behind a caller-supplied extractor: you
store or replace with `put`, you read absence as a value with `get`, you
drop with `remove`, and you snapshot with `list`.

**Version:** Praxis `0.1.0-dev`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';` exposes `Repository`.

## Concept

A `Map` names keyed storage but no lifecycle: no extracted-identity rule,
no upsert policy, no absent-instead-of-throw read, no snapshot discipline.
`Repository` owns that lifecycle as a slot table over an SDK map. Identity
comes from the `keyOf` extractor you supply, never from the record type,
so `String` slugs and `int` numbers address records the same way. This
store never persists: paging, queries, and validity stay caller or adapter
policy, never store behavior.

## Quick path

1. Create the store with your identity extractor: `Repository(keyOf: ...)`.
2. Store or replace a record: `lessonStore.put('lesson-a')`.
3. Read through `Opt`: `lessonStore.get('lesson-a').isPresent`.
4. Drop one identity: `lessonStore.remove('lesson-a')`.
5. Snapshot everything stored: `lessonStore.list()`.

## Which type?

The package doc (`lib/src/repo.dart`) is the source; this table mirrors
its "Which function?" table:

| When you want to ...                            | Reach for ...      |
| ----------------------------------------------- | ------------------ |
| Hold one key space of identity-addressed records | [Repository]       |
| Store or replace the record under its identity  | [Repository.put]   |
| Read the record as present-or-absent            | [Repository.get]   |
| Drop one identity, reporting what was held      | [Repository.remove] |
| Read a fresh snapshot of every stored record    | [Repository.list]  |

## Example

From `test/docs_guides_c_test.dart` (group `repo guide`):

```dart
import 'package:praxis/praxis.dart';

void main() {
  final Repository<String, String> lessonStore = Repository<String, String>(
    keyOf: (String candidate) => candidate,
  );
  lessonStore.put('lesson-a');
  lessonStore.put('lesson-b');
  print(lessonStore.get('lesson-a').isPresent); // Output: true
  print(lessonStore.list()); // Output: [lesson-a, lesson-b]
  print(lessonStore.remove('lesson-a')); // Output: true
  print(lessonStore.list()); // Output: [lesson-b]
}
```

Run it: `dart test test/docs_guides_c_test.dart -n 'repo guide'`.

> [!WARNING]
> Create a fresh store per test instead of sharing one. The store is
> caller-owned mutable state, and a shared store leaks puts from one test
> into the next. Never treat `list()` as live storage either: it returns a
> fresh snapshot per call, so mutating the snapshot never touches the
> store and later puts never rewrite an earlier snapshot.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| Upsert replaces, never duplicates | A duplicate `put` replaces the record and keeps one entry per identity; `put` stays total and never throws for duplicates. |
| Replacing keeps the listing position | `list` still reports a replaced identity where it was first stored; removing then re-storing moves the identity to the end. |
| Missing reads are absence, never throws | `get` on a missing identity answers absent `Opt` instead of throwing. |
| Removal is idempotent | `remove` reports `true` when it drops a record and `false` when nothing was held; missing identities never throw. |
| Snapshots are fresh and ordered | Every `list` call copies into a fresh growable list in first-stored-first-listed order; an empty store lists an empty snapshot, never `null`. |

## When to use the stdlib directly

Reach for a plain `Map` when no lifecycle needs naming: you hold the keys
yourself, a missing key throwing (or a nullable read) is acceptable, and
live `keys`/`values` views cause no aliasing trouble. Reach for
`Repository` when identity extraction, upsert policy, absent-instead-of-
throw reads, or snapshot discipline is the lesson.

## Next step

Records you fetch over HTTP land here: see [httpx](httpx.md) for the typed
JSON envelope that delivers them.
