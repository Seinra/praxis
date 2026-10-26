# set — typed distinct-value helpers over Set

**Version:** praxis `0.1.0-dev` on Dart `^3.13.0`.
**Prereqs:** Dart SDK; `import 'package:praxis/src/set.dart'`. Read
[foundations](foundations.md) first if generic syntax is new.

> API source: `lib/src/set.dart` — doc comments are the reference; this guide
> is the bridge. Every runnable line here is asserted by
> `test/docs_guides_a_test.dart` — same outputs.

## Concept

The set helpers answer the shapes the SDK names but never finishes: an
either-side exclusivity, a named subset direction, or a share-nothing probe
without an intermediate allocation. Every helper is pure — inputs are never
mutated and set outputs are fresh values. An empty set is a normal outcome
here, never an error.

**When to use the stdlib directly:** `union`, `intersection`, `difference`,
and `containsAll` stay yours when the SDK already names the operation. You
reach for these helpers when the SDK forces a three-allocation composition
(symmetric difference), an inverted reading direction (`containsAll` called
backwards), or a throwaway intermediate set (disjointness via `intersection`
plus `isEmpty`).

## Steps

1. Combine: `symmetricDifference` returns the members held by exactly one side.
2. Direct: `isSubsetOf` reads inclusion left to right; `isSupersetOf` mirrors
   it as the symmetric vocabulary.
3. Probe: `isDisjointFrom` walks the smaller side and exits on the first shared
   member — no intermediate set is ever built.
4. Compare: `hasSameMembers` answers membership structurally, where `==` on
   sets reports identity and misleads.

## Which function?

Source: `lib/src/set.dart` — this table mirrors the package Which-table
verbatim.

| When you want to ...                  | Reach for ...         |
| ------------------------------------- | --------------------- |
| Members held by exactly one side      | [symmetricDifference] |
| Ask whether every member is held      | [isSubsetOf]          |
| Ask whether every other member is held | [isSupersetOf]       |
| Ask whether sides share no member     | [isDisjointFrom]      |
| Ask whether holdings match by members | [hasSameMembers]      |

## Example

Runnable — asserted by `test/docs_guides_a_test.dart` (same outputs):

```dart
import 'package:praxis/src/set.dart';

void main() {
  print(symmetricDifference(<int>{1, 2, 3}, <int>{3, 4})); // {1, 2, 4}
  print(isSubsetOf(<int>{1, 2}, <int>{1, 2, 3})); // true
  print(isSupersetOf(<int>{1, 2, 3}, <int>{1, 2})); // true
  print(isDisjointFrom(<int>{1, 2}, <int>{3, 4})); // true
  print(hasSameMembers(<int>{1, 2}, <int>{2, 1})); // true
}
```

Expected output:

```text
{1, 2, 4}
true
true
true
true
```

## Contracts

| Contract | What it means for you |
| --- | --- |
| Empty is normal | Every helper is empty-safe: an empty side adds no counterexample (`isSubsetOf`), shares nothing (`isDisjointFrom`), or compares by membership (`hasSameMembers` on two empty sides is `true`). |
| Pure in, pure out | No helper mutates its inputs; the set output is a fresh value. |
| No intermediate allocations for probes | `isDisjointFrom` walks the smaller side directly instead of building an intersection to throw away; `hasSameMembers` checks lengths before a single `containsAll` pass. |
| Direction reads left to right | `isSubsetOf(firstMembers, secondMembers)` asks whether every member of the first is held by the second; `isSupersetOf` is the swapped call, not an inverted probe. |

> [!WARNING]
> Never compare holdings with `==` — on sets it reports identity, not
> membership, so two separately built holdings with the same members compare
> unequal. You compare by membership with `hasSameMembers`.

## Next step

- Neighbor: [lists](lists.md) — ordered holdings with presence flags; sets
  answer membership while lists answer position.
- Grouped holdings: [mapx](mapx.md) — when keys map to values instead of
  standing alone as members.
