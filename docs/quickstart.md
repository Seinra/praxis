# Praxis quickstart: point, run, verify

You point a scratch package at Praxis through a path dependency, run one typed pipeline over `result` plus `lists`, and watch it print `42` and `2 true`.

**Version:** 0.1.0-dev on Dart ^3.13.0
**Prereqs:** Dart `^3.13.0` in your `PATH` (`dart --version` reports `3.13.x`), plus a local Praxis checkout.

## Quick path

### 1. Point a scratch package at Praxis

Create the scratch package and wire it to your checkout:

```bash
mkdir praxis_hello && cd praxis_hello
```

Save this as `pubspec.yaml`, replacing `<path-to-praxis>` with your checkout path:

```yaml
name: praxis_hello

environment:
  sdk: ^3.13.0

dependencies:
  praxis:
    path: <path-to-praxis>
```

Then fetch dependencies:

```bash
dart pub get
```

> [!NOTE]
> Praxis stays private while it grows toward the library bar, so you consume it through a path dependency. Publishing waits for the maturity gate.

### 2. Run your first typed pipeline

Save this as `bin/praxis_hello.dart`. It runs as-is — no edits needed:

```dart
import 'package:praxis/src/lists.dart';
import 'package:praxis/src/result.dart';

void main() {
  final Result<int> current = Result<int>.ok(21);
  final Result<int> doubled = current.mapValue(
    (int successValue) => successValue * 2,
  );
  print(doubled.getOrElse(0));

  final List<int> numbers = <int>[1, 2, 3];
  final ({int? value, bool present}) found = findElement(
    numbers,
    (int candidate) => candidate > 1,
  );
  print('${found.value} ${found.present}');
}
```

Then run it:

```bash
dart run
```

Expected output:

```text
42
2 true
```

### 3. Verify the library

From your Praxis checkout, run:

```bash
dart test
```

Expect every package green.

## Details

| Topic | Behavior |
| --- | --- |
| `Result.ok` | Wraps a success value as a `Result`; you build outcomes with `Result.ok` and `Result.failure`. |
| `mapValue` | Transforms the success side and carries failures through untouched; calls chain left to right. |
| `getOrElse` | Reads the success side with an explicit fallback for the failure side. |
| `findElement` | Scans for the first match and reports the `(value, present)` record; empty input or no match is a normal outcome, never a throw. Never trust `value` without `present`. |

## Checklist

- [ ] `dart run` prints `42` and `2 true` with no edits to `bin/praxis_hello.dart`
- [ ] `dart test` from the Praxis checkout stays green
- [ ] You can state what `mapValue` does to the failure side (it carries it through untouched)

## Next step

Your pipeline runs and the tree is green — work the three standalone recipes in the [cookbook](cookbook.md).
