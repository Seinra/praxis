/// A first-in first-out queue with absent-safe outcomes.
///
/// Reach for [FifoQueue] when the call order is "serve the longest waiting
/// first": [FifoQueue.enqueue] adds at the back, [FifoQueue.dequeue]
/// removes and returns the front with a presence flag, [FifoQueue.peek]
/// reads the front without removing it, and [FifoQueue.length],
/// [FifoQueue.isEmpty], plus [FifoQueue.isNotEmpty] report the depth. Reach
/// for `dart:collection` [Queue] directly when double-ended ops
/// (`addFirst`, `removeLast`) are the job — this holder owns only FIFO
/// discipline.
///
/// Which function?
///
/// | When you want to ...                    | Reach for ...       |
/// | --------------------------------------- | ------------------- |
/// | Hold values first-in first-out          | [FifoQueue]         |
/// | Build an empty queue                    | [FifoQueue.new]     |
/// | Add a value at the back                 | [FifoQueue.enqueue] |
/// | Remove and return the front value       | [FifoQueue.dequeue] |
/// | Read the front value without removing   | [FifoQueue.peek]    |
/// | Count waiting values                    | [FifoQueue.length]  |
/// | Ask whether the queue holds nothing     | [FifoQueue.isEmpty] |
/// | Ask whether the queue holds something   | [FifoQueue.isNotEmpty] |
///
/// An empty queue is a normal outcome here, never an error:
/// [FifoQueue.dequeue] and [FifoQueue.peek] answer
/// `(value: null, present: false)` instead of throwing, so callers branch
/// on `present` like every other Praxis OrNull. Never trust `value`
/// without checking `present` first: a queue may itself hold `null`
/// elements, so only the flag tells a held `null` from an absent one.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
library;

/// Holds values of type [Element] in first-in first-out order.
///
/// Enqueues land at the back and dequeues leave from the front, so the
/// longest-waiting value always serves first. The holder mutates only its
/// own backing list: constructors take no caller collections, so there is
/// no aliasing surface, and every answer is either a fresh record or a
/// stored value leaving the queue on [FifoQueue.dequeue].
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | values to serve longest-waiting-first | [FifoQueue] |
///
/// Stdlib gap (DART-SDK): `dart:collection` [Queue] (`ListQueue`) owns
/// double-ended ops, but `removeFirst` and `first` require a non-empty
/// queue and throw `IterableElementError.noElement()` on empty input —
/// absence travels as a throw, never as a value. [FifoQueue] fills that
/// gap with absent-safe [FifoQueue.dequeue] and [FifoQueue.peek] answering
/// the `(value, present)` OrNull record, plus grep-able
/// `enqueue`/`dequeue` names that say FIFO where `add`/`removeFirst` say
/// double-ended storage. The SDK name [Queue] stays untouched: this holder
/// is [FifoQueue] so imports never clash with `dart:collection`. Fidelity
/// note (AXIOM-SISTER): mirrors Axiom `queue` discipline (empty yields
/// the zero value plus `false`, head offset with amortized O(1) dequeue,
/// compaction that releases drained backing) without Go signatures —
/// records instead of `(T, bool)` pairs, total functions instead of
/// panics.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final FifoQueue<int> waitingScores = FifoQueue<int>();
/// waitingScores.enqueue(72);
/// waitingScores.enqueue(91);
/// final ({int? value, bool present}) frontScore = waitingScores.peek();
/// // frontScore.present == true
/// ```
final class FifoQueue<Element> {
  /// Creates an empty queue ready for [FifoQueue.enqueue].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | nothing yet to serve FIFO | [FifoQueue.new] |
  ///
  /// Stdlib gap (DART-SDK): the `dart:collection` [Queue] factory starts
  /// empty too, but carries double-ended semantics; [FifoQueue.new] starts
  /// an empty holder whose only order is front-to-back.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final FifoQueue<int> waitingScores = FifoQueue<int>();
  /// // waitingScores.isEmpty == true
  /// ```
  FifoQueue();

  final List<Element?> _storedValues = <Element?>[];
  int _headOffset = 0;

  /// Adds [heldValue] at the back of the queue.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a value to serve last | [FifoQueue.enqueue] |
  ///
  /// Stdlib gap (DART-SDK): `dart:collection` `Queue.add` appends too, but
  /// says nothing about FIFO order; [enqueue] names the back-of-line
  /// contract the reader can grep. Runs in amortized O(1).
  ///
  /// Never mutates caller inputs: [heldValue] moves into the private
  /// backing, and no caller collection is read or written.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final FifoQueue<String> waitingWords = FifoQueue<String>();
  /// waitingWords.enqueue('fig');
  /// // waitingWords.length == 1
  /// ```
  void enqueue(Element heldValue) {
    _storedValues.add(heldValue);
  }

  /// Removes and returns the front value with a presence flag.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the front value to serve next | [FifoQueue.dequeue] |
  ///
  /// Stdlib gap (DART-SDK): `dart:collection` `Queue.removeFirst` throws
  /// `IterableElementError.noElement()` on empty input; [dequeue] answers
  /// `(value: null, present: false)` instead, so empty input stays a
  /// normal outcome. Runs in amortized O(1): serving advances a head
  /// offset instead of shifting, and the consumed prefix compacts per
  /// [_compactStoredValues].
  ///
  /// An empty queue yields `(value: null, present: false)`: never an
  /// error, never a throw. The vacated slot is cleared so a served value
  /// stays collectable.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final FifoQueue<String> waitingWords = FifoQueue<String>();
  /// waitingWords.enqueue('fig');
  /// waitingWords.enqueue('pear');
  /// final ({String? value, bool present}) frontWord = waitingWords.dequeue();
  /// // frontWord.value == 'fig'
  /// ```
  ({Element? value, bool present}) dequeue() {
    if (_headOffset >= _storedValues.length) {
      return (value: null, present: false);
    }
    final Element? frontValue = _storedValues[_headOffset];
    _storedValues[_headOffset] = null;
    _headOffset += 1;
    _compactStoredValues();
    // `as Element` (never `!`): preserves a served `null` when [Element]
    // itself is nullable instead of throwing on it.
    return (value: frontValue as Element, present: true);
  }

  /// Reads the front value with a presence flag, leaving the queue untouched.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the front value to read without serving | [FifoQueue.peek] |
  ///
  /// Stdlib gap (DART-SDK): `dart:collection` `Queue.first` throws
  /// `IterableElementError.noElement()` on empty input; [peek] answers
  /// `(value: null, present: false)` instead, so probing an empty queue
  /// stays a normal outcome.
  ///
  /// An empty queue yields `(value: null, present: false)`: never an
  /// error, never a throw. Never mutates the queue.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final FifoQueue<String> waitingWords = FifoQueue<String>();
  /// waitingWords.enqueue('fig');
  /// final ({String? value, bool present}) frontWord = waitingWords.peek();
  /// // frontWord.value == 'fig'
  /// ```
  ({Element? value, bool present}) peek() {
    if (_headOffset >= _storedValues.length) {
      return (value: null, present: false);
    }
    // Same present-`null` spelling as [FifoQueue.dequeue].
    return (value: _storedValues[_headOffset] as Element, present: true);
  }

  /// Counts the values currently waiting.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the line depth to read | [FifoQueue.length] |
  ///
  /// Stdlib gap (DART-SDK): `dart:collection` `Queue.length` counts
  /// double-ended storage; [length] counts the FIFO line, mirroring the
  /// SDK noun so callers keep one vocabulary.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final FifoQueue<int> waitingScores = FifoQueue<int>();
  /// waitingScores.enqueue(72);
  /// waitingScores.enqueue(91);
  /// // waitingScores.length == 2
  /// ```
  int get length => _storedValues.length - _headOffset;

  /// Whether the queue holds no values.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the line to test for nothing waiting | [FifoQueue.isEmpty] |
  ///
  /// Stdlib gap (DART-SDK): `dart:collection` `Queue.isEmpty` tests
  /// double-ended storage; [isEmpty] tests the FIFO line, mirroring the
  /// SDK predicate so callers keep one vocabulary.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final FifoQueue<int> waitingScores = FifoQueue<int>();
  /// // waitingScores.isEmpty == true
  /// ```
  bool get isEmpty => _headOffset >= _storedValues.length;

  /// Whether the queue holds at least one value.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the line to test for something waiting | [FifoQueue.isNotEmpty] |
  ///
  /// Stdlib gap (DART-SDK): `dart:collection` `Queue.isNotEmpty` tests
  /// double-ended storage; [isNotEmpty] tests the FIFO line, mirroring the
  /// SDK predicate so callers keep one vocabulary.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final FifoQueue<int> waitingScores = FifoQueue<int>();
  /// // waitingScores.isNotEmpty == false
  /// ```
  bool get isNotEmpty => _headOffset < _storedValues.length;

  /// Reclaims the consumed prefix per the Axiom `queue` policy.
  ///
  /// Releases the backing when drained, and slides the live suffix to the
  /// front once the prefix is both long ([_compactThreshold]) and at least
  /// half the backing. Tests pin order, never timing.
  void _compactStoredValues() {
    if (_headOffset >= _storedValues.length) {
      _storedValues.clear();
      _headOffset = 0;
      return;
    }
    if (_headOffset >= _compactThreshold &&
        _headOffset * 2 >= _storedValues.length) {
      final List<Element?> liveValues = _storedValues.sublist(_headOffset);
      _storedValues
        ..clear()
        ..addAll(liveValues);
      _headOffset = 0;
    }
  }
}

/// The consumed-prefix length that, together with holding at least half the
/// backing, triggers a slide of the live suffix. The 64-entry floor is a
/// heuristic: slides stay rare on small queues while order stays pinned by
/// tests, never timing.
const int _compactThreshold = 64;
