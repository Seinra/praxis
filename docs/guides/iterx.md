# iterx — lazy iterable adapters that pull on demand

**Version:** praxis `0.1.0-dev` on Dart `^3.13.0`.
**Prereqs:** Dart SDK; `import 'package:praxis/praxis.dart'`. Read
[foundations](foundations.md) first if generic syntax is new.

> API source: `lib/src/iterx.dart` — doc comments are the reference; this
> guide is the bridge. Every runnable line here is asserted by
> `test/docs_guides_a_test.dart` — same outputs.

## Concept

The iterx adapters complement the eager [lists](lists.md) helpers: each adapter
returns a lazy `Iterable` that runs nothing until you iterate, pulls one
element at a time, and stops pulling as soon as you stop. Chunk and window
outputs are fresh lists, and re-iterating re-runs the pipeline from the
source. An empty source is a normal outcome here, never an error.

> [!WARNING]
> Never realize an infinite generator without a bound. `cycleIterable` and
> `repeatElement` yield forever — you cap them with the SDK `take` before
> `toList`, or the pipeline never terminates.

**When to use the stdlib directly:** `map`, `where`, `expand`, `take`, `skip`,
`followedBy`, and `toList` stay yours when the SDK already names the operation;
`List.filled` and counted `Iterable.generate` stay yours for a finished
collection of a known size. You reach for these adapters when the source is an
`Iterable` rather than a `List`, the pipeline should stay lazy, or the output
is unbounded.

## Steps

1. Pair: `zipIterables` pulls both sides positionally and stops at the shorter
   side — stopping early stops pulling both sources.
2. Chunk lazily: `chunkedIterable` fills each fresh chunk as you pull; the
   size validates eagerly at call time and stays fully lazy after that.
3. Window: `windowedIterable` slides fresh windows of exactly one size,
   advancing by one; sources shorter than the window yield nothing.
4. Repeat: `cycleIterable` replays a short sequence forever (buffering one
   element at a time); `repeatElement` repeats one value forever.
5. Collapse: `deduplicateAdjacent` drops a repeat only when it directly follows
   an equal — non-adjacent repeats survive, unlike `toSet`.

## Which function?

Source: `lib/src/iterx.dart` — this table mirrors the package Which-table
verbatim.

| When you want to ...                          | Reach for ...         |
| --------------------------------------------- | --------------------- |
| Pair two iterables positionally               | [zipIterables]        |
| Fixed-size chunks as fresh lists, lazily      | [chunkedIterable]     |
| Sliding windows of exactly one size, lazily   | [windowedIterable]    |
| Repeat a source iterable forever in order     | [cycleIterable]       |
| Repeat one value forever                      | [repeatElement]       |
| Collapse adjacent duplicates, keeping order   | [deduplicateAdjacent] |

## Example

Runnable — asserted by `test/docs_guides_a_test.dart` (same outputs):

```dart
import 'package:praxis/praxis.dart';

void main() {
  print(zipIterables(<int>[1, 2, 3], <String>['a', 'b']).toList());
  // [(first: 1, second: a), (first: 2, second: b)]

  print(chunkedIterable(<int>[1, 2, 3, 4, 5], 2).toList());
  // [[1, 2], [3, 4], [5]]

  print(windowedIterable(<int>[1, 2, 3], 2).toList());
  // [[1, 2], [2, 3]]

  print(cycleIterable(<int>[1, 2]).take(5).toList());
  // [1, 2, 1, 2, 1]

  print(repeatElement(7).take(3).toList());
  // [7, 7, 7]

  print(deduplicateAdjacent(<int>[1, 1, 2, 1]).toList());
  // [1, 2, 1]
}
```

Expected output:

```text
[(first: 1, second: a), (first: 2, second: b)]
[[1, 2], [3, 4], [5]]
[[1, 2], [2, 3]]
[1, 2, 1, 2, 1]
[7, 7, 7]
[1, 2, 1]
```

## Contracts

| Contract | What it means for you |
| --- | --- |
| Lazy after validation | Invalid sizes throw `ArgumentError` at call time; creating the iterable pulls nothing, and each pull advances the source only as far as needed. |
| Pure in, pure out | No adapter mutates its source; chunks and windows are fresh lists, so mutating the result never affects the source. |
| Re-iteration re-runs | Iterating twice replays the pipeline from the source; breaking early stops pulling the source. |
| Empty is normal, except the infinite two | Empty sources yield empty results (except `cycleIterable` over empty, which yields nothing); the infinite generators are the caller's bound, never the adapter's. |

> [!WARNING]
> Never choose `deduplicateAdjacent` for all-seen uniqueness — it collapses
> only consecutive equals (`[1, 1, 2, 1]` keeps the trailing `1`). You reach
> for `toSet` or the eager [lists](lists.md) helpers when every duplicate must
> go regardless of position.

## Checklist

- [ ] You bound the infinite generators (`cycleIterable`, `repeatElement`)
  with `take` before you realize them.
- [ ] You can state the lazy rule (creating the iterable pulls nothing;
  breaking early stops pulling the source).
- [ ] You reach for `deduplicateAdjacent` only when consecutive duplicates
  must collapse (non-adjacent repeats survive).

## Next step

- Neighbor: [lists](lists.md) — the eager family; you reach for it when the
  input is already a `List` and you want a finished value in one pass.
- Presence-flagged search: [opt](opt.md) — when a pulled element may be absent
  and the absence must travel with the flag.
