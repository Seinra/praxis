/// Bounded concurrency combinators over [Future] and [Stream].
///
/// Reach for these when the SDK names no bounded shape: [flowMap] fans out
/// with a bounded in-flight cap and reports results in input order,
/// [flowFirst] races for the first success while ignoring failures, and
/// [flowCollect] streams one typed [Result] per input in completion order.
/// Every call shares one caller-owned [FlowScope] for cooperative
/// cancellation: the combinator stops starting new work on its terminal
/// event, the caller stops it from the outside with [FlowScope.stop], and
/// in-flight futures always run to completion because Dart futures are not
/// preemptible.
///
/// | When you want to ... | Reach for |
/// | --- | --- |
/// | transform every input with a cap, keeping input order | [flowMap] |
/// | the first success, ignoring failures until all fail | [flowFirst] |
/// | one outcome per input as each finishes | [flowCollect] |
/// | a stop signal shared by one call | [FlowScope] |
///
/// YAGNI-killed SDK surface (DART-SDK): [Future.wait]
/// (`lib/async/future.dart:517`) joins an unbounded set — it subscribes every
/// future eagerly and keeps siblings running after the first error, so it
/// owns neither a cap nor cancellation. [Stream.fromFutures]
/// (`lib/async/stream.dart:297`) subscribes all futures immediately (the
/// source names them "already running"), so it owns neither a cap nor input
/// order. [Future.any] (`lib/async/future.dart:656`) settles on the first
/// value OR error, so it owns no first-success race. [Future.timeout]
/// (`lib/async/future_impl.dart:1032`) is a per-future `Timer` deadline with
/// no shared scope, so it owns no cooperative cancel contract.
/// `CancelableOperation` lives in `package:async`, which stays an external
/// reference and never a dependency. Anything the SDK owns is never wrapped.
library;

import 'dart:async';

import 'package:praxis/src/result.dart';

/// A caller-owned cooperative stop signal shared by one `flow` call.
///
/// Give [flowMap], [flowFirst], or [flowCollect] a scope to keep an outside
/// handle on the run: call [stop] — for example on dispose — and the
/// combinator stops starting new work while started tasks run to completion.
/// Each combinator also stops its scope on its own terminal event: [flowMap]
/// on the first task failure, [flowFirst] on the first success.
/// [flowCollect] never stops it because failures ride as [Result] values
/// beside successes. There is exactly one stop path — a single [isStopped]
/// flag — whether the stop comes from inside the combinator or from the
/// caller outside.
///
/// When no explicit scope is passed, each call creates one internal scope
/// that stays private to that call.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a stop signal shared by one call | [FlowScope] |
///
/// Stdlib gap (DART-SDK): Dart ships no `context.Context` equivalent, so
/// cancellation stays cooperative by language design — a shared flag plus a
/// rule to stop starting new work. [FlowScope] names that rule so every
/// `flow` combinator cancels the same way. Fidelity note (AXIOM-SISTER):
/// the cooperative half of Axiom's context-bound fan-out, without
/// goroutines.
///
/// Available since praxis `0.1.0-dev`; requires Dart `^3.13.0`.
///
/// ```dart
/// final FlowScope scope = FlowScope();
/// // scope.isStopped == false
/// scope.stop();
/// // scope.isStopped == true
/// ```
final class FlowScope {
  /// Whether [stop] has been called, from inside the combinator or outside.
  bool get isStopped => _stopped;
  bool _stopped = false;

  /// Stops the scope so the combinator starts no new transform work.
  ///
  /// Stopping is advisory and idempotent: started futures run to completion
  /// because Dart futures are not preemptible, and calling [stop] twice
  /// changes nothing.
  void stop() {
    _stopped = true;
  }
}

/// Runs [transform] over every input with at most [maxInflight] concurrent
/// tasks and reports results in input order.
///
/// Starts up to [maxInflight] transforms at once and starts each next input
/// as running tasks settle, so at most [maxInflight] futures are ever in
/// flight. Results land in input order even when later inputs finish first.
/// The [inputs] iterable must be finite: it is read once up front into a
/// private list, never mutated.
///
/// The first task failure wins: no new work starts, the shared [scope]
/// stops, and the returned future completes with that failure once started
/// tasks settle. In-flight futures always run to completion because Dart
/// futures are not preemptible. Stopping [scope] from the outside has the
/// same scheduling effect; when inputs never ran as a result, the future
/// completes with a [StateError] instead of a holed list.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | inputs to transform with a cap, keeping input order | [flowMap] |
///
/// Stdlib gap (DART-SDK): [Future.wait] (`lib/async/future.dart:517`) joins
/// an unbounded set — it subscribes every future eagerly and keeps siblings
/// running after the first error — and [Stream.fromFutures]
/// (`lib/async/stream.dart:297`) is likewise unbounded and completion
/// ordered. Neither names a bounded in-flight cap with input-order results,
/// so [flowMap] owns that shape. Fidelity note (AXIOM-SISTER): mirrors the
/// bounded-worker, first-error-wins discipline of Axiom's flow package with
/// a cooperative [FlowScope] instead of a `context.Context`.
///
/// A [maxInflight] of zero or less throws an [ArgumentError]: unlike Axiom's
/// `NumCPU` fallback, a platform-neutral core cannot probe core counts
/// without `dart:io`. Empty [inputs] return an empty list without running
/// work. Synchronous throws inside [transform] count as task failures. When
/// [scope] is omitted, one internal [FlowScope] serves this call only.
///
/// Available since praxis `0.1.0-dev`; requires Dart `^3.13.0`.
///
/// ```dart
/// final List<int> doubledOutputs = await flowMap<int, int>(
///   <int>[1, 2, 3],
///   maxInflight: 2,
///   transform: (int candidateInput, FlowScope scope) async =>
///       candidateInput * 2,
/// );
/// // doubledOutputs == <int>[2, 4, 6]
/// ```
Future<List<Output>> flowMap<Input, Output>(
  Iterable<Input> inputs, {
  required int maxInflight,
  required Future<Output> Function(Input input, FlowScope scope) transform,
  FlowScope? scope,
}) {
  if (maxInflight <= 0) {
    throw ArgumentError.value(
      maxInflight,
      'maxInflight',
      'Must be greater than zero.',
    );
  }
  final List<Input> pendingInputs = inputs.toList();
  if (pendingInputs.isEmpty) {
    return Future<List<Output>>.value(<Output>[]);
  }
  return _OrderedJoin<Input, Output>(
    pendingInputs,
    maxInflight,
    transform,
    scope ?? FlowScope(),
  ).run();
}

/// Races [transform] over every input and reports the first success.
///
/// Starts up to [maxInflight] transforms at once and keeps starting pending
/// inputs while tasks fail, so the race survives failures: each failure only
/// records the first error and frees its slot for the next input. The first
/// success completes the returned future immediately and stops the shared
/// [scope] so siblings stop starting new work; in-flight futures run to
/// completion because Dart futures are not preemptible. The [inputs]
/// iterable must be finite: it is read once up front into a private list,
/// never mutated.
///
/// When every started task failed, the future completes with the first
/// chronological error — the gap against [Future.any]
/// (`lib/async/future.dart:656`), which settles on the first value OR error
/// and therefore loses slow successes to fast failures. Stopping [scope]
/// from the outside stops new work; started tasks still settle, and the
/// future completes with the recorded failure — or with a [StateError] when
/// nothing settled at all.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | the first success, ignoring failures until all fail | [flowFirst] |
///
/// Stdlib gap (DART-SDK): [Future.any] owns first-settles, not
/// first-success; no SDK combinator keeps racing past failures, so
/// [flowFirst] owns that shape. Fidelity note (AXIOM-SISTER): mirrors
/// Axiom's first-success race with cooperative [FlowScope] cancellation
/// instead of context cancellation.
///
/// A [maxInflight] of zero or less throws an [ArgumentError]: unlike Axiom's
/// `NumCPU` fallback, a platform-neutral core cannot probe core counts
/// without `dart:io`. Empty [inputs] throw an [ArgumentError] because no
/// success is possible. Synchronous throws inside [transform] count as
/// ignorable failures. When [scope] is omitted, one internal [FlowScope]
/// serves this call only.
///
/// Available since praxis `0.1.0-dev`; requires Dart `^3.13.0`.
///
/// ```dart
/// final int winnerOutput = await flowFirst<int, int>(
///   <int>[1, 2, 3],
///   maxInflight: 2,
///   transform: (int candidateInput, FlowScope scope) async =>
///       candidateInput * 10,
/// );
/// // winnerOutput == 10
/// ```
Future<Output> flowFirst<Input, Output>(
  Iterable<Input> inputs, {
  required int maxInflight,
  required Future<Output> Function(Input input, FlowScope scope) transform,
  FlowScope? scope,
}) {
  if (maxInflight <= 0) {
    throw ArgumentError.value(
      maxInflight,
      'maxInflight',
      'Must be greater than zero.',
    );
  }
  final List<Input> pendingInputs = inputs.toList();
  if (pendingInputs.isEmpty) {
    throw ArgumentError.value(
      pendingInputs,
      'inputs',
      'flowFirst needs at least one input: no success is possible.',
    );
  }
  return _FirstWin<Input, Output>(
    pendingInputs,
    maxInflight,
    transform,
    scope ?? FlowScope(),
  ).run();
}

/// Streams one [Result] per input in completion order with a bounded cap.
///
/// Starts up to [maxInflight] transforms at once and starts each next input
/// as running tasks settle, adding each outcome — [Result.ok] for successes,
/// [Result.failure] for failures — as its task finishes. Failures ride
/// beside successes as values and never throw: this is the collect-all
/// discipline, so a failing task never stops its siblings. The failure
/// [Exception] keeps its instance; non-`Exception` throwables arrive wrapped
/// with their string form, and stack traces are dropped because [Result]
/// carries the cause only. The [inputs] iterable must be finite: it is read
/// once up front into a private list, never mutated.
///
/// The stream closes after every started task settles. Stopping [scope] from
/// the outside — or cancelling the subscription — stops new work and closes
/// the stream after in-flight tasks settle, so those truncations report
/// fewer events than inputs. Empty [inputs] close immediately without
/// running work.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | one outcome per input as each finishes | [flowCollect] |
///
/// Stdlib gap (DART-SDK): [Stream.fromFutures]
/// (`lib/async/stream.dart:297`) forwards unbounded completion-order futures
/// and rethrows their errors through the stream; it names no cap and no
/// value-level failure channel. [flowCollect] owns the bounded cap with a
/// typed [Result] per input, so outcomes compose with the `result` helpers
/// instead of `try`/`catch` at the listener. Fidelity note (AXIOM-SISTER):
/// mirrors Axiom's collect-all `Result` stream over a cooperative [FlowScope]
/// instead of a channel.
///
/// A [maxInflight] of zero or less throws an [ArgumentError]: unlike Axiom's
/// `NumCPU` fallback, a platform-neutral core cannot probe core counts
/// without `dart:io`. Synchronous throws inside [transform] count as task
/// failures and ride as [Result.failure] values. When [scope] is omitted,
/// one internal [FlowScope] serves this call only.
///
/// Available since praxis `0.1.0-dev`; requires Dart `^3.13.0`.
///
/// ```dart
/// final List<Result<int>> collectedOutcomes = await flowCollect<int, int>(
///   <int>[1, 2],
///   maxInflight: 2,
///   transform: (int candidateInput, FlowScope scope) async =>
///       candidateInput * 2,
/// ).toList();
/// // collectedOutcomes.every((Result<int> outcome) => outcome.isOk) == true
/// ```
Stream<Result<Output>> flowCollect<Input, Output>(
  Iterable<Input> inputs, {
  required int maxInflight,
  required Future<Output> Function(Input input, FlowScope scope) transform,
  FlowScope? scope,
}) {
  if (maxInflight <= 0) {
    throw ArgumentError.value(
      maxInflight,
      'maxInflight',
      'Must be greater than zero.',
    );
  }
  final List<Input> pendingInputs = inputs.toList();
  if (pendingInputs.isEmpty) {
    return Stream<Result<Output>>.empty();
  }
  return _CollectStream<Input, Output>(
    pendingInputs,
    maxInflight,
    transform,
    scope ?? FlowScope(),
  ).run();
}

/// Joins bounded transform runs into input-order results for [flowMap].
///
/// [flowMap] owns the contract; this runner owns the scheduling. The first
/// task failure latches, stops the shared scope, and completes the run with
/// that failure once started tasks settle.
final class _OrderedJoin<Input, Output> {
  /// Creates a join over [pendingInputs] with the given scheduling.
  _OrderedJoin(
    this._pendingInputs,
    this._maxInflight,
    this._transform,
    this._activeScope,
  ) : _orderedOutputs = List<Output?>.filled(_pendingInputs.length, null);

  final List<Input> _pendingInputs;
  final int _maxInflight;
  final Future<Output> Function(Input input, FlowScope scope) _transform;
  final FlowScope _activeScope;
  final List<Output?> _orderedOutputs;

  final Completer<List<Output>> _completer = Completer<List<Output>>();
  int _nextIndex = 0;
  int _inflightCount = 0;
  int _settledCount = 0;
  ({Object failure, StackTrace stackTrace})? _firstFailure;

  /// Starts the bounded run and reports its future.
  Future<List<Output>> run() {
    _pump();
    return _completer.future;
  }

  void _pump() {
    while (_nextIndex < _pendingInputs.length &&
        _inflightCount < _maxInflight &&
        !_activeScope.isStopped &&
        _firstFailure == null) {
      final int slotIndex = _nextIndex;
      _nextIndex += 1;
      _inflightCount += 1;
      _startAt(slotIndex);
    }
    _maybeFinish();
  }

  void _startAt(int slotIndex) {
    Future<Output> taskFuture;
    try {
      taskFuture = _transform(_pendingInputs[slotIndex], _activeScope);
    } catch (syncFailure, syncStackTrace) {
      _inflightCount -= 1;
      _settledCount += 1;
      _recordFailure(syncFailure, syncStackTrace);
      _activeScope.stop();
      return;
    }
    unawaited(
      taskFuture.then(
        (Output successValue) => _onTaskSuccess(slotIndex, successValue),
        onError: (Object taskFailure, StackTrace taskStackTrace) =>
            _onTaskFailure(taskFailure, taskStackTrace),
      ),
    );
  }

  void _onTaskSuccess(int slotIndex, Output successValue) {
    _orderedOutputs[slotIndex] = successValue;
    _inflightCount -= 1;
    _settledCount += 1;
    _pump();
  }

  void _onTaskFailure(Object taskFailure, StackTrace taskStackTrace) {
    _inflightCount -= 1;
    _settledCount += 1;
    _recordFailure(taskFailure, taskStackTrace);
    _activeScope.stop();
    _maybeFinish();
  }

  void _recordFailure(Object taskFailure, StackTrace taskStackTrace) {
    _firstFailure ??= (failure: taskFailure, stackTrace: taskStackTrace);
  }

  void _maybeFinish() {
    if (_completer.isCompleted || _inflightCount > 0) {
      return;
    }
    final ({Object failure, StackTrace stackTrace})? latchedFailure =
        _firstFailure;
    if (latchedFailure != null) {
      _completer.completeError(
        latchedFailure.failure,
        latchedFailure.stackTrace,
      );
      return;
    }
    if (_settledCount >= _pendingInputs.length) {
      _completer.complete(<Output>[
        for (final Output? slotValue in _orderedOutputs) slotValue as Output,
      ]);
      return;
    }
    if (_activeScope.isStopped) {
      _completer.completeError(
        StateError('flowMap stopped before every input ran.'),
      );
    }
  }
}

/// Races bounded transform runs for the first success for [flowFirst].
///
/// [flowFirst] owns the contract; this runner owns the scheduling. Failures
/// only latch the first error and free their slot; the first success
/// completes the run immediately and stops the shared scope.
final class _FirstWin<Input, Output> {
  /// Creates a race over [pendingInputs] with the given scheduling.
  _FirstWin(
    this._pendingInputs,
    this._maxInflight,
    this._transform,
    this._activeScope,
  );

  final List<Input> _pendingInputs;
  final int _maxInflight;
  final Future<Output> Function(Input input, FlowScope scope) _transform;
  final FlowScope _activeScope;

  final Completer<Output> _completer = Completer<Output>();
  int _nextIndex = 0;
  int _inflightCount = 0;
  int _settledCount = 0;
  ({Object failure, StackTrace stackTrace})? _firstFailure;

  /// Starts the bounded race and reports its future.
  Future<Output> run() {
    _pump();
    return _completer.future;
  }

  void _pump() {
    while (_nextIndex < _pendingInputs.length &&
        _inflightCount < _maxInflight &&
        !_activeScope.isStopped &&
        !_completer.isCompleted) {
      final int slotIndex = _nextIndex;
      _nextIndex += 1;
      _inflightCount += 1;
      _startAt(slotIndex);
    }
    _maybeFinish();
  }

  void _startAt(int slotIndex) {
    Future<Output> taskFuture;
    try {
      taskFuture = _transform(_pendingInputs[slotIndex], _activeScope);
    } catch (syncFailure, syncStackTrace) {
      _inflightCount -= 1;
      _settledCount += 1;
      _recordFailure(syncFailure, syncStackTrace);
      return;
    }
    unawaited(
      taskFuture.then(
        _onTaskSuccess,
        onError: (Object taskFailure, StackTrace taskStackTrace) =>
            _onTaskFailure(taskFailure, taskStackTrace),
      ),
    );
  }

  void _onTaskSuccess(Output successValue) {
    if (_completer.isCompleted) {
      return;
    }
    _inflightCount -= 1;
    _settledCount += 1;
    _activeScope.stop();
    _completer.complete(successValue);
  }

  void _onTaskFailure(Object taskFailure, StackTrace taskStackTrace) {
    if (_completer.isCompleted) {
      return;
    }
    _inflightCount -= 1;
    _settledCount += 1;
    _recordFailure(taskFailure, taskStackTrace);
    _pump();
  }

  void _recordFailure(Object taskFailure, StackTrace taskStackTrace) {
    _firstFailure ??= (failure: taskFailure, stackTrace: taskStackTrace);
  }

  void _maybeFinish() {
    if (_completer.isCompleted || _inflightCount > 0) {
      return;
    }
    if (_settledCount >= _pendingInputs.length || _activeScope.isStopped) {
      final ({Object failure, StackTrace stackTrace})? latchedFailure =
          _firstFailure;
      if (latchedFailure != null) {
        _completer.completeError(
          latchedFailure.failure,
          latchedFailure.stackTrace,
        );
      } else {
        _completer.completeError(
          StateError('flowFirst stopped with no success and no failure.'),
        );
      }
    }
  }
}

/// Collects bounded transform runs as completion-order events for
/// [flowCollect].
///
/// [flowCollect] owns the contract; this runner owns the scheduling. Every
/// settlement adds one [Result] — failures never stop siblings — and the
/// controller closes once every started task settles.
final class _CollectStream<Input, Output> {
  /// Creates a collection over [pendingInputs] with the given scheduling.
  _CollectStream(
    this._pendingInputs,
    this._maxInflight,
    this._transform,
    this._activeScope,
  );

  final List<Input> _pendingInputs;
  final int _maxInflight;
  final Future<Output> Function(Input input, FlowScope scope) _transform;
  final FlowScope _activeScope;
  final StreamController<Result<Output>> _controller =
      StreamController<Result<Output>>();

  int _nextIndex = 0;
  int _inflightCount = 0;
  int _settledCount = 0;
  bool _halted = false;

  /// Starts the bounded collection and reports its stream.
  Stream<Result<Output>> run() {
    _controller.onCancel = () {
      _halted = true;
    };
    _pump();
    return _controller.stream;
  }

  void _pump() {
    while (_nextIndex < _pendingInputs.length &&
        _inflightCount < _maxInflight &&
        !_halted &&
        !_activeScope.isStopped) {
      final int slotIndex = _nextIndex;
      _nextIndex += 1;
      _inflightCount += 1;
      _startAt(slotIndex);
    }
    _maybeClose();
  }

  void _startAt(int slotIndex) {
    Future<Output> taskFuture;
    try {
      taskFuture = _transform(_pendingInputs[slotIndex], _activeScope);
    } catch (syncFailure) {
      _inflightCount -= 1;
      _settledCount += 1;
      _addOutcome(Result<Output>.failure(_asException(syncFailure)));
      return;
    }
    unawaited(
      taskFuture.then(
        (Output successValue) => _settle(Result<Output>.ok(successValue)),
        onError: (Object taskFailure) =>
            _settle(Result<Output>.failure(_asException(taskFailure))),
      ),
    );
  }

  void _settle(Result<Output> outcome) {
    _inflightCount -= 1;
    _settledCount += 1;
    _addOutcome(outcome);
    _pump();
  }

  void _addOutcome(Result<Output> outcome) {
    if (!_halted && !_controller.isClosed) {
      _controller.add(outcome);
    }
  }

  void _maybeClose() {
    if (_controller.isClosed || _inflightCount > 0) {
      return;
    }
    if (_settledCount >= _pendingInputs.length ||
        _halted ||
        _activeScope.isStopped) {
      unawaited(_controller.close());
    }
  }
}

/// Coerces a task failure into the [Exception] that [Result.failure] holds.
///
/// Passes [Exception] instances through untouched so identity pins hold;
/// wraps anything else with its string form because [Result] names
/// [Exception] as its only failure value by design.
Exception _asException(Object taskFailure) {
  if (taskFailure is Exception) {
    return taskFailure;
  }
  return Exception('flow task failed with a non-Exception: $taskFailure');
}
