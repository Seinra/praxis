# orderedmap — insertion order plus a bounded recency cache

You replay entries in first-insertion order with `OrderedMap`, and you
bound memory with every hit refreshing recency through `LruCache`.

**Version:** Praxis `0.1.0-dev`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';` exposes `OrderedMap`
and `LruCache`.

## Concept

`LinkedHashMap` iterates in insertion order, but `operator []` answers
`null` both when the key is missing and when the key holds a `null`
value — absence needs a second `containsKey` probe, and `keys`/`values`
expose live views instead of snapshots. `OrderedMap` fills that gap with
one-probe `get` answering the `(value, present)` record plus fresh-snapshot
`keys`/`values`. Neither SDK map names eviction, so `LruCache` pins that
lesson next to it: fixed capacity, refresh-on-hit, evict
least-recently-used-first. For failures with causes see the result
package; for a wrapped maybe see opt.

## Quick path

1. Build an empty ordered map: `OrderedMap<String, int>()`.
2. Add or replace: `scoresByName.put('ann', 91)`.
3. Read in one probe: `scoresByName.get('ann')`.
4. Replay the order: `scoresByName.keys()` and `scoresByName.values()`.
5. Bound memory: `LruCache<String, int>(2)` — `put` stores and evicts
   least-recently-used-first, `get` reads while refreshing recency.

## Which function?

The package doc (`lib/src/orderedmap.dart`) is the source; this table
mirrors its "Which function?" table:

| When you want to ...                          | Reach for ...     |
| --------------------------------------------- | ----------------- |
| Remember insertion order alongside lookup     | [OrderedMap]      |
| Bound memory with least-recently-used eviction | [LruCache]       |
| Build an empty ordered map                    | [OrderedMap.new]  |
| Build a bounded recency cache                 | [LruCache.new]    |
| Add or replace an entry                       | [OrderedMap.put]  |
| Read an entry (cache: refreshes recency)      | [OrderedMap.get]  |
| Remove an entry                               | [OrderedMap.remove] |
| Count held entries                            | [OrderedMap.length] |
| Ask whether nothing is held                   | [OrderedMap.isEmpty] |
| Ask whether something is held                 | [OrderedMap.isNotEmpty] |
| Replay keys or values in insertion order      | [OrderedMap.keys] |
| Read a cached entry refreshing its recency    | [LruCache.get]    |
| Store a cached entry evicting when full       | [LruCache.put]    |
| Read the cache bound                          | [LruCache.capacity] |
| Count cached entries                          | [LruCache.length] |

## Example

Example contents are asserted by `test/docs_guides_c_test.dart` (group `orderedmap guide`):

```dart
import 'package:praxis/praxis.dart';

void main() {
  final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
  scoresByName.put('ann', 91);
  scoresByName.put('bob', 72);
  print(scoresByName.keys()); // Output: [ann, bob]
  print(scoresByName.get('ann').value); // Output: 91

  final LruCache<String, int> recentScores = LruCache<String, int>(2);
  recentScores.put('ann', 91);
  recentScores.put('bob', 72);
  recentScores.put('cid', 85);
  print(recentScores.get('ann').present); // Output: false
  print(recentScores.length); // Output: 2
}
```

Expected output:

```text
[ann, bob]
91
false
2
```

Run it: `dart test test/docs_guides_c_test.dart -n 'orderedmap guide'`.

> [!WARNING]
> A cache `get` is a read with a write effect: every hit moves the key to
> most-recent, so probing entries reshuffles what `put` evicts next. Never
> construct a cache with a non-positive bound either — capacity is fixed at
> construction, and `LruCache(0)` throws `ArgumentError` instead of holding
> nothing. Never trust `value` without `present` here as well: a held
> `null` reads `(value: null, present: true)`.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| Upsert keeps first-insertion position | Replacing a key's value never moves it; removing then re-putting takes the back. |
| Missing keys are absence, never throws | `get` on a missing key answers `(value: null, present: false)`; `remove` on a missing key is a no-op. |
| Replays are fresh snapshots | `keys()` and `values()` answer fresh lists aligned with each other, so mutating a replay never disturbs the map. |
| Hits refresh recency | Every `LruCache.get` hit and every `put` moves the key to most-recent; overflow evicts least-recently-used-first. |
| Capacity is fixed and enforced | The cache never holds more than `capacity` entries; a non-positive capacity throws `ArgumentError` at construction. |
| Inputs are never aliased | Constructors take no caller collections, so there is no aliasing surface. |

## When to use the stdlib directly

Reach for `LinkedHashMap` (or a plain map literal, which is one) when
insertion-order iteration is enough: nullable reads are acceptable and no
presence flag or bound applies. Reach for `SplayTreeMap` when sorted-key
iteration is the job. Reach for `OrderedMap` when one-probe presence-flag
reads plus snapshot replays teach better, and for `LruCache` when memory
stays bounded under refresh-on-hit eviction.

## Checklist

- [ ] You can state the position rule in one sentence (replacing a key never moves it; removing then re-putting takes the back).
- [ ] You can state the absence rule in one sentence (a missing `get` answers `(value: null, present: false)` and a missing `remove` is a no-op).
- [ ] You can state the recency rule in one sentence (every `LruCache` hit refreshes recency and overflow evicts least-recently-used-first within the fixed `capacity`).

## Next step

When entries become identity-addressed records with an upsert lifecycle,
see [repo](repo.md) for the store that owns that policy.
