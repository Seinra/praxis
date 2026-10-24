import 'dart:async';

import 'package:praxis/src/flow.dart';
import 'package:praxis/src/result.dart';
import 'package:test/test.dart';

/// Pumps the microtask queue so gated futures settle without real delays.
///
/// Every `flow` combinator schedules through microtasks only, so awaiting a
/// completed future a few dozen times flushes every pending handler. No
/// timers, no wall-clock waits: the suite stays fake-async end to end.
Future<void> flushMicrotasks([int roundCount = 25]) async {
  for (int roundIndex = 0; roundIndex < roundCount; roundIndex += 1) {
    await Future<void>.value();
  }
}

void main() {
  group('FlowScope', () {
    test('starts unstopped and stays stopped', () {
      final FlowScope scope = FlowScope();

      expect(scope.isStopped, isFalse);
      scope.stop();
      expect(scope.isStopped, isTrue);
      scope.stop();
      expect(scope.isStopped, isTrue);
    });

    test('internal scopes stay private to each call', () async {
      final FlowScope ownerScope = FlowScope();
      final Completer<int> firstGate = Completer<int>();
      final Completer<int> secondGate = Completer<int>();
      final Completer<int> thirdGate = Completer<int>();

      final Future<List<int>> ownedOutputs = flowMap<int, int>(
        <int>[0, 1],
        maxInflight: 1,
        transform: (int candidateInput, FlowScope scope) =>
            candidateInput == 0 ? firstGate.future : secondGate.future,
        scope: ownerScope,
      );
      final Future<List<int>> internalOutputs = flowMap<int, int>(
        <int>[0],
        maxInflight: 1,
        transform: (int candidateInput, FlowScope scope) => thirdGate.future,
      );

      await flushMicrotasks();
      ownerScope.stop();
      firstGate.complete(1);
      thirdGate.complete(2);

      await expectLater(ownedOutputs, throwsA(isStateError));
      expect(await internalOutputs, equals(<int>[2]));
    });
  });

  group('flowMap', () {
    test('empty inputs return an empty list without running work', () async {
      int startedCount = 0;
      final List<int> orderedOutputs = await flowMap<int, int>(
        <int>[],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) {
          startedCount += 1;
          return Future<int>.value(candidateInput * 2);
        },
      );

      expect(orderedOutputs, isEmpty);
      expect(startedCount, equals(0));
    });

    test('zero and negative caps throw ArgumentError', () {
      Future<List<int>> runWithCap(int capValue) => flowMap<int, int>(
        <int>[1],
        maxInflight: capValue,
        transform: (int candidateInput, FlowScope scope) =>
            Future<int>.value(candidateInput),
      );

      expect(() => runWithCap(0), throwsArgumentError);
      expect(() => runWithCap(-2), throwsArgumentError);
    });

    test('cap of one serializes transforms and keeps input order', () async {
      final List<int> startedInputs = <int>[];
      int currentInflight = 0;
      int maxObservedInflight = 0;
      final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
        for (final int candidateInput in <int>[10, 20, 30])
          candidateInput: Completer<int>(),
      };

      final Future<List<int>> pendingOutputs = flowMap<int, int>(
        <int>[10, 20, 30],
        maxInflight: 1,
        transform: (int candidateInput, FlowScope scope) {
          startedInputs.add(candidateInput);
          currentInflight += 1;
          if (currentInflight > maxObservedInflight) {
            maxObservedInflight = currentInflight;
          }
          return gateByInput[candidateInput]!.future.then((int gatedValue) {
            currentInflight -= 1;
            return gatedValue;
          });
        },
      );

      await flushMicrotasks();
      expect(startedInputs, equals(<int>[10]));

      gateByInput[10]!.complete(1);
      await flushMicrotasks();
      expect(startedInputs, equals(<int>[10, 20]));

      gateByInput[20]!.complete(2);
      await flushMicrotasks();
      expect(startedInputs, equals(<int>[10, 20, 30]));

      gateByInput[30]!.complete(3);
      expect(await pendingOutputs, equals(<int>[1, 2, 3]));
      expect(maxObservedInflight, equals(1));
    });

    test('results keep input order when later inputs finish first', () async {
      final List<int> startedInputs = <int>[];
      final Map<int, Completer<String>> gateByInput = <int, Completer<String>>{
        for (final int candidateInput in <int>[0, 1, 2])
          candidateInput: Completer<String>(),
      };

      final Future<List<String>> pendingOutputs = flowMap<int, String>(
        <int>[0, 1, 2],
        maxInflight: 3,
        transform: (int candidateInput, FlowScope scope) {
          startedInputs.add(candidateInput);
          return gateByInput[candidateInput]!.future;
        },
      );

      await flushMicrotasks();
      expect(startedInputs, equals(<int>[0, 1, 2]));

      gateByInput[2]!.complete('two');
      gateByInput[0]!.complete('zero');
      gateByInput[1]!.complete('one');

      expect(await pendingOutputs, equals(<String>['zero', 'one', 'two']));
    });

    test(
      'first failure stops new work, in-flight runs to completion',
      () async {
        final Exception rootFailure = Exception('input zero failed');
        final List<int> startedInputs = <int>[];
        final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
          for (final int candidateInput in <int>[0, 1, 2, 3])
            candidateInput: Completer<int>(),
        };
        bool siblingSettled = false;

        final Future<List<int>> pendingOutputs = flowMap<int, int>(
          <int>[0, 1, 2, 3],
          maxInflight: 2,
          transform: (int candidateInput, FlowScope scope) {
            startedInputs.add(candidateInput);
            return gateByInput[candidateInput]!.future.then((int gatedValue) {
              if (candidateInput == 1) {
                siblingSettled = true;
              }
              return gatedValue;
            });
          },
        );

        await flushMicrotasks();
        expect(startedInputs, equals(<int>[0, 1]));

        gateByInput[0]!.completeError(rootFailure);
        await flushMicrotasks();
        expect(startedInputs, equals(<int>[0, 1]));

        gateByInput[1]!.complete(11);
        await expectLater(pendingOutputs, throwsA(same(rootFailure)));
        expect(siblingSettled, isTrue);
      },
    );

    test('first chronological failure wins over later failures', () async {
      final Exception earlyFailure = Exception('early sibling failed');
      final Exception lateFailure = Exception('late sibling failed');
      final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
        for (final int candidateInput in <int>[0, 1])
          candidateInput: Completer<int>(),
      };

      final Future<List<int>> pendingOutputs = flowMap<int, int>(
        <int>[0, 1],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) =>
            gateByInput[candidateInput]!.future,
      );

      await flushMicrotasks();
      gateByInput[1]!.completeError(earlyFailure);
      await flushMicrotasks();
      gateByInput[0]!.completeError(lateFailure);

      await expectLater(pendingOutputs, throwsA(same(earlyFailure)));
    });

    test(
      'synchronous throws inside transform count as task failures',
      () async {
        final StateError syncFailure = StateError('sync zero boom');
        final List<int> startedInputs = <int>[];

        final Future<List<int>> pendingOutputs = flowMap<int, int>(
          <int>[0, 1, 2],
          maxInflight: 2,
          transform: (int candidateInput, FlowScope scope) {
            startedInputs.add(candidateInput);
            if (candidateInput == 0) {
              throw syncFailure;
            }
            return Future<int>.value(candidateInput);
          },
        );

        await expectLater(pendingOutputs, throwsA(same(syncFailure)));
        expect(startedInputs, equals(<int>[0]));
      },
    );

    test('external stop prevents new work and fails closed', () async {
      final FlowScope ownerScope = FlowScope();
      final List<int> startedInputs = <int>[];
      final Completer<int> firstGate = Completer<int>();

      final Future<List<int>> pendingOutputs = flowMap<int, int>(
        <int>[0, 1],
        maxInflight: 1,
        transform: (int candidateInput, FlowScope scope) {
          startedInputs.add(candidateInput);
          return firstGate.future;
        },
        scope: ownerScope,
      );

      await flushMicrotasks();
      expect(startedInputs, equals(<int>[0]));

      ownerScope.stop();
      firstGate.complete(7);
      await expectLater(pendingOutputs, throwsA(isStateError));
      expect(startedInputs, equals(<int>[0]));
    });
  });

  group('flowFirst', () {
    test('empty inputs throw ArgumentError', () {
      expect(
        () => flowFirst<int, int>(
          <int>[],
          maxInflight: 2,
          transform: (int candidateInput, FlowScope scope) =>
              Future<int>.value(candidateInput),
        ),
        throwsArgumentError,
      );
    });

    test('zero and negative caps throw ArgumentError', () {
      Future<int> runWithCap(int capValue) => flowFirst<int, int>(
        <int>[1],
        maxInflight: capValue,
        transform: (int candidateInput, FlowScope scope) =>
            Future<int>.value(candidateInput),
      );

      expect(() => runWithCap(0), throwsArgumentError);
      expect(() => runWithCap(-2), throwsArgumentError);
    });

    test('first success wins while failures are ignored', () async {
      final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
        for (final int candidateInput in <int>[0, 1, 2])
          candidateInput: Completer<int>(),
      };

      final Future<int> pendingWinner = flowFirst<int, int>(
        <int>[0, 1, 2],
        maxInflight: 3,
        transform: (int candidateInput, FlowScope scope) =>
            gateByInput[candidateInput]!.future,
      );

      await flushMicrotasks();
      gateByInput[0]!.completeError(Exception('slow zero failed'));
      gateByInput[2]!.complete(22);

      expect(await pendingWinner, equals(22));

      gateByInput[1]!.complete(11);
      await flushMicrotasks();
    });

    test('winning success stops new work through the shared scope', () async {
      final FlowScope ownerScope = FlowScope();
      final List<int> startedInputs = <int>[];
      final Completer<int> firstGate = Completer<int>();

      final Future<int> pendingWinner = flowFirst<int, int>(
        <int>[0, 1],
        maxInflight: 1,
        transform: (int candidateInput, FlowScope scope) {
          startedInputs.add(candidateInput);
          return firstGate.future;
        },
        scope: ownerScope,
      );

      await flushMicrotasks();
      expect(startedInputs, equals(<int>[0]));

      firstGate.complete(7);
      expect(await pendingWinner, equals(7));
      expect(ownerScope.isStopped, isTrue);

      await flushMicrotasks();
      expect(startedInputs, equals(<int>[0]));
    });

    test('every failure reports the first chronological error', () async {
      final Exception earlyFailure = Exception('early sibling failed');
      final Exception lateFailure = Exception('late sibling failed');
      final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
        for (final int candidateInput in <int>[0, 1])
          candidateInput: Completer<int>(),
      };

      final Future<int> pendingWinner = flowFirst<int, int>(
        <int>[0, 1],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) =>
            gateByInput[candidateInput]!.future,
      );

      await flushMicrotasks();
      gateByInput[1]!.completeError(earlyFailure);
      await flushMicrotasks();
      gateByInput[0]!.completeError(lateFailure);

      await expectLater(pendingWinner, throwsA(same(earlyFailure)));
    });

    test('slow success still wins over an eager failure', () async {
      final Completer<int> slowGate = Completer<int>();
      final Future<int> pendingWinner = flowFirst<int, int>(
        <int>[0, 1],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) {
          if (candidateInput == 0) {
            return Future<int>.error(Exception('fast zero failed'));
          }
          return slowGate.future;
        },
      );

      await flushMicrotasks();
      slowGate.complete(11);

      expect(await pendingWinner, equals(11));
    });

    test('synchronous throws count as ignorable failures', () async {
      final Future<int> pendingWinner = flowFirst<int, int>(
        <int>[0, 1],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) {
          if (candidateInput == 0) {
            throw StateError('sync zero boom');
          }
          return Future<int>.value(11);
        },
      );

      expect(await pendingWinner, equals(11));
    });

    test('started work still settles after external stop', () async {
      final FlowScope ownerScope = FlowScope();
      final Completer<int> firstGate = Completer<int>();

      final Future<int> pendingWinner = flowFirst<int, int>(
        <int>[0, 1],
        maxInflight: 1,
        transform: (int candidateInput, FlowScope scope) => firstGate.future,
        scope: ownerScope,
      );

      await flushMicrotasks();
      ownerScope.stop();
      firstGate.complete(7);

      expect(await pendingWinner, equals(7));
    });

    test(
      'external stop with pending work reports the recorded failure',
      () async {
        final FlowScope ownerScope = FlowScope();
        final Exception recordedFailure = Exception('recorded zero failed');
        final List<int> startedInputs = <int>[];
        final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
          for (final int candidateInput in <int>[0, 1])
            candidateInput: Completer<int>(),
        };

        final Future<int> pendingWinner = flowFirst<int, int>(
          <int>[0, 1],
          maxInflight: 1,
          transform: (int candidateInput, FlowScope scope) {
            startedInputs.add(candidateInput);
            return gateByInput[candidateInput]!.future;
          },
          scope: ownerScope,
        );

        await flushMicrotasks();
        ownerScope.stop();
        gateByInput[0]!.completeError(recordedFailure);

        await expectLater(pendingWinner, throwsA(same(recordedFailure)));
        expect(startedInputs, equals(<int>[0]));
      },
    );
  });

  group('flowCollect', () {
    test('empty inputs close immediately without running work', () async {
      int startedCount = 0;
      final List<Result<int>> collectedOutcomes = await flowCollect<int, int>(
        <int>[],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) {
          startedCount += 1;
          return Future<int>.value(candidateInput * 2);
        },
      ).toList();

      expect(collectedOutcomes, isEmpty);
      expect(startedCount, equals(0));
    });

    test('zero and negative caps throw ArgumentError', () {
      Stream<Result<int>> runWithCap(int capValue) => flowCollect<int, int>(
        <int>[1],
        maxInflight: capValue,
        transform: (int candidateInput, FlowScope scope) =>
            Future<int>.value(candidateInput),
      );

      expect(() => runWithCap(0), throwsArgumentError);
      expect(() => runWithCap(-2), throwsArgumentError);
    });

    test('emits one result per input in completion order', () async {
      final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
        for (final int candidateInput in <int>[0, 1, 2])
          candidateInput: Completer<int>(),
      };

      final Future<List<Result<int>>> pendingCollected = flowCollect<int, int>(
        <int>[0, 1, 2],
        maxInflight: 3,
        transform: (int candidateInput, FlowScope scope) =>
            gateByInput[candidateInput]!.future,
      ).toList();

      await flushMicrotasks();
      gateByInput[1]!.complete(11);
      gateByInput[0]!.complete(10);
      gateByInput[2]!.complete(12);

      final List<Result<int>> collectedOutcomes = await pendingCollected;
      expect(
        collectedOutcomes
            .map((Result<int> outcome) => outcome.getOrElse(-1))
            .toList(),
        equals(<int>[11, 10, 12]),
      );
      expect(
        collectedOutcomes.every((Result<int> outcome) => outcome.isOk),
        isTrue,
      );
    });

    test('failures ride beside successes without throwing', () async {
      final Exception rootFailure = Exception('input zero failed');
      final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
        for (final int candidateInput in <int>[0, 1])
          candidateInput: Completer<int>(),
      };

      final Future<List<Result<int>>> pendingCollected = flowCollect<int, int>(
        <int>[0, 1],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) =>
            gateByInput[candidateInput]!.future,
      ).toList();

      await flushMicrotasks();
      gateByInput[0]!.completeError(rootFailure);
      gateByInput[1]!.complete(11);

      final List<Result<int>> collectedOutcomes = await pendingCollected;
      expect(collectedOutcomes.length, equals(2));
      final Result<int> failureOutcome = collectedOutcomes.firstWhere(
        (Result<int> outcome) => outcome.isFailure,
      );
      final Object carriedCause = failureOutcome.when(
        ok: (int successValue) => throw StateError('expected a failure'),
        failure: (Exception failureCause) => failureCause,
      );
      expect(carriedCause, same(rootFailure));
      expect(
        collectedOutcomes
            .where((Result<int> outcome) => outcome.isOk)
            .map((Result<int> outcome) => outcome.getOrElse(-1))
            .toList(),
        equals(<int>[11]),
      );
    });

    test('task failure never stops sibling work', () async {
      final Exception rootFailure = Exception('input zero failed');
      final List<int> startedInputs = <int>[];
      final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
        for (final int candidateInput in <int>[0, 1, 2])
          candidateInput: Completer<int>(),
      };

      final Future<List<Result<int>>> pendingCollected = flowCollect<int, int>(
        <int>[0, 1, 2],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) {
          startedInputs.add(candidateInput);
          return gateByInput[candidateInput]!.future;
        },
      ).toList();

      await flushMicrotasks();
      expect(startedInputs, equals(<int>[0, 1]));

      gateByInput[0]!.completeError(rootFailure);
      await flushMicrotasks();
      expect(startedInputs, equals(<int>[0, 1, 2]));

      gateByInput[1]!.complete(11);
      gateByInput[2]!.complete(12);

      final List<Result<int>> collectedOutcomes = await pendingCollected;
      expect(collectedOutcomes.length, equals(3));
      expect(
        collectedOutcomes
            .where((Result<int> outcome) => outcome.isFailure)
            .length,
        equals(1),
      );
    });

    test('cap of one serializes collection', () async {
      final List<int> startedInputs = <int>[];
      int currentInflight = 0;
      int maxObservedInflight = 0;
      final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
        for (final int candidateInput in <int>[10, 20])
          candidateInput: Completer<int>(),
      };

      final Future<List<Result<int>>> pendingCollected = flowCollect<int, int>(
        <int>[10, 20],
        maxInflight: 1,
        transform: (int candidateInput, FlowScope scope) {
          startedInputs.add(candidateInput);
          currentInflight += 1;
          if (currentInflight > maxObservedInflight) {
            maxObservedInflight = currentInflight;
          }
          return gateByInput[candidateInput]!.future.then((int gatedValue) {
            currentInflight -= 1;
            return gatedValue;
          });
        },
      ).toList();

      await flushMicrotasks();
      expect(startedInputs, equals(<int>[10]));

      gateByInput[10]!.complete(1);
      await flushMicrotasks();
      expect(startedInputs, equals(<int>[10, 20]));

      gateByInput[20]!.complete(2);
      final List<Result<int>> collectedOutcomes = await pendingCollected;
      expect(
        collectedOutcomes
            .map((Result<int> outcome) => outcome.getOrElse(-1))
            .toList(),
        equals(<int>[1, 2]),
      );
      expect(maxObservedInflight, equals(1));
    });

    test('synchronous Exception throws ride as identical failures', () async {
      final Exception syncFailure = Exception('sync zero boom');

      final List<Result<int>> collectedOutcomes = await flowCollect<int, int>(
        <int>[0, 1],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) {
          if (candidateInput == 0) {
            throw syncFailure;
          }
          return Future<int>.value(11);
        },
      ).toList();

      expect(collectedOutcomes.length, equals(2));
      final Result<int> failureOutcome = collectedOutcomes.firstWhere(
        (Result<int> outcome) => outcome.isFailure,
      );
      final Object carriedCause = failureOutcome.when(
        ok: (int successValue) => throw StateError('expected a failure'),
        failure: (Exception failureCause) => failureCause,
      );
      expect(carriedCause, same(syncFailure));
    });

    test('synchronous non-Exception throws ride wrapped', () async {
      final StateError syncFailure = StateError('sync zero boom');

      final List<Result<int>> collectedOutcomes = await flowCollect<int, int>(
        <int>[0, 1],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) {
          if (candidateInput == 0) {
            throw syncFailure;
          }
          return Future<int>.value(11);
        },
      ).toList();

      expect(collectedOutcomes.length, equals(2));
      final Result<int> failureOutcome = collectedOutcomes.firstWhere(
        (Result<int> outcome) => outcome.isFailure,
      );
      final Object carriedCause = failureOutcome.when(
        ok: (int successValue) => throw StateError('expected a failure'),
        failure: (Exception failureCause) => failureCause,
      );
      expect(carriedCause, isNot(same(syncFailure)));
      expect('$carriedCause', contains('sync zero boom'));
    });

    test('external stop closes the stream after in-flight settle', () async {
      final FlowScope ownerScope = FlowScope();
      final List<int> startedInputs = <int>[];
      final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
        for (final int candidateInput in <int>[0, 1, 2])
          candidateInput: Completer<int>(),
      };

      final Future<List<Result<int>>> pendingCollected = flowCollect<int, int>(
        <int>[0, 1, 2],
        maxInflight: 1,
        transform: (int candidateInput, FlowScope scope) {
          startedInputs.add(candidateInput);
          return gateByInput[candidateInput]!.future;
        },
        scope: ownerScope,
      ).toList();

      await flushMicrotasks();
      expect(startedInputs, equals(<int>[0]));

      ownerScope.stop();
      gateByInput[0]!.complete(10);

      final List<Result<int>> collectedOutcomes = await pendingCollected;
      expect(
        collectedOutcomes
            .map((Result<int> outcome) => outcome.getOrElse(-1))
            .toList(),
        equals(<int>[10]),
      );
      expect(startedInputs, equals(<int>[0]));
    });

    test('cancelling the subscription stops new work', () async {
      final List<int> startedInputs = <int>[];
      final Map<int, Completer<int>> gateByInput = <int, Completer<int>>{
        for (final int candidateInput in <int>[0, 1])
          candidateInput: Completer<int>(),
      };
      final List<Result<int>> receivedOutcomes = <Result<int>>[];

      final Stream<Result<int>> outcomeStream = flowCollect<int, int>(
        <int>[0, 1],
        maxInflight: 1,
        transform: (int candidateInput, FlowScope scope) {
          startedInputs.add(candidateInput);
          return gateByInput[candidateInput]!.future;
        },
      );
      final StreamSubscription<Result<int>> subscription = outcomeStream.listen(
        receivedOutcomes.add,
      );

      await flushMicrotasks();
      expect(startedInputs, equals(<int>[0]));

      await subscription.cancel();
      gateByInput[0]!.complete(10);
      await flushMicrotasks();

      expect(startedInputs, equals(<int>[0]));
      expect(receivedOutcomes, isEmpty);
    });
  });

  group('documented examples stay runnable', () {
    test('flowMap example', () async {
      final List<int> doubledOutputs = await flowMap<int, int>(
        <int>[1, 2, 3],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) async =>
            candidateInput * 2,
      );

      expect(doubledOutputs, equals(<int>[2, 4, 6]));
    });

    test('flowFirst example', () async {
      final int winnerOutput = await flowFirst<int, int>(
        <int>[1, 2, 3],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) async =>
            candidateInput * 10,
      );

      expect(winnerOutput, equals(10));
    });

    test('flowCollect example', () async {
      final List<Result<int>> collectedOutcomes = await flowCollect<int, int>(
        <int>[1, 2],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) async =>
            candidateInput * 2,
      ).toList();

      expect(
        collectedOutcomes
            .map((Result<int> outcome) => outcome.getOrElse(-1))
            .toList(),
        equals(<int>[2, 4]),
      );
      expect(
        collectedOutcomes.every((Result<int> outcome) => outcome.isOk),
        isTrue,
      );
    });

    test('FlowScope example', () {
      final FlowScope scope = FlowScope();

      expect(scope.isStopped, isFalse);
      scope.stop();
      expect(scope.isStopped, isTrue);
    });
  });
}
