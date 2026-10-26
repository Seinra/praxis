# mapx — typed reshapes over Map

**Version:** praxis `0.1.0` on Dart `^3.13.0`.
**Prereqs:** Dart SDK; `import 'package:praxis/praxis.dart'`. Read
[foundations](foundations.md) first if generic syntax is new.

> API source: `lib/src/mapx.dart` — doc comments are the reference; this guide
> is the bridge. Every runnable line here is asserted by
> `test/docs_guides_a_test.dart` — same outputs.

## Concept

The mapx helpers reshape a `Map` the SDK names only in parts: a grouped
inversion, a key-set projection, a single-channel transform, or an entry
grouping. Every helper is pure — inputs are never mutated and outputs are
fresh maps with fresh collections. An empty map is a normal outcome here,
never an error.

**When to use the stdlib directly:** `map`, `keys`, `values`, `containsKey`,
`update`, `putIfAbsent`, `addAll`, and `remove` stay yours when the SDK already
names the operation. You reach for these helpers when the SDK forces a
hand-rolled loop around those parts: inversion needs an entries loop plus
`putIfAbsent` plus a fresh list per unseen value, and projection needs a
`containsKey` probe plus `[]` per wanted key.

## Steps

1. Invert: `invertEntries` groups keys sharing one value into fresh lists.
2. Project: `pickEntries` keeps only the requested keys that are present;
   `omitEntries` drops the listed keys and keeps the rest. Missing keys are
   ignored by both.
3. Reshape: `mapValues` transforms every value and keeps keys; `mapKeys`
   remaps every key and keeps values.
4. Group: `groupEntriesBy` files entry values into fresh lists under a key
   your function derives.

## Which function?

Source: `lib/src/mapx.dart` — this table mirrors the package Which-table
verbatim.

| When you want to ...                   | Reach for ...   |
| --------------------------------------- | --------------- |
| Group keys sharing one value           | [invertEntries] |
| Keep only the requested keys            | [pickEntries]   |
| Drop the listed keys                    | [omitEntries]   |
| Transform every value, keep keys        | [mapValues]     |
| Remap every key, keep values            | [mapKeys]       |
| Group values by a derived key           | [groupEntriesBy] |

## Example

Runnable — asserted by `test/docs_guides_a_test.dart` (same outputs):

```dart
import 'package:praxis/praxis.dart';

void main() {
  print(invertEntries(<String, int>{'ann': 1, 'bob': 2, 'cid': 1}));
  // {1: [ann, cid], 2: [bob]}

  print(pickEntries(<String, int>{'ann': 1, 'bob': 2}, <String>['ann', 'missing']));
  // {ann: 1}

  print(omitEntries(<String, int>{'ann': 1, 'bob': 2}, <String>['ann']));
  // {bob: 2}

  print(mapValues(<String, int>{'ann': 1}, (int score) => score * 2));
  // {ann: 2}

  print(mapKeys(<String, int>{'ann': 1}, (String name) => name.toUpperCase()));
  // {ANN: 1}

  print(groupEntriesBy(
    <String, int>{'ann': 91, 'bob': 72},
    (String name, int score) => score >= 80 ? 'pass' : 'fail',
  ));
  // {pass: [91], fail: [72]}
}
```

Expected output:

```text
{1: [ann, cid], 2: [bob]}
{ann: 1}
{bob: 2}
{ann: 2}
{ANN: 1}
{pass: [91], fail: [72]}
```

## Contracts

| Contract | What it means for you |
| --- | --- |
| Empty is normal, and cheap | Every helper returns a fresh empty map on empty input; the grouping helpers never call your function when there is nothing to group. |
| Pure in, pure out | No helper mutates its inputs; every list inside `invertEntries` and `groupEntriesBy` is fresh, so mutating the result never affects the source. |
| Groups preserve encounter order | Grouped lists follow `Map` insertion order, and `pickEntries` follows your `wantedKeys` order. |
| Complements pair up | `pickEntries` keeps the wanted keys that are present; `omitEntries` keeps everything except the excluded keys; missing keys are ignored by both. |

> [!WARNING]
> Never assume inversion round-trips. Shared values collect into one list, so
> a plain reverse needs a rule for which key wins — and `mapKeys` collisions
> collapse the same way, with the last encountered key winning. You name the
> winner before you remap.

## Checklist

- [ ] You can state the empty-input rule (every helper returns a fresh empty
  map; the grouping helpers never call your function when there is nothing
  to group).
- [ ] You can state the purity rule (no helper mutates its inputs; every
  list inside `invertEntries` and `groupEntriesBy` is fresh).
- [ ] You name the collision rule before you remap (`mapKeys` lets the last
  encountered key win; inversion collects shared values into one list).

## Next step

- Neighbor: [lists](lists.md) — the eager family; `partitionElements` splits
  one collection into two while `groupEntriesBy` files entries under derived keys.
- Distinct holdings: [set](set.md) — when membership itself is the question,
  not the mapping.
