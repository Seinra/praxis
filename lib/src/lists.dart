/// Typed list helpers over [List], layered on `dart:core` instead of
/// replacing it.
///
/// Reach for these when the SDK names the shape but not the outcome: a
/// presence-flag search, an absent-safe extreme, fresh-copy chunks, or a
/// one-pass split. Reach for the SDK directly when it already names the
/// operation (`where`, `map`, `fold`, `sort`). Every helper is pure: inputs
/// are never mutated and outputs are fresh values.
///
/// Which function?
///
/// | When you want to ...                   | Reach for ...       |
/// | -------------------------------------- | ------------------- |
/// | Find the first match, presence-flagged | [findElement]       |
/// | Smallest element, absent-safe          | [minElement]        |
/// | Largest element, absent-safe           | [maxElement]        |
/// | Fixed-size chunks as fresh lists       | [chunkElements]     |
/// | Split into matching plus rest          | [partitionElements] |
///
/// The `(value, present)` record on [findElement], [minElement], and
/// [maxElement] is this package's OrNull: `present` reports presence and
/// `value` is `null` when absent. Empty input or no match is a normal
/// outcome here, never an error. Never trust `value` without checking
/// `present` first: a list may itself hold `null` elements, so only the
/// flag tells a found `null` from an absent one.
library;

/// Finds the first element satisfying [shouldMatch].
///
/// | When you want to ...                   | Reach for ... |
/// | -------------------------------------- | ------------- |
/// | Find the first match, presence-flagged | [findElement] |
///
/// `dart:core` answers this shape with [List.firstWhere], which throws a
/// [StateError] when nothing matches and reports absence through a
/// callback (`orElse`), never through a flag (DART-SDK). [findElement]
/// fills that gap: it returns the `(value, present)` OrNull record
/// instead, mirroring the Axiom `slice` precedent of `(value, bool)`
/// presence pairs (AXIOM-SISTER), so empty input or no match stays a
/// normal outcome.
///
/// Returns `(value: null, present: false)` without calling [shouldMatch]
/// when [elements] is empty. Never mutates [elements].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0` (records).
///
/// ```dart
/// final scores = <int>[72, 91, 85];
/// final found = findElement(scores, (score) => score > 80);
/// if (found.present) {
///   print(found.value); // 91
/// }
/// ```
({Element? value, bool present}) findElement<Element>(
  List<Element> elements,
  bool Function(Element) shouldMatch,
) {
  for (final candidate in elements) {
    if (shouldMatch(candidate)) {
      return (value: candidate, present: true);
    }
  }
  return (value: null, present: false);
}

/// Returns the smallest element of [elements].
///
/// | When you want to ...          | Reach for ... |
/// | ----------------------------- | ------------- |
/// | Smallest element, absent-safe | [minElement]  |
///
/// `dart:core` has no smallest-over-a-list helper: `dart:math` `min` takes
/// exactly two scalars, and [List] ordering otherwise goes through `sort`,
/// which mutates in place (DART-SDK). The suffixed name keeps this clear
/// of that two-scalar `min` for callers importing both libraries.
/// The bound is `Comparable<Object>`, not `Comparable<Element>`: `int`
/// implements `Comparable<num>`, so an `Element`-bound would reject the
/// most common element type (DART-SDK).
/// [minElement] fills the gap with one pure scan that leaves [elements]
/// untouched, mirroring the Axiom `slice` precedent where empty input
/// yields the zero value plus `false` (AXIOM-SISTER); here the absent
/// value is `null`, so never trust `value` without checking `present`
/// first.
///
/// Returns `(value: null, present: false)` when [elements] is empty. Ties
/// keep the first minimal element. Never mutates [elements].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0` (records).
///
/// ```dart
/// final lowest = minElement(<int>[3, 1, 2]);
/// if (lowest.present) {
///   print(lowest.value); // 1
/// }
/// ```
({Element? value, bool present}) minElement<Element extends Comparable<Object>>(
  List<Element> elements,
) {
  if (elements.isEmpty) {
    return (value: null, present: false);
  }
  Element lowest = elements.first;
  for (final candidate in elements.skip(1)) {
    if (candidate.compareTo(lowest) < 0) {
      lowest = candidate;
    }
  }
  return (value: lowest, present: true);
}

/// Returns the largest element of [elements].
///
/// | When you want to ...         | Reach for ... |
/// | ---------------------------- | ------------- |
/// | Largest element, absent-safe | [maxElement]  |
///
/// `dart:core` has no largest-over-a-list helper: `dart:math` `max` takes
/// exactly two scalars, and [List] ordering otherwise goes through `sort`,
/// which mutates in place (DART-SDK). The suffixed name keeps this clear
/// of that two-scalar `max` for callers importing both libraries.
/// The bound is `Comparable<Object>`, not `Comparable<Element>`: `int`
/// implements `Comparable<num>`, so an `Element`-bound would reject the
/// most common element type (DART-SDK).
/// [maxElement] fills the gap with one pure scan that leaves [elements]
/// untouched, mirroring the Axiom `slice` precedent where empty input
/// yields the zero value plus `false` (AXIOM-SISTER); here the absent
/// value is `null`, so never trust `value` without checking `present`
/// first.
///
/// Returns `(value: null, present: false)` when [elements] is empty. Ties
/// keep the first maximal element. Never mutates [elements].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0` (records).
///
/// ```dart
/// final highest = maxElement(<String>['fig', 'pear', 'kiwi']);
/// if (highest.present) {
///   print(highest.value); // pear
/// }
/// ```
({Element? value, bool present}) maxElement<Element extends Comparable<Object>>(
  List<Element> elements,
) {
  if (elements.isEmpty) {
    return (value: null, present: false);
  }
  Element highest = elements.first;
  for (final candidate in elements.skip(1)) {
    if (candidate.compareTo(highest) > 0) {
      highest = candidate;
    }
  }
  return (value: highest, present: true);
}

/// Splits [elements] into consecutive fresh chunks of at most [chunkSize].
///
/// | When you want to ...             | Reach for ...   |
/// | -------------------------------- | --------------- |
/// | Fixed-size chunks as fresh lists | [chunkElements] |
///
/// `dart:core` has no chunk helper: [List.sublist] carves one range per
/// call and never validates the size (DART-SDK). [chunkElements] fills
/// that gap with one eager pass returning every chunk as a fresh list,
/// mirroring the Axiom `slice` Chunked precedent (AXIOM-SISTER).
///
/// Throws an [ArgumentError] when [chunkSize] is below `1`: a
/// non-positive chunk size is a programmer error, not a domain outcome.
/// Returns a fresh empty list when [elements] is empty. Every chunk is a
/// fresh list, so mutating the result never affects [elements]. Never
/// mutates [elements].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0` (records).
///
/// ```dart
/// final chunks = chunkElements(<int>[1, 2, 3, 4, 5], 2);
/// print(chunks); // [[1, 2], [3, 4], [5]]
/// ```
List<List<Element>> chunkElements<Element>(
  List<Element> elements,
  int chunkSize,
) {
  if (chunkSize < 1) {
    throw ArgumentError.value(chunkSize, 'chunkSize', 'needs size >= 1');
  }
  final List<List<Element>> chunks = <List<Element>>[];
  for (int start = 0; start < elements.length; start += chunkSize) {
    int end = start + chunkSize;
    if (end > elements.length) {
      end = elements.length;
    }
    chunks.add(elements.sublist(start, end));
  }
  return chunks;
}

/// Splits [elements] into matching plus rest, preserving order.
///
/// | When you want to ...          | Reach for ...       |
/// | ----------------------------- | ------------------- |
/// | Split into matching plus rest | [partitionElements] |
///
/// `dart:core` answers half of this shape with `where`, which keeps the
/// matches but drops the rest; recovering both sides takes two passes
/// that call [shouldMatch] twice per element (DART-SDK).
/// [partitionElements] fills the gap with one pass returning both fresh
/// lists as a `(matching, rest)` record, mirroring the Axiom `slice`
/// Partition precedent (AXIOM-SISTER).
///
/// Returns two empty lists without calling [shouldMatch] when [elements]
/// is empty. Never mutates [elements].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0` (records).
///
/// ```dart
/// final split = partitionElements(
///   <int>[1, 2, 3, 4],
///   (number) => number.isEven,
/// );
/// print(split); // (matching: [2, 4], rest: [1, 3])
/// ```
({List<Element> matching, List<Element> rest}) partitionElements<Element>(
  List<Element> elements,
  bool Function(Element) shouldMatch,
) {
  final List<Element> matching = <Element>[];
  final List<Element> rest = <Element>[];
  for (final candidate in elements) {
    if (shouldMatch(candidate)) {
      matching.add(candidate);
    } else {
      rest.add(candidate);
    }
  }
  return (matching: matching, rest: rest);
}
