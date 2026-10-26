/// Per-key in-flight sharing for concurrent async calls.
///
/// Reach for this when concurrent callers stampede one backend behind the
/// same key: [SingleflightGroup] holds one in-flight [Future] per key,
/// [SingleflightGroup.call] shares it with late joiners, and completion
/// forgets the key so the next sequential call re-executes. Errors ride the
/// shared future to every sharer; callers retry explicitly with a fresh
/// [SingleflightGroup.call].
///
/// Which function?
///
/// | When you want to ...                            | Reach for ...          |
/// | ----------------------------------------------- | ---------------------- |
/// | Hold one key space with shared in-flight calls  | [SingleflightGroup]    |
/// | Share one execution across same-key callers     | [SingleflightGroup.call] |
///
/// Out of scope by design: caches with TTL (that lifecycle belongs to a
/// future `repo` slice, never here), cross-isolate sharing (app concern,
/// out of scope), and waiting queues with timeouts (no `Timer` deadlines
/// here). This package dedupes concurrency; it never stores outcomes.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
library;

import 'dart:async';

/// Holds one in-flight async call per key so concurrent same-key callers
/// share a single execution.
///
/// The group is caller-owned mutable state: [call] records the leader
/// future under its key, hands the identical future to late joiners, and
/// forgets the key when the future settles — success or failure — so the
/// map never grows past the live keys and sequential calls re-execute.
/// The group never mutates caller inputs; every sharer receives the
/// identical future instance, so a shared mutable outcome stays read-only
/// for all sharers.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | one key space with shared in-flight calls | [SingleflightGroup] |
///
/// Stdlib gap (DART-SDK): [Future.wait] (`lib/async/future.dart`) joins an
/// already-known set of futures — every future runs whether or not keys
/// overlap — so it owns no per-key dedupe. [Stream.fromFutures]
/// (`lib/async/stream.dart`) shares one subscription across listeners, not
/// one execution across callers. No SDK combinator memoizes an in-flight
/// future by key, so [SingleflightGroup] owns that shape as a hand-rolled
/// live-key table over an SDK map, never a reimplementation.
/// Fidelity note (AXIOM-SISTER): mirrors Axiom's `singleflight` discipline
/// (share in-flight per key, forget on settle, propagate errors to all
/// sharers) without Go signatures: futures instead of channels, an
/// identity-checked forget instead of a mutex-guarded close, no `Stats`
/// counters and no manual `Forget` — completion forgets, and anything
/// cache-shaped stays YAGNI-killed for the future `repo` slice.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final SingleflightGroup<String, int> flightGroup =
///     SingleflightGroup<String, int>();
/// final int sharedValue = await flightGroup.call('user:7', () async => 42);
/// // sharedValue == 42
/// ```
final class SingleflightGroup<RequestKey extends Object, OutcomeValue> {
  /// Creates a group holding no in-flight calls.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an empty key space to share in-flight calls | [SingleflightGroup.new] |
  ///
  /// Stdlib gap (DART-SDK): no SDK constructor names a per-key in-flight
  /// table, so [SingleflightGroup.new] names the empty live-key map that
  /// [SingleflightGroup.call] fills and forgets. A nullable-key guard is
  /// YAGNI-killed here with a reason: sound null safety already rejects
  /// `null` through the [RequestKey extends Object] bound, so the compiler
  /// enforces the contract before any call runs.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final SingleflightGroup<String, int> flightGroup =
  ///     SingleflightGroup<String, int>();
  /// // flightGroup is ready: no in-flight calls yet
  /// ```
  SingleflightGroup();

  final Map<RequestKey, Future<OutcomeValue>> _inflightCalls =
      <RequestKey, Future<OutcomeValue>>{};

  /// Shares one execution across concurrent callers holding [requestKey].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a key plus work to run once while shared | [SingleflightGroup.call] |
  ///
  /// Stdlib gap (DART-SDK): see [SingleflightGroup] for the missing shape —
  /// no SDK combinator memoizes an in-flight future by key. [call] owns the
  /// operation half: the first caller runs [action] while concurrent
  /// same-key callers receive the identical future instance.
  ///
  /// The check-then-store runs synchronously with no `await` between, so
  /// late joiners attach atomically on the single-threaded event loop.
  /// Settlement forgets the key on success and on failure through an
  /// identity check, so a settled entry never blocks the next sequential
  /// call and never evicts its replacement. Failures propagate through
  /// the shared future to every sharer with the identical error instance;
  /// callers retry explicitly with a fresh [call] because sequential calls
  /// re-execute by design (no caching). Synchronous throws inside [action]
  /// become error futures for the caller only: nothing was stored, so
  /// nothing was shared and the key stays free.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final SingleflightGroup<String, int> flightGroup =
  ///     SingleflightGroup<String, int>();
  /// final int sharedValue = await flightGroup.call('user:7', () async => 42);
  /// // sharedValue == 42
  /// ```
  Future<OutcomeValue> call(
    RequestKey requestKey,
    Future<OutcomeValue> Function() action,
  ) {
    final Future<OutcomeValue>? sharedFuture = _inflightCalls[requestKey];
    if (sharedFuture != null) {
      return sharedFuture;
    }
    late final Future<OutcomeValue> leaderFuture;
    try {
      leaderFuture = action();
    } catch (syncFailure, syncStackTrace) {
      return Future<OutcomeValue>.error(syncFailure, syncStackTrace);
    }
    _inflightCalls[requestKey] = leaderFuture;
    unawaited(
      leaderFuture.then<void>(
        (OutcomeValue settledValue) =>
            _forgetIfCurrent(requestKey, leaderFuture),
        onError: (Object sharedFailure, StackTrace sharedStackTrace) =>
            _forgetIfCurrent(requestKey, leaderFuture),
      ),
    );
    return leaderFuture;
  }

  /// Forgets [leaderFuture] when it still holds [requestKey].
  ///
  /// Keeps settlement from evicting a replacement: when a newer call
  /// already stored a fresh future under [requestKey], the identity check
  /// leaves it alone instead of clearing live work.
  void _forgetIfCurrent(
    RequestKey requestKey,
    Future<OutcomeValue> leaderFuture,
  ) {
    if (identical(_inflightCalls[requestKey], leaderFuture)) {
      _inflightCalls.remove(requestKey);
    }
  }
}
