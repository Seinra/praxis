/// Lazy iterable adapters over [Iterable], complementing the eager helpers in `lists`.
///
/// Reach for these when the source is an [Iterable], the pipeline should
/// pull on demand, or the output is unbounded: each adapter returns a lazy
/// [Iterable] that runs nothing until the caller iterates, pulls one
/// element at a time, and stops pulling as soon as the caller stops.
/// Reach for the eager `lists` helpers (`findElement`, `minElement`,
/// `maxElement`, `chunkElements`, `partitionElements`) when the input is
/// already a [List] and the caller wants a finished value in one pass.
/// Reach for the SDK directly when it already names the operation (`map`,
/// `where`, `expand`, `take`, `skip`, `followedBy`, `toList`). Every
/// adapter is pure: inputs are never mutated, chunk and window outputs are
/// fresh lists, and re-iterating re-runs the pipeline from the source.
///
/// Which function?
///
/// | When you want to ...                          | Reach for ...         |
/// | --------------------------------------------- | --------------------- |
/// | Pair two iterables positionally               | [zipIterables]        |
/// | Fixed-size chunks as fresh lists, lazily      | [chunkedIterable]     |
/// | Sliding windows of exactly one size, lazily   | [windowedIterable]    |
/// | Repeat a source iterable forever in order     | [cycleIterable]       |
/// | Repeat one value forever                      | [repeatElement]       |
/// | Collapse adjacent duplicates, keeping order   | [deduplicateAdjacent] |
///
/// An empty source is a normal outcome here, never an error: every adapter
/// is empty-safe except the infinite generators, which the caller bounds
/// with the SDK `take`. Invalid sizes are programmer errors and throw at
/// call time; valid sizes stay fully lazy.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0` (records,
/// `sync*` generators).
library;

import 'dart:collection';

/// Pairs elements from two iterables positionally, stopping at the shorter side.
///
/// | When you want to ...            | Reach for ...  |
/// | ------------------------------- | -------------- |
/// | Pair two iterables positionally | [zipIterables] |
///
/// `dart:core` has no zip helper: spelling it with the SDK takes two
/// iterators plus a manual loop at every call site, and the pairing intent
/// hides inside the composition (DART-SDK). [zipIterables] fills that gap
/// with one lazy pull per side, mirroring the Axiom `iterx` ZipSeq
/// precedent of stopping at the shorter input with deferred cleanup
/// (AXIOM-SISTER).
///
/// Pulls nothing until iterated and stops pulling both sides as soon as
/// the caller stops: `zipIterables(firstElements, secondElements).take(2)`
/// advances each source exactly twice. Re-iterating re-runs both sources
/// from the start. Reach for this adapter when either side is an
/// [Iterable], the pipeline is lazy, or either side is unbounded; reach
/// for the eager `lists` helpers when both sides are already [List]
/// values wanted as a finished paired list in one pass. Never mutates
/// [firstElements] or [secondElements].
///
/// Returns an empty iterable when either side is empty.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0` (records).
///
/// ```dart
/// final paired = zipIterables(<int>[1, 2, 3], <String>['a', 'b']);
/// print(paired.toList()); // [(first: 1, second: a), (first: 2, second: b)]
/// ```
Iterable<({FirstElement first, SecondElement second})>
zipIterables<FirstElement, SecondElement>(
  Iterable<FirstElement> firstElements,
  Iterable<SecondElement> secondElements,
) sync* {
  final Iterator<FirstElement> firstIterator = firstElements.iterator;
  final Iterator<SecondElement> secondIterator = secondElements.iterator;
  while (firstIterator.moveNext() && secondIterator.moveNext()) {
    yield (first: firstIterator.current, second: secondIterator.current);
  }
}

/// Groups an iterable into consecutive fresh chunks of at most [chunkSize], lazily.
///
/// | When you want to ...                       | Reach for ...     |
/// | ------------------------------------------ | ----------------- |
/// | Fixed-size chunks as fresh lists, lazily   | [chunkedIterable] |
///
/// `dart:core` has no chunk helper: [List.sublist] carves one range per
/// call and never validates the size (DART-SDK). [chunkedIterable] fills
/// that gap with chunks that fill as the caller pulls, mirroring the Axiom
/// `iterx` ChunkedSeq precedent of fresh copies with a short final chunk
/// (AXIOM-SISTER).
///
/// Validates [chunkSize] eagerly at call time and stays fully lazy after
/// that: creating the iterable pulls nothing, and each pulled chunk pulls
/// exactly [chunkSize] elements (fewer for the final chunk). Breaking
/// early stops pulling the source, and re-iterating re-runs from the
/// source. Reach for this adapter when the source is an [Iterable], the
/// pipeline is lazy, or the source is unbounded; reach for the eager
/// `chunkElements` lists helper when the input is already a [List] and the
/// caller wants every chunk as a finished `List` in one pass. Every chunk
/// is a fresh list, so mutating the result never affects [sourceElements].
/// Never mutates [sourceElements].
///
/// Throws an [ArgumentError] when [chunkSize] is below `1`: a
/// non-positive chunk size is a programmer error, not a domain outcome.
/// Returns an empty iterable when [sourceElements] is empty.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final chunks = chunkedIterable(<int>[1, 2, 3, 4, 5], 2);
/// print(chunks.toList()); // [[1, 2], [3, 4], [5]]
/// ```
Iterable<List<Element>> chunkedIterable<Element>(
  Iterable<Element> sourceElements,
  int chunkSize,
) {
  if (chunkSize < 1) {
    throw ArgumentError.value(chunkSize, 'chunkSize', 'needs size >= 1');
  }
  return _chunkedElements(sourceElements, chunkSize);
}

Iterable<List<Element>> _chunkedElements<Element>(
  Iterable<Element> sourceElements,
  int chunkSize,
) sync* {
  List<Element> pendingElements = <Element>[];
  for (final Element candidate in sourceElements) {
    pendingElements.add(candidate);
    if (pendingElements.length == chunkSize) {
      yield List<Element>.of(pendingElements);
      pendingElements = <Element>[];
    }
  }
  if (pendingElements.isNotEmpty) {
    yield List<Element>.of(pendingElements);
  }
}

/// Slides windows of exactly [windowSize] over an iterable, yielding fresh copies lazily.
///
/// | When you want to ...                         | Reach for ...      |
/// | -------------------------------------------- | ------------------ |
/// | Sliding windows of exactly one size, lazily  | [windowedIterable] |
///
/// `dart:core` has no sliding-window helper: spelling it with the SDK
/// takes a manual buffer plus index arithmetic at every call site
/// (DART-SDK). [windowedIterable] fills that gap with windows that fill as
/// the caller pulls, mirroring the Axiom `iterx` WindowsSeq precedent of
/// fresh copies advancing by one (AXIOM-SISTER).
///
/// Validates [windowSize] eagerly at call time and stays fully lazy after
/// that: creating the iterable pulls nothing, and each pulled window pulls
/// exactly one new element once the buffer is full. Breaking early stops
/// pulling the source, and re-iterating re-runs from the source. Reach for
/// this adapter when the source is an [Iterable] or the pipeline is lazy;
/// reach for the eager `lists` helpers when the input is already a [List]
/// and the caller wants a finished value in one pass. Every window is a
/// fresh list, so mutating the result never affects [sourceElements].
/// Never mutates [sourceElements].
///
/// Throws an [ArgumentError] when [windowSize] is below `1`: a
/// non-positive window size is a programmer error, not a domain outcome.
/// Returns an empty iterable when [sourceElements] is empty or shorter
/// than [windowSize].
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final windows = windowedIterable(<int>[1, 2, 3], 2);
/// print(windows.toList()); // [[1, 2], [2, 3]]
/// ```
Iterable<List<Element>> windowedIterable<Element>(
  Iterable<Element> sourceElements,
  int windowSize,
) {
  if (windowSize < 1) {
    throw ArgumentError.value(windowSize, 'windowSize', 'needs size >= 1');
  }
  return _windowedElements(sourceElements, windowSize);
}

Iterable<List<Element>> _windowedElements<Element>(
  Iterable<Element> sourceElements,
  int windowSize,
) sync* {
  final Queue<Element> windowElements = Queue<Element>();
  for (final Element candidate in sourceElements) {
    windowElements.addLast(candidate);
    if (windowElements.length < windowSize) {
      continue;
    }
    yield List<Element>.of(windowElements);
    windowElements.removeFirst();
  }
}

/// Repeats a source iterable forever in order, buffering incrementally.
///
/// | When you want to ...                      | Reach for ...   |
/// | ----------------------------------------- | --------------- |
/// | Repeat a source iterable forever in order | [cycleIterable] |
///
/// `dart:core` has no cycle helper: [List.filled] repeats one value
/// eagerly and [Iterable.generate] needs a count upfront, so neither
/// expresses repeat-this-sequence-forever (DART-SDK). [cycleIterable]
/// fills that gap by yielding the first pass while buffering and replaying
/// from the buffer afterwards, mirroring the Axiom `iterx` Cycle precedent
/// where empty input yields nothing (AXIOM-SISTER).
///
/// Pulls nothing until iterated and buffers one element at a time: the
/// first pass pulls the source on demand, later passes replay the buffer
/// without touching the source again. Realize infinite output only through
/// a bounded consumer such as the SDK `take`. Reach for this adapter when
/// the caller needs an unbounded repetition of a short sequence; reach for
/// the eager `lists` helpers when the input is already a [List] and the
/// caller wants a bounded repetition as a finished list. Never mutates
/// [sourceElements].
///
/// Returns an empty iterable when [sourceElements] is empty.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final cycled = cycleIterable(<int>[1, 2]).take(5);
/// print(cycled.toList()); // [1, 2, 1, 2, 1]
/// ```
Iterable<Element> cycleIterable<Element>(
  Iterable<Element> sourceElements,
) sync* {
  final List<Element> bufferedElements = <Element>[];
  for (final Element candidate in sourceElements) {
    bufferedElements.add(candidate);
    yield candidate;
  }
  if (bufferedElements.isEmpty) {
    return;
  }
  while (true) {
    for (final Element candidate in bufferedElements) {
      yield candidate;
    }
  }
}

/// Repeats one value forever.
///
/// | When you want to ...     | Reach for ...   |
/// | ------------------------ | --------------- |
/// | Repeat one value forever | [repeatElement] |
///
/// `dart:core` repeats one value only eagerly ([List.filled]) or counted
/// ([Iterable.generate] needs the count upfront), so neither expresses
/// repeat-forever for a lazy pipeline (DART-SDK). [repeatElement] fills
/// that gap with an unbounded lazy iterable, mirroring the Axiom `iterx`
/// Repeat precedent (AXIOM-SISTER).
///
/// Pulls nothing on its own: values materialize only as the caller pulls.
/// Realize infinite output only through a bounded consumer such as the SDK
/// `take`. Reach for this adapter when the pipeline needs an unbounded
/// constant stream; reach for the eager `List.filled` or the counted
/// `Iterable.generate` when the caller wants a finished collection of a
/// known size. The yielded values are the same object when [repeatedElement]
/// is an object: sharing is by design for an infinite constant stream.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final repeated = repeatElement(7).take(3);
/// print(repeated.toList()); // [7, 7, 7]
/// ```
Iterable<Element> repeatElement<Element>(Element repeatedElement) sync* {
  while (true) {
    yield repeatedElement;
  }
}

/// Collapses adjacent duplicates, keeping the first of each run.
///
/// | When you want to ...                         | Reach for ...         |
/// | -------------------------------------------- | --------------------- |
/// | Collapse adjacent duplicates, keeping order  | [deduplicateAdjacent] |
///
/// `dart:core` answers all-seen uniqueness with `toSet`, which is eager,
/// drops encounter order into set order, and collapses non-adjacent
/// duplicates too (DART-SDK). [deduplicateAdjacent] fills the gap with a
/// lazy adjacent-run collapse that keeps non-adjacent repeats, mirroring
/// the Axiom `iterx` DeduplicateSeq precedent of group-by semantics where
/// only consecutive equals collapse (AXIOM-SISTER).
///
/// Pulls nothing until iterated and pulls one element per yield: breaking
/// early stops pulling the source, and re-iterating re-runs from the
/// source. Reach for this adapter when the source is an [Iterable], the
/// pipeline is lazy, or only consecutive duplicates should collapse; reach
/// for the eager `toSet` or the `lists` helpers when the caller wants
/// all-seen uniqueness as a finished collection. Never mutates
/// [sourceElements].
///
/// Returns an empty iterable when [sourceElements] is empty.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final uniqueRuns = deduplicateAdjacent(<int>[1, 1, 2, 1]);
/// print(uniqueRuns.toList()); // [1, 2, 1]
/// ```
Iterable<Element> deduplicateAdjacent<Element>(
  Iterable<Element> sourceElements,
) sync* {
  bool started = false;
  Element? previousElement;
  for (final Element candidate in sourceElements) {
    if (started && candidate == previousElement) {
      continue;
    }
    started = true;
    previousElement = candidate;
    yield candidate;
  }
}
