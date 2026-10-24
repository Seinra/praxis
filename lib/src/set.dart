/// Typed distinct-value helpers over [Set], layered on `dart:core` instead
/// of replacing it.
///
/// Reach for these when the SDK names the parts but not the outcome: an
/// either-side exclusivity, a named subset direction, or a share-nothing
/// probe without an intermediate allocation. Reach for the SDK directly
/// when it already names the operation (`union`, `intersection`,
/// `difference`, `containsAll`). Every helper is pure: inputs are never
/// mutated and set outputs are fresh values.
///
/// Which function?
///
/// | When you want to ...                  | Reach for ...         |
/// | ------------------------------------- | --------------------- |
/// | Members held by exactly one side      | [symmetricDifference] |
/// | Ask whether every member is held      | [isSubsetOf]          |
/// | Ask whether every other member is held | [isSupersetOf]       |
/// | Ask whether sides share no member     | [isDisjointFrom]      |
/// | Ask whether holdings match by members | [hasSameMembers]      |
///
/// An empty set is a normal outcome here, never an error: every helper is
/// empty-safe, and the boolean probes answer directly without building an
/// intermediate set.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
library;

/// Returns the members held by exactly one of [firstMembers] or [secondMembers].
///
/// | When you want to ...             | Reach for ...         |
/// | -------------------------------- | --------------------- |
/// | Members held by exactly one side | [symmetricDifference] |
///
/// `dart:core` has no symmetric-difference helper: spelling it with the
/// SDK takes `union` plus `intersection` plus `difference` across three
/// intermediate allocations, and the intent hides inside the composition
/// (DART-SDK). [symmetricDifference] fills that gap with one pass per
/// side into a fresh set, mirroring the Axiom `set` SymmetricDifference
/// precedent (AXIOM-SISTER).
///
/// Returns a fresh empty set when both sides match or both are empty.
/// Never mutates [firstMembers] or [secondMembers].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final difference = symmetricDifference(<int>{1, 2, 3}, <int>{3, 4});
/// print(difference.containsAll(<int>{1, 2, 4})); // true
/// ```
Set<Element> symmetricDifference<Element>(
  Set<Element> firstMembers,
  Set<Element> secondMembers,
) {
  final Set<Element> difference = <Element>{};
  for (final Element candidateMember in firstMembers) {
    if (!secondMembers.contains(candidateMember)) {
      difference.add(candidateMember);
    }
  }
  for (final Element candidateMember in secondMembers) {
    if (!firstMembers.contains(candidateMember)) {
      difference.add(candidateMember);
    }
  }
  return difference;
}

/// Reports whether every member of [firstMembers] is held by [secondMembers].
///
/// | When you want to ...             | Reach for ... |
/// | -------------------------------- | ------------- |
/// | Ask whether every member is held | [isSubsetOf]  |
///
/// `dart:core` answers this shape with [Set.containsAll], which is an
/// `Iterable` probe with an inverted reading direction: the superset
/// calls it with the subset as the argument, so the inclusion order
/// reads backwards at the call site (DART-SDK). [isSubsetOf] fills that
/// gap with a named set-to-set relation plus a length fast path, so the
/// inclusion order reads left to right, mirroring the Axiom `set`
/// IsSubsetOf precedent (AXIOM-SISTER).
///
/// Returns `true` when [firstMembers] is empty: an empty side adds no
/// counterexample. Never mutates [firstMembers] or [secondMembers].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// print(isSubsetOf(<int>{1, 2}, <int>{1, 2, 3})); // true
/// ```
bool isSubsetOf<Element>(
  Set<Element> firstMembers,
  Set<Element> secondMembers,
) {
  if (firstMembers.length > secondMembers.length) {
    return false;
  }
  for (final Element candidateMember in firstMembers) {
    if (!secondMembers.contains(candidateMember)) {
      return false;
    }
  }
  return true;
}

/// Reports whether every member of [secondMembers] is held by [firstMembers].
///
/// | When you want to ...                  | Reach for ...   |
/// | ------------------------------------- | --------------- |
/// | Ask whether every other member is held | [isSupersetOf] |
///
/// `dart:core` has no named superset predicate: callers either invert a
/// [Set.containsAll] call or negate a subset check inline, and both hide
/// which side promises the coverage (DART-SDK). [isSupersetOf] fills
/// that gap as the symmetric vocabulary of [isSubsetOf], delegating to
/// the swapped subset check, mirroring the Axiom `set` IsSupersetOf
/// precedent (AXIOM-SISTER).
///
/// Returns `true` when [secondMembers] is empty: nothing promises nothing
/// to cover. Never mutates [firstMembers] or [secondMembers].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// print(isSupersetOf(<int>{1, 2, 3}, <int>{1, 2})); // true
/// ```
bool isSupersetOf<Element>(
  Set<Element> firstMembers,
  Set<Element> secondMembers,
) {
  return isSubsetOf<Element>(secondMembers, firstMembers);
}

/// Reports whether [firstMembers] and [secondMembers] share no member.
///
/// | When you want to ...              | Reach for ...    |
/// | -------------------------------- | ---------------- |
/// | Ask whether sides share no member | [isDisjointFrom] |
///
/// `dart:core` answers this shape with `intersection` plus `isEmpty`,
/// which builds a full intermediate set only to throw it away
/// (DART-SDK). [isDisjointFrom] fills that gap with a direct probe that
/// walks the smaller side and exits on the first shared member, so no
/// intermediate set is ever built, mirroring the Axiom `set` IsDisjoint
/// precedent (AXIOM-SISTER).
///
/// Returns `true` when either side is empty: an empty side shares
/// nothing. Never mutates [firstMembers] or [secondMembers].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// print(isDisjointFrom(<int>{1, 2}, <int>{3, 4})); // true
/// ```
bool isDisjointFrom<Element>(
  Set<Element> firstMembers,
  Set<Element> secondMembers,
) {
  Set<Element> smallerMembers = firstMembers;
  Set<Element> largerMembers = secondMembers;
  if (smallerMembers.length > largerMembers.length) {
    smallerMembers = secondMembers;
    largerMembers = firstMembers;
  }
  for (final Element candidateMember in smallerMembers) {
    if (largerMembers.contains(candidateMember)) {
      return false;
    }
  }
  return true;
}

/// Reports whether [firstMembers] and [secondMembers] hold exactly the same members.
///
/// | When you want to ...                  | Reach for ...    |
/// | ------------------------------------- | ---------------- |
/// | Ask whether holdings match by members | [hasSameMembers] |
///
/// `dart:core` `==` on sets reports identity, not membership, so two
/// separately built holdings with the same members compare unequal
/// (DART-SDK). [hasSameMembers] fills that gap with one structural
/// check — equal lengths plus a single [Set.containsAll] pass — so tests
/// and distinct-value logic compare by membership, mirroring the Axiom
/// `set` Equal precedent (AXIOM-SISTER).
///
/// Returns `true` for two empty sides. Never mutates [firstMembers] or
/// [secondMembers].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// print(hasSameMembers(<int>{1, 2}, <int>{2, 1})); // true
/// ```
bool hasSameMembers<Element>(
  Set<Element> firstMembers,
  Set<Element> secondMembers,
) {
  if (firstMembers.length != secondMembers.length) {
    return false;
  }
  return secondMembers.containsAll(firstMembers);
}
