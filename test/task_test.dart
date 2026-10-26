import 'package:praxis/src/result.dart';
import 'package:praxis/src/task.dart';
import 'package:test/test.dart';

void main() {
  group('Task.spawn', () {
    test('runs compute eagerly without join', () async {
      bool startedCompute = false;
      final Task<int> backgroundTask = Task<int>.spawn(() async {
        startedCompute = true;
        return 42;
      });
      expect(startedCompute, isTrue);
      final Result<int> outcome = await backgroundTask.join();
      expect(outcome.getOrElse(0), equals(42));
    });

    test('sync throw inside compute becomes failure not a throw', () async {
      final Task<int> backgroundTask = Task<int>.spawn(() {
        throw StateError('compute offline');
      });
      final Result<int> outcome = await backgroundTask.join();
      expect(outcome.isFailure, isTrue);
      expect(outcome.getOrElse(0), equals(0));
    });

    test('non-Exception error arrives wrapped with its string form', () async {
      final Task<int> backgroundTask = Task<int>.spawn(() async {
        throw ArgumentError('plain stop');
      });
      final Result<int> outcome = await backgroundTask.join();
      expect(outcome.isFailure, isTrue);
      final Exception? wrappedCause = outcome.when(
        ok: (int successValue) => null,
        failure: (Exception failureCause) => failureCause,
      );
      expect(wrappedCause, isNotNull);
      expect(wrappedCause.toString(), contains('plain stop'));
    });
  });

  group('Task.join', () {
    test(
      'shares one success across concurrent joiners and runs once',
      () async {
        int computeRuns = 0;
        final Task<int> backgroundTask = Task<int>.spawn(() async {
          computeRuns += 1;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return 42;
        });
        final List<Result<int>> sharedOutcomes = await Future.wait(
          <Future<Result<int>>>[
            for (int joinIndex = 0; joinIndex < 5; joinIndex++)
              backgroundTask.join(),
          ],
        );
        expect(computeRuns, equals(1));
        for (final Result<int> sharedOutcome in sharedOutcomes) {
          expect(sharedOutcome.getOrElse(0), equals(42));
        }
      },
    );

    test(
      'shares one failure across joiners with the identical cause',
      () async {
        final Exception rootCause = Exception('shared stop');
        int computeRuns = 0;
        final Task<int> backgroundTask = Task<int>.spawn(() async {
          computeRuns += 1;
          throw rootCause;
        });
        final Result<int> firstOutcome = await backgroundTask.join();
        final Result<int> secondOutcome = await backgroundTask.join();
        expect(computeRuns, equals(1));
        final Exception? firstCause = firstOutcome.when(
          ok: (int successValue) => null,
          failure: (Exception failureCause) => failureCause,
        );
        final Exception? secondCause = secondOutcome.when(
          ok: (int successValue) => null,
          failure: (Exception failureCause) => failureCause,
        );
        expect(identical(firstCause, rootCause), isTrue);
        expect(identical(secondCause, rootCause), isTrue);
      },
    );

    test(
      'repeated joins after settle share the outcome without rerunning',
      () async {
        int computeRuns = 0;
        final Task<int> backgroundTask = Task<int>.spawn(() async {
          computeRuns += 1;
          return 42;
        });
        final Result<int> firstOutcome = await backgroundTask.join();
        final Result<int> secondOutcome = await backgroundTask.join();
        expect(firstOutcome.getOrElse(0), equals(42));
        expect(secondOutcome.getOrElse(0), equals(42));
        expect(computeRuns, equals(1));
      },
    );

    test('joiners share the identical immutable outcome', () async {
      final Task<int> backgroundTask = Task<int>.spawn(() async => 42);
      final Result<int> firstOutcome = await backgroundTask.join();
      final Result<int> secondOutcome = await backgroundTask.join();
      expect(identical(firstOutcome, secondOutcome), isTrue);
    });
  });
}
