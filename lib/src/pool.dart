/// Bounded sync object-reuse helpers over idle lists.
///
/// Reach for these when the SDK names the storage but not the lifecycle:
/// [Pool] holds recyclables with a factory plus an optional reset plus a
/// bounded idle cap, [Pool.acquire] borrows a value creating when idle is
/// empty, [Pool.release] returns a value for reuse, and [Pool.use] borrows
/// for one call with guaranteed release. Every helper is sync only: waiting
/// acquirers, timeouts, and cross-isolate sharing stay out of scope.
///
/// Which function?
///
/// | When you want to ...                          | Reach for ...   |
/// | --------------------------------------------- | --------------- |
/// | Hold recyclables with factory plus reset plus cap | [Pool]      |
/// | Borrow a value, creating when idle is empty   | [Pool.acquire] |
/// | Return a value for reuse                      | [Pool.release] |
/// | Borrow for one call with guaranteed release   | [Pool.use]     |
/// | Ask how many idle values wait                 | [Pool.idleCount] |
/// | Read the idle cap                             | [Pool.maxSize] |
///
/// Out of scope by design: async-aware pooling with waiting acquirers or
/// timeouts (that design belongs to a future `flow`-crossing slice, never
/// here). This package reuses values already created; it never manages
/// concurrency.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
library;

/// A bounded sync pool of reusable values of type [Pooled].
///
/// Holds at most [maxSize] idle values: [acquire] reuses the most recently
/// released value or builds a fresh one with the factory, [release] resets
/// the borrowed value and stores it when room remains or discards it when
/// idle is full, and [use] borrows for one call with guaranteed release.
/// The pool itself is the managed state; it never mutates caller inputs
/// beyond resetting the pooled value on [release].
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | objects to reuse instead of rebuild | [Pool] |
///
/// Stdlib gap (DART-SDK): `dart:core` and `dart:collection` name storage
/// ([List], [Queue]) but no reuse lifecycle — no factory for empty idle,
/// no reset hook, no idle cap with discard. [Pool] owns that lifecycle as
/// a hand-rolled free list over an SDK list, never a reimplementation.
/// Fidelity note (AXIOM-SISTER): mirrors Axiom's `pool` reuse discipline
/// (bounded idle set, factory plus reset plus discard, borrow semantics)
/// without Go signatures: explicit factory required (no zero-value pool),
/// explicit [maxSize] cap (no GC-drop), [ArgumentError] on double-release.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
///   create: StringBuffer.new,
///   reset: (StringBuffer borrowedValue) => borrowedValue.clear(),
///   maxSize: 2,
/// );
/// // bufferPool.idleCount == 0
/// ```
final class Pool<Pooled> {
  /// Creates a pool that builds fresh values with [_create].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a factory plus a cap to hold recyclables | [Pool.new] |
  ///
  /// Stdlib gap (DART-SDK): no SDK constructor names a bounded reuse set,
  /// so [Pool.new] names the factory plus the idle cap together. A `nil`
  /// factory guard is YAGNI-killed here with a reason: sound null safety
  /// makes it unrepresentable, since [_create] is a non-nullable function
  /// the compiler already rejects as `null`.
  ///
  /// Throws an [ArgumentError] when [maxSize] is zero or less: unlike
  /// Axiom's GC-dropped pool, a platform-neutral core names the idle cap
  /// explicitly and rejects a cap that can never hold. [_reset] runs on
  /// [release] before idle storage; when omitted, released values store
  /// as-is.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
  ///   create: StringBuffer.new,
  ///   maxSize: 2,
  /// );
  /// // bufferPool.maxSize == 2
  /// ```
  Pool({required this._create, this._reset, required int maxSize})
    : maxSize = maxSize {
    if (maxSize <= 0) {
      throw ArgumentError.value(
        maxSize,
        'maxSize',
        'Must be greater than zero.',
      );
    }
  }

  final Pooled Function() _create;
  final void Function(Pooled borrowedValue)? _reset;

  /// The idle cap: at most this many values wait in [idleCount].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the idle cap to read | [Pool.maxSize] |
  ///
  /// Stdlib gap (DART-SDK): [List] and [Queue] grow without a reuse cap,
  /// so [maxSize] names the bound that keeps idle storage bounded.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
  ///   create: StringBuffer.new,
  ///   maxSize: 2,
  /// );
  /// // bufferPool.maxSize == 2
  /// ```
  final int maxSize;

  final List<Pooled> _idleValues = <Pooled>[];

  /// How many values currently wait idle for [acquire].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | the idle depth to assert in tests | [Pool.idleCount] |
  ///
  /// Stdlib gap (DART-SDK): storage lengths report allocation, not reuse
  /// readiness; [idleCount] reports how many reset values [acquire] can
  /// hand out without calling the factory.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
  ///   create: StringBuffer.new,
  ///   maxSize: 2,
  /// );
  /// // bufferPool.idleCount == 0
  /// ```
  int get idleCount => _idleValues.length;

  /// Borrows a value, reusing idle when available or creating fresh.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a value to borrow, creating when idle is empty | [Pool.acquire] |
  ///
  /// Stdlib gap (DART-SDK): [List.removeLast] and [Queue.removeFirst]
  /// pop storage, but neither names creating through a factory when empty;
  /// [acquire] owns that empty-idle-creates rule. Fidelity note
  /// (AXIOM-SISTER): mirrors Axiom's borrow validity — a recycled or
  /// fresh usable value — over an explicit idle list instead of a
  /// GC-dropped runtime pool.
  ///
  /// Empty and exhausted idle both create through the factory: the pool
  /// never throws for lack of idle and never waits. Factory throws
  /// propagate with nothing stored.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
  ///   create: StringBuffer.new,
  ///   maxSize: 2,
  /// );
  /// final StringBuffer borrowedBuffer = bufferPool.acquire();
  /// borrowedBuffer.write('hi');
  /// // borrowedBuffer.toString() == 'hi'
  /// ```
  Pooled acquire() {
    if (_idleValues.isNotEmpty) {
      return _idleValues.removeLast();
    }
    return _create();
  }

  /// Returns [borrowedValue] for reuse after an optional reset.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a borrowed value to return for reuse | [Pool.release] |
  ///
  /// Stdlib gap (DART-SDK): [List.add] and [Queue.add] store without a
  /// lifecycle — no reset, no cap, no duplicate guard. [release] owns the
  /// reuse lifecycle: reset, then store when room remains, else discard.
  /// Fidelity note (AXIOM-SISTER): mirrors Axiom's return-for-reuse with
  /// an explicit bounded discard instead of a runtime GC drop.
  ///
  /// Double-release throws an [ArgumentError] while the value stays idle:
  /// releasing the same identity twice without an intervening [acquire]
  /// would hand one mutable value to two borrowers, so the second release
  /// fails instead of aliasing. Values discarded when idle was full leave
  /// no idle entry, so the guard does not track them. The caller drops its
  /// reference after [release]: re-releasing a stale reference after an
  /// intervening [acquire] would alias, so callers never retain the value.
  /// Reset errors propagate and discard the value: a value whose reset
  /// throws is never stored. Full idle discards the value: [idleCount]
  /// stays at [maxSize] instead of growing unbounded.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
  ///   create: StringBuffer.new,
  ///   reset: (StringBuffer borrowedValue) => borrowedValue.clear(),
  ///   maxSize: 2,
  /// );
  /// final StringBuffer borrowedBuffer = bufferPool.acquire();
  /// borrowedBuffer.write('hi');
  /// bufferPool.release(borrowedBuffer);
  /// // bufferPool.idleCount == 1
  /// ```
  void release(Pooled borrowedValue) {
    if (_idleValues.any(
      (Pooled idleValue) => identical(idleValue, borrowedValue),
    )) {
      throw ArgumentError.value(
        borrowedValue,
        'borrowedValue',
        'Already released: same identity is idle.',
      );
    }
    final void Function(Pooled borrowedValue)? activeReset = _reset;
    if (activeReset != null) {
      activeReset(borrowedValue);
    }
    if (_idleValues.length >= maxSize) {
      return;
    }
    _idleValues.add(borrowedValue);
  }

  /// Borrows a value for [action] with guaranteed release.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a value to use temporarily without manual release | [Pool.use] |
  ///
  /// Stdlib gap (DART-SDK): no SDK helper pairs acquire with
  /// `finally`-release over a reuse lifecycle; [use] owns that scoped
  /// borrow so callers cannot leak the borrowed value on the happy path.
  ///
  /// Acquires one value, runs [action], and releases in a `finally` block,
  /// returning the action result. Action throws still release when reset
  /// succeeds, then propagate the action error; reset throws discard the
  /// value and propagate the reset error, and when both throw the reset
  /// error propagates. Never mutates caller inputs:
  /// only the pooled value passes through [action] and [release].
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
  ///   create: StringBuffer.new,
  ///   reset: (StringBuffer borrowedValue) => borrowedValue.clear(),
  ///   maxSize: 2,
  /// );
  /// final String greeting = bufferPool.use<String>(
  ///   (StringBuffer borrowedValue) {
  ///     borrowedValue.write('hi');
  ///     return borrowedValue.toString();
  ///   },
  /// );
  /// // greeting == 'hi'
  /// ```
  Outcome use<Outcome>(Outcome Function(Pooled borrowedValue) action) {
    final Pooled borrowedValue = acquire();
    try {
      return action(borrowedValue);
    } finally {
      release(borrowedValue);
    }
  }
}
