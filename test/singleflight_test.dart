import 'dart:async';

import 'package:praxis/src/singleflight.dart';
import 'package:test/test.dart';

/// Pumps the microtask queue so gated futures settle without real delays.
///
/// Singleflight schedules cleanup through microtasks only, so awaiting a
/// completed future flushes every pending handler. No timers, no
/// wall-clock waits: the suite stays fake-async end to end.
Future<void> flushMicrotasks([int roundCount = 25]) async {
  for (int roundIndex = 0; roundIndex < roundCount; roundIndex += 1) {
    await Future<void>.value();
  }
}

void main() {
  group('SingleflightGroup.call', () {
    test('concurrent same-key callers share one execution', () async {
      final SingleflightGroup<String, int> flightGroup =
          SingleflightGroup<String, int>();
      int executionCount = 0;
      final Completer<int> gate = Completer<int>();

      final Future<int> firstPending = flightGroup.call('shared', () {
        executionCount += 1;
        return gate.future;
      });
      final Future<int> secondPending = flightGroup.call('shared', () {
        executionCount += 1;
        return gate.future;
      });

      expect(identical(firstPending, secondPending), isTrue);
      gate.complete(42);
      expect(await firstPending, equals(42));
      expect(await secondPending, equals(42));
      expect(executionCount, equals(1));
    });

    test('sequential same-key calls re-execute without caching', () async {
      final SingleflightGroup<String, int> flightGroup =
          SingleflightGroup<String, int>();
      int executionCount = 0;
      Future<int> produceOutcome() async {
        executionCount += 1;
        return executionCount;
      }

      expect(await flightGroup.call('chain', produceOutcome), equals(1));
      expect(await flightGroup.call('chain', produceOutcome), equals(2));
      expect(executionCount, equals(2));
    });

    test('errors propagate to all sharers through the shared future', () async {
      final SingleflightGroup<String, int> flightGroup =
          SingleflightGroup<String, int>();
      int executionCount = 0;
      final Exception rootFailure = Exception('backend offline');
      final Completer<int> gate = Completer<int>();

      final Future<int> firstPending = flightGroup.call('fragile', () {
        executionCount += 1;
        return gate.future;
      });
      final Future<int> secondPending = flightGroup.call('fragile', () {
        executionCount += 1;
        return gate.future;
      });

      expect(identical(firstPending, secondPending), isTrue);
      gate.completeError(rootFailure);
      await expectLater(firstPending, throwsA(same(rootFailure)));
      await expectLater(secondPending, throwsA(same(rootFailure)));
      expect(executionCount, equals(1));

      await flushMicrotasks();
      expect(await flightGroup.call('fragile', () async => 7), equals(7));
    });

    test('distinct keys run apart', () async {
      final SingleflightGroup<String, int> flightGroup =
          SingleflightGroup<String, int>();
      int executionCount = 0;
      final Completer<int> northGate = Completer<int>();
      final Completer<int> southGate = Completer<int>();

      final Future<int> northPending = flightGroup.call('north', () {
        executionCount += 1;
        return northGate.future;
      });
      final Future<int> southPending = flightGroup.call('south', () {
        executionCount += 1;
        return southGate.future;
      });

      expect(identical(northPending, southPending), isFalse);
      northGate.complete(1);
      southGate.complete(2);
      expect(await northPending, equals(1));
      expect(await southPending, equals(2));
      expect(executionCount, equals(2));
    });

    test(
      'completion forgets the key so post-settle recall re-executes',
      () async {
        final SingleflightGroup<String, int> flightGroup =
            SingleflightGroup<String, int>();
        int executionCount = 0;
        final Completer<int> gate = Completer<int>();
        Future<int> gatedAction() async {
          executionCount += 1;
          return gate.future;
        }

        final Future<int> firstPending = flightGroup.call(
          'forgetful',
          gatedAction,
        );
        gate.complete(11);
        expect(await firstPending, equals(11));
        expect(executionCount, equals(1));

        await flushMicrotasks();
        final Future<int> secondPending = flightGroup.call(
          'forgetful',
          () async {
            executionCount += 1;
            return 22;
          },
        );

        expect(identical(firstPending, secondPending), isFalse);
        expect(await secondPending, equals(22));
        expect(executionCount, equals(2));
      },
    );

    test('synchronous throws become error futures without sharing', () async {
      final SingleflightGroup<String, int> flightGroup =
          SingleflightGroup<String, int>();
      int executionCount = 0;

      await expectLater(
        flightGroup.call('sync', () {
          executionCount += 1;
          throw StateError('sync boom');
        }),
        throwsStateError,
      );
      expect(executionCount, equals(1));

      expect(
        await flightGroup.call('sync', () async {
          executionCount += 1;
          return 7;
        }),
        equals(7),
      );
      expect(executionCount, equals(2));
    });
  });

  group('documented examples stay runnable', () {
    test('SingleflightGroup example', () async {
      final SingleflightGroup<String, int> flightGroup =
          SingleflightGroup<String, int>();
      final int sharedValue = await flightGroup.call('user:7', () async => 42);

      expect(sharedValue, equals(42));
    });

    test('SingleflightGroup.new example', () async {
      final SingleflightGroup<String, int> flightGroup =
          SingleflightGroup<String, int>();

      expect(await flightGroup.call('user:7', () async => 42), equals(42));
    });

    test('SingleflightGroup.call example', () async {
      final SingleflightGroup<String, int> flightGroup =
          SingleflightGroup<String, int>();
      final int sharedValue = await flightGroup.call('user:7', () async => 42);

      expect(sharedValue, equals(42));
    });
  });
}
