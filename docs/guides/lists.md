# lists — typed searches, extremes, chunks, and splits over List

**Version:** praxis `0.1.0-dev` on Dart `^3.13.0`.
**Prereqs:** Dart SDK; `import 'package:praxis/src/lists.dart'`. Read
[foundations](foundations.md) first if generic syntax is new.

> API source: `lib/src/lists.dart` — doc comments are the reference; this
> guide is the bridge. Every runnable line here is asserted by
> `test/docs_guides_a_test.dart` — same outputs.

## Concept

The lists helpers answer the shapes the SDK names but never finishes: a
presence-flagged search, an absent-safe extreme, fresh-copy chunks, or a
one-pass split. Every helper is pure — inputs are never mutated and outputs
are fresh values. Empty input or no match is a normal outcome here, never an
error.

> [!WARNING]
> Never trust `value` without checking `present` first. A list may itself hold
> `null` elements, so only the flag tells a found `null` from an absent one —
> the same records-as-OrNull rule [foundations](foundations.md) teaches.

**When to use the stdlib directly:** `where`, `map`, `fold`, and `sort` stay
yours when the SDK already names the operation. You reach for these helpers
when the SDK shape ends halfway: `firstWhere` throws instead of flagging,
`dart:math` `min`/`max` take exactly two scalars, `sublist` carves one range
per call, and `where` keeps the matches but drops the rest.

## Steps

1. Search: `findElement` returns the first match as `(value, present)` — no
   `StateError` on a miss, no callback-shaped absence.
2. Extremes: `minElement`/`maxElement` scan once and stay absent-safe on empty
   input; ties keep the first minimal or maximal element.
3. Chunk: `chunkElements` cuts fixed-size fresh copies; a short final chunk
   carries the remainder.
4. Split: `partitionElements` walks once and returns both fresh lists as a
   `(matching, rest)` record.

## Which function?

Source: `lib/src/lists.dart` — this table mirrors the package Which-table
verbatim.

| When you want to ...                   | Reach for ...       |
| -------------------------------------- | ------------------- |
| Find the first match, presence-flagged | [findElement]       |
| Smallest element, absent-safe          | [minElement]        |
| Largest element, absent-safe           | [maxElement]        |
| Fixed-size chunks as fresh lists       | [chunkElements]     |
| Split into matching plus rest          | [partitionElements] |

## Example

Runnable — asserted by `test/docs_guides_a_test.dart` (same outputs):

```dart
import 'package:praxis/src/lists.dart';

void main() {
  final ({int? value, bool present}) found = findElement(
    <int>[72, 91, 85],
    (int score) => score > 80,
  );
  print(found.present ? found.value : -1); // 91

  final ({int? value, bool present}) lowest = minElement(<int>[3, 1, 2]);
  print(lowest.present ? lowest.value : -1); // 1

  print(chunkElements(<int>[1, 2, 3, 4, 5], 2)); // [[1, 2], [3, 4], [5]]

  final ({List<int> matching, List<int> rest}) split = partitionElements(
    <int>[1, 2, 3, 4],
    (int number) => number.isEven,
  );
  print(split); // (matching: [2, 4], rest: [1, 3])
}
```

Expected output:

```text
91
1
[[1, 2], [3, 4], [5]]
(matching: [2, 4], rest: [1, 3])
```

## Contracts

| Contract | What it means for you |
| --- | --- |
| Empty is normal | `findElement`, `minElement`, and `maxElement` return `(value: null, present: false)` on empty input without calling your function; chunk and partition return fresh empty collections. |
| Pure in, pure out | No helper mutates its input; chunks, groups, and both partition lists are fresh, so mutating the result never affects the source. |
| One pass where the SDK takes two | `partitionElements` calls your predicate once per element and returns both sides; the SDK `where` composition calls it twice per element. |
| Programmer errors throw | A `chunkSize` below `1` throws `ArgumentError` — a non-positive chunk size is a caller bug, not a domain outcome. |

> [!WARNING]
> Never pass a shared or reused list into `chunkElements` expecting views —
> every chunk is a fresh copy. You mutate the result freely; the input stays
> untouched, and that is the guarantee, not a side effect to work around.

## Next step

- Neighbor: [opt](opt.md) — the same presence discipline as a chainable value.
- Lazy pipelines over any `Iterable`: [iterx](iterx.md) — reach for it when the
  source is not a `List` or the pipeline should pull on demand.
