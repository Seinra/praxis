/// Single eager background computation with a join-later handle.
///
/// Reach for this when one computation should start now and be joined
/// later: [Task.spawn] starts the computation eagerly and hands back a
/// handle, [Task.join] reports its single shared outcome as a typed
/// [Result]. Every join — from N concurrent joiners, before or after
/// completion — receives the identical outcome, so one background
/// computation fans out without re-running. Compute failures become
/// [Result.failure] values at the spawn boundary instead of throws across
/// the join, so failures travel as data the caller handles without
/// `try`/`catch`.
///
/// Which function?
///
/// | When you want to ... | Reach for |
/// | --- | --- |
/// | Hold one background computation with its shared outcome | [Task] |
/// | Start one computation now, join it later | [Task.spawn] |
/// | Join the computation and read its shared outcome | [Task.join] |
///
/// Out of scope by design: `Then`/`Map` combinators (that shaping belongs
/// to [Result.mapValue] and [Result.andThen] over the joined outcome, never
/// here), timeouts and cancellation scopes (that contract belongs to
/// `flow`'s `FlowScope`, never here), task groups (that fan-out belongs to
/// `flow`, never here), and lazy cold-start handles (a deferred start is a
/// plain `Future` closure by SDK construction — naming it would add a
/// delegate-only wrapper). This package runs one computation once and
/// shares its outcome; it never dedupes keys (reach for `singleflight`)
/// and never caps concurrency (reach for `flow`).
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
library;

import 'package:praxis/src/result.dart';

/// One eager background computation joined later through [Task.join].
///
/// [Task.spawn] starts the computation before returning, so it runs even
/// when [Task.join] never comes. Every join reports the same outcome:
/// success as [Result.ok], compute failure as [Result.failure], so the join
/// never throws for a compute failure. [Result] is immutable, so sharing
/// the identical instance across joiners stays read-only for all of them.
/// The handle never mutates caller inputs: the computation takes no
/// arguments, and each handle owns its private outcome future.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | one background computation with its shared outcome | [Task] |
///
/// Stdlib gap (DART-SDK): [Future] already joins later and shares one
/// outcome across listeners, but carries failures as thrown objects outside
/// the type — the same sum-type gap `result` names over `dart:core`, which
/// ships no success-or-failure shape. [Task] owns the eager-run-once plus
/// [Result]-typed-join pair, so failures travel inside the type. Fidelity
/// note (AXIOM-SISTER): mirrors Axiom's `task` lifecycle discipline (every
/// spawned computation runs once, every join shares one outcome, every
/// failure becomes data) without Go signatures: futures instead of
/// goroutines, no context parameter because Dart futures are not
/// preemptible and cooperative cancel belongs to `flow`'s `FlowScope`.
///
/// Every handle comes from [Task.spawn]: the constructor always stores the
/// outcome future, so there is no zero-handle path. A `null` compute guard
/// is YAGNI-killed here with a reason: sound null safety makes it
/// unrepresentable, since the computation is a non-nullable function the
/// compiler already rejects as `null`.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final Task<int> backgroundTask = Task<int>.spawn(() async => 42);
/// final Result<int> outcome = await backgroundTask.join();
/// // outcome.getOrElse(0) == 42
/// ```
final class Task<OutcomeValue> {
  /// Starts [compute] now and holds its future outcome for [Task.join].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | work to start now and join later | [Task.spawn] |
  ///
  /// Stdlib gap (DART-SDK): calling an `async` function already starts
  /// eager work, but leaves failures as throws and sharing as convention;
  /// [Task.spawn] pairs the eager start with the [Result]-typed join, so
  /// the contract reads at the spawn site. Fidelity note (AXIOM-SISTER):
  /// the eager half of Axiom's `Spawn` without the context half — Dart has
  /// no `context.Context`, so there is nothing to pre-cancel and no scope
  /// to thread.
  ///
  /// Runs [compute] exactly once before returning: the computation starts
  /// even when [Task.join] never comes. A synchronous throw inside
  /// [compute] becomes a [Result.failure] instead of escaping the
  /// constructor, matching the async-error path.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Task<int> backgroundTask = Task<int>.spawn(() async => 42);
  /// // the computation is already running: no join yet
  /// ```
  Task.spawn(Future<OutcomeValue> Function() compute)
    : _outcomeFuture = _launch(compute);

  final Future<Result<OutcomeValue>> _outcomeFuture;

  /// Joins the spawned computation and reports its shared outcome.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a spawned computation to join and read | [Task.join] |
  ///
  /// Stdlib gap (DART-SDK): `await` on a [Future] rethrows the compute
  /// failure at every joiner, so each join site repeats the `try`/`catch`;
  /// [join] reports the failure once as a [Result.failure] value shared by
  /// every joiner. Fidelity note (AXIOM-SISTER): the shared-outcome half
  /// of Axiom's `Await` — every join before or after completion reports
  /// the identical [Result], except the run always happens eagerly with
  /// nothing to deduplicate.
  ///
  /// Success arrives as [Result.ok] holding the value; compute failures —
  /// async errors and synchronous throws alike — arrive as
  /// [Result.failure]. [Exception] failures keep their instance, so
  /// identity pins hold; non-`Exception` throwables arrive wrapped with
  /// their string form, because [Result] names [Exception] as its only
  /// failure value by design. Never throws for a compute failure.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final Task<int> backgroundTask = Task<int>.spawn(() async => 42);
  /// final Result<int> firstOutcome = await backgroundTask.join();
  /// final Result<int> secondOutcome = await backgroundTask.join();
  /// // identical(firstOutcome, secondOutcome) == true
  /// ```
  Future<Result<OutcomeValue>> join() => _outcomeFuture;

  /// Runs [compute] once and lifts its settlement into one shared outcome.
  ///
  /// Returns a future that completes with [Result.ok] on success and with
  /// [Result.failure] on any compute failure, so [join] never throws for
  /// compute failures. Synchronous throws count as compute failures on the
  /// same path as async errors.
  static Future<Result<OutcomeValue>> _launch<OutcomeValue>(
    Future<OutcomeValue> Function() compute,
  ) {
    try {
      return compute().then<Result<OutcomeValue>>(
        Result<OutcomeValue>.ok,
        onError: (Object taskFailure) =>
            Result<OutcomeValue>.failure(_asException(taskFailure)),
      );
    } catch (syncFailure) {
      return Future<Result<OutcomeValue>>.value(
        Result<OutcomeValue>.failure(_asException(syncFailure)),
      );
    }
  }
}

/// Coerces a compute failure into the [Exception] that [Result.failure] holds.
///
/// Passes [Exception] instances through untouched so identity pins hold;
/// wraps anything else with its string form because [Result] names
/// [Exception] as its only failure value by design. Mirrors the coercion
/// beside `flow`'s bounded runners, kept private here so `task` stays
/// decoupled from `flow` beyond the shared `result` vocabulary.
Exception _asException(Object taskFailure) {
  if (taskFailure is Exception) {
    return taskFailure;
  }
  return Exception('task compute failed with a non-Exception: $taskFailure');
}
