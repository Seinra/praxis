/// A last-in first-out stack with absent-safe outcomes.
///
/// Reach for [Stack] when the call order is "undo the most recent first":
/// [Stack.push] adds on top, [Stack.pop] removes and returns the top with
/// a presence flag, [Stack.peek] reads the top without removing it, and
/// [Stack.length], [Stack.isEmpty], plus [Stack.isNotEmpty] report the
/// depth. Reach for the [List] directly when indexed access, sorting, or
/// searching is the job — a stack owns only top-of-pile discipline.
///
/// Which function?
///
/// | When you want to ...                  | Reach for ... |
/// | ------------------------------------- | ------------- |
/// | Hold values last-in first-out         | [Stack]       |
/// | Build an empty stack                  | [Stack.new]   |
/// | Add a value on top                    | [Stack.push]  |
/// | Remove and return the top value       | [Stack.pop]   |
/// | Read the top value without removing   | [Stack.peek]  |
/// | Count held values                     | [Stack.length] |
/// | Ask whether the stack holds nothing   | [Stack.isEmpty] |
/// | Ask whether the stack holds something | [Stack.isNotEmpty] |
///
/// An empty stack is a normal outcome here, never an error: [Stack.pop]
/// and [Stack.peek] answer `(value: null, present: false)` instead of
/// throwing, so callers branch on `present` like every other Praxis OrNull.
/// Never trust `value` without checking `present` first: a stack may itself
/// hold `null` elements, so only the flag tells a held `null` from an
/// absent one.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
library;

/// Holds values of type [Element] in last-in first-out order.
///
/// Pushes land on top and pops leave from the top, so the most recently
/// pushed value always serves first. The holder mutates only its own
/// backing list: constructors take no caller collections, so there is no
/// aliasing surface, and every answer is either a fresh record or a stored
/// value leaving the stack on [Stack.pop].
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | values to undo most-recent-first | [Stack] |
///
/// Stdlib gap (DART-SDK): [List.add], [List.removeLast], and [List.last]
/// own indexed stack ops, but [List.removeLast] requires a non-empty list
/// and [List.last] throws a [StateError] on empty input — absence travels
/// as a throw, never as a value. [Stack] fills that gap with absent-safe
/// [Stack.pop] and [Stack.peek] answering the `(value, present)` OrNull
/// record, plus grep-able `push`/`pop`/`peek` names that say LIFO where
/// `add`/`removeLast`/`last` say indexed list. Fidelity note
/// (AXIOM-SISTER): mirrors Axiom `stack` discipline (empty yields the
/// zero value plus `false`, ready without construction arguments,
/// amortized O(1) on the tail) without Go signatures — records instead of
/// `(T, bool)` pairs, [ArgumentError]-free total functions instead of
/// panics.
///
/// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final Stack<int> heldScores = Stack<int>();
/// heldScores.push(72);
/// heldScores.push(91);
/// final ({int? value, bool present}) topScore = heldScores.peek();
/// // topScore.present == true
/// ```
final class Stack<Element> {
  /// Creates an empty stack ready for [Stack.push].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | nothing yet to hold LIFO | [Stack.new] |
  ///
  /// Stdlib gap (DART-SDK): a growable [List] literal starts empty too,
  /// but carries indexed semantics; [Stack.new] starts an empty holder
  /// whose only order is top-of-pile.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Stack<int> heldScores = Stack<int>();
  /// // heldScores.isEmpty == true
  /// ```
  Stack();

  final List<Element> _storedValues = <Element>[];

  /// Adds [heldValue] on top of the stack.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a value to hold most-recent-first | [Stack.push] |
  ///
  /// Stdlib gap (DART-SDK): [List.add] appends too, but says nothing about
  /// LIFO order; [push] names the top-of-pile contract the reader can
  /// grep. Runs in amortized O(1) on the tail of the backing list.
  ///
  /// Never mutates caller inputs: [heldValue] moves into the private
  /// backing, and no caller collection is read or written.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Stack<String> heldWords = Stack<String>();
  /// heldWords.push('fig');
  /// // heldWords.length == 1
  /// ```
  void push(Element heldValue) {
    _storedValues.add(heldValue);
  }

  /// Removes and returns the top value with a presence flag.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the top value to take off the pile | [Stack.pop] |
  ///
  /// Stdlib gap (DART-SDK): [List.removeLast] throws a [StateError] on
  /// empty input; [pop] answers `(value: null, present: false)` instead,
  /// so empty input stays a normal outcome. Runs in amortized O(1) on the
  /// tail of the backing list.
  ///
  /// An empty stack yields `(value: null, present: false)`: never an
  /// error, never a throw. Draining releases the backing for reuse; use a
  /// fresh [Stack] to release memory.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Stack<String> heldWords = Stack<String>();
  /// heldWords.push('fig');
  /// heldWords.push('pear');
  /// final ({String? value, bool present}) topWord = heldWords.pop();
  /// // topWord.present == true
  /// ```
  ({Element? value, bool present}) pop() {
    if (_storedValues.isEmpty) {
      return (value: null, present: false);
    }
    return (value: _storedValues.removeLast(), present: true);
  }

  /// Reads the top value with a presence flag, leaving the stack untouched.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the top value to read without taking | [Stack.peek] |
  ///
  /// Stdlib gap (DART-SDK): [List.last] throws a [StateError] on empty
  /// input; [peek] answers `(value: null, present: false)` instead, so
  /// probing an empty stack stays a normal outcome.
  ///
  /// An empty stack yields `(value: null, present: false)`: never an
  /// error, never a throw. Never mutates the stack.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Stack<String> heldWords = Stack<String>();
  /// heldWords.push('fig');
  /// final ({String? value, bool present}) topWord = heldWords.peek();
  /// // topWord.value == 'fig'
  /// ```
  ({Element? value, bool present}) peek() {
    if (_storedValues.isEmpty) {
      return (value: null, present: false);
    }
    return (value: _storedValues.last, present: true);
  }

  /// Counts the values currently held.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the pile depth to read | [Stack.length] |
  ///
  /// Stdlib gap (DART-SDK): [List.length] counts indexed storage; [length]
  /// counts the LIFO pile, mirroring the SDK noun so callers keep one
  /// vocabulary.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Stack<int> heldScores = Stack<int>();
  /// heldScores.push(72);
  /// heldScores.push(91);
  /// // heldScores.length == 2
  /// ```
  int get length => _storedValues.length;

  /// Whether the stack holds no values.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the pile to test for nothing held | [Stack.isEmpty] |
  ///
  /// Stdlib gap (DART-SDK): [List.isEmpty] tests indexed storage; [isEmpty]
  /// tests the LIFO pile, mirroring the SDK predicate so callers keep one
  /// vocabulary.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Stack<int> heldScores = Stack<int>();
  /// // heldScores.isEmpty == true
  /// ```
  bool get isEmpty => _storedValues.isEmpty;

  /// Whether the stack holds at least one value.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the pile to test for something held | [Stack.isNotEmpty] |
  ///
  /// Stdlib gap (DART-SDK): [List.isNotEmpty] tests indexed storage;
  /// [isNotEmpty] tests the LIFO pile, mirroring the SDK predicate so
  /// callers keep one vocabulary.
  ///
  /// Available since Praxis `0.1.0-dev`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Stack<int> heldScores = Stack<int>();
  /// // heldScores.isNotEmpty == false
  /// ```
  bool get isNotEmpty => _storedValues.isNotEmpty;
}
