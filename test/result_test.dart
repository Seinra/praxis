import 'package:praxis/src/result.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    group('constructs each side', () {
      test('ok holds the success side', () {
        final Result<int> outcome = Result<int>.ok(21);

        expect(outcome.isOk, isTrue);
        expect(outcome.isFailure, isFalse);
        expect(outcome.getOrElse(0), equals(21));
      });

      test('failure holds the failure side', () {
        final Result<int> outcome = Result<int>.failure(
          Exception('connection lost'),
        );

        expect(outcome.isOk, isFalse);
        expect(outcome.isFailure, isTrue);
        expect(outcome.getOrElse(0), equals(0));
      });
    });

    group('asks the side', () {
      final List<
        ({
          String description,
          Result<int> outcome,
          bool expectedIsOk,
          bool expectedIsFailure,
        })
      >
      sideCases =
          <
            ({
              String description,
              Result<int> outcome,
              bool expectedIsOk,
              bool expectedIsFailure,
            })
          >[
            (
              description: 'ok reports the success side',
              outcome: Result<int>.ok(1),
              expectedIsOk: true,
              expectedIsFailure: false,
            ),
            (
              description: 'failure reports the failure side',
              outcome: Result<int>.failure(Exception('offline')),
              expectedIsOk: false,
              expectedIsFailure: true,
            ),
          ];

      for (final sideCase in sideCases) {
        test(sideCase.description, () {
          expect(sideCase.outcome.isOk, equals(sideCase.expectedIsOk));
          expect(
            sideCase.outcome.isFailure,
            equals(sideCase.expectedIsFailure),
          );
        });
      }
    });

    group('splits explicitly with when', () {
      String describeOutcome(Result<int> outcome) {
        return outcome.when(
          ok: (int successValue) => 'ok:$successValue',
          failure: (Exception failureCause) => 'failure',
        );
      }

      test('ok takes the success branch', () {
        expect(describeOutcome(Result<int>.ok(3)), equals('ok:3'));
      });

      test('failure takes the failure branch', () {
        expect(
          describeOutcome(Result<int>.failure(Exception('offline'))),
          equals('failure'),
        );
      });

      final List<
        ({String description, Result<int> outcome, String expectedLabel})
      >
      splitCases =
          <({String description, Result<int> outcome, String expectedLabel})>[
            (
              description: 'ok one splits to its label',
              outcome: Result<int>.ok(1),
              expectedLabel: 'ok:1',
            ),
            (
              description: 'ok two splits to its label',
              outcome: Result<int>.ok(2),
              expectedLabel: 'ok:2',
            ),
            (
              description: 'failure splits to the failure label',
              outcome: Result<int>.failure(Exception('offline')),
              expectedLabel: 'failure',
            ),
          ];

      for (final splitCase in splitCases) {
        test(splitCase.description, () {
          expect(
            describeOutcome(splitCase.outcome),
            equals(splitCase.expectedLabel),
          );
        });
      }
    });

    group('reads with getOrElse', () {
      test('ok ignores the fallback value', () {
        expect(Result<int>.ok(7).getOrElse(0), equals(7));
      });

      test('failure returns the fallback value', () {
        expect(
          Result<int>.failure(Exception('offline')).getOrElse(0),
          equals(0),
        );
      });

      test('ok holding null still reports success and reads null', () {
        final Result<String?> outcome = Result<String?>.ok(null);

        expect(outcome.isOk, isTrue);
        expect(outcome.getOrElse('fallback'), isNull);
      });
    });

    group('transforms the success side with mapValue', () {
      Result<int> doubleOutcome(Result<int> outcome) {
        return outcome.mapValue((int successValue) => successValue * 2);
      }

      test('ok maps the success value', () {
        expect(doubleOutcome(Result<int>.ok(21)).getOrElse(0), equals(42));
      });

      final List<
        ({String description, Result<int> sourceOutcome, int expectedRead})
      >
      mapCases =
          <({String description, Result<int> sourceOutcome, int expectedRead})>[
            (
              description: 'one doubles to two',
              sourceOutcome: Result<int>.ok(1),
              expectedRead: 2,
            ),
            (
              description: 'twenty-one doubles to forty-two',
              sourceOutcome: Result<int>.ok(21),
              expectedRead: 42,
            ),
            (
              description: 'zero doubles to zero',
              sourceOutcome: Result<int>.ok(0),
              expectedRead: 0,
            ),
          ];

      for (final mapCase in mapCases) {
        test(mapCase.description, () {
          expect(
            doubleOutcome(mapCase.sourceOutcome).getOrElse(-1),
            equals(mapCase.expectedRead),
          );
        });
      }

      test('failure carries the cause through untouched', () {
        final Exception rootCause = Exception('offline');
        final Result<int> sourceOutcome = Result<int>.failure(rootCause);
        int transformCalls = 0;
        final Result<int> mappedOutcome = sourceOutcome.mapValue((
          int successValue,
        ) {
          transformCalls += 1;
          return successValue * 2;
        });

        expect(transformCalls, equals(0));
        expect(mappedOutcome.isFailure, isTrue);
        expect(mappedOutcome.getOrElse(-1), equals(-1));
        final Exception carriedCause = switch (mappedOutcome) {
          Ok<int>(value: final heldValue) => throw StateError(
            'expected failure, held $heldValue',
          ),
          Failure<int>(cause: final heldCause) => heldCause,
        };
        expect(carriedCause, same(rootCause));
      });
    });

    group('chains into the next outcome with andThen', () {
      test('ok chains into the next success', () {
        final Result<int> chainedOutcome = Result<int>.ok(21)
            .andThen((int successValue) => Result<int>.ok(successValue + 1));

        expect(chainedOutcome.getOrElse(0), equals(22));
      });

      test('ok chains into a failing next outcome', () {
        final Exception nextCause = Exception('downstream offline');
        final Result<int> chainedOutcome = Result<int>.ok(21)
            .andThen((int successValue) => Result<int>.failure(nextCause));

        expect(chainedOutcome.isFailure, isTrue);
        final Exception carriedCause = switch (chainedOutcome) {
          Ok<int>(value: final heldValue) => throw StateError(
            'expected failure, held $heldValue',
          ),
          Failure<int>(cause: final heldCause) => heldCause,
        };
        expect(carriedCause, same(nextCause));
      });

      test('failure short-circuits without running next', () {
        final Exception rootCause = Exception('offline');
        final Result<int> sourceOutcome = Result<int>.failure(rootCause);
        int nextCalls = 0;
        final Result<int> chainedOutcome = sourceOutcome.andThen((
          int successValue,
        ) {
          nextCalls += 1;
          return Result<int>.ok(successValue);
        });

        expect(nextCalls, equals(0));
        expect(chainedOutcome.isFailure, isTrue);
        final Exception carriedCause = switch (chainedOutcome) {
          Ok<int>(value: final heldValue) => throw StateError(
            'expected failure, held $heldValue',
          ),
          Failure<int>(cause: final heldCause) => heldCause,
        };
        expect(carriedCause, same(rootCause));
      });

      final List<
        ({
          String description,
          Result<int> sourceOutcome,
          int expectedRead,
          bool expectedIsFailure,
        })
      >
      chainCases =
          <
            ({
              String description,
              Result<int> sourceOutcome,
              int expectedRead,
              bool expectedIsFailure,
            })
          >[
            (
              description: 'ok chains into the incremented success',
              sourceOutcome: Result<int>.ok(20),
              expectedRead: 21,
              expectedIsFailure: false,
            ),
            (
              description: 'failure short-circuits the chain',
              sourceOutcome: Result<int>.failure(Exception('offline')),
              expectedRead: -1,
              expectedIsFailure: true,
            ),
          ];

      for (final chainCase in chainCases) {
        test(chainCase.description, () {
          final Result<int> chainedOutcome = chainCase.sourceOutcome.andThen(
            (int successValue) => Result<int>.ok(successValue + 1),
          );

          expect(chainedOutcome.isFailure, equals(chainCase.expectedIsFailure));
          expect(chainedOutcome.getOrElse(-1), equals(chainCase.expectedRead));
        });
      }
    });

    group('never mutates the source outcome', () {
      test('mapValue leaves the source intact', () {
        final Result<int> sourceOutcome = Result<int>.ok(4);

        sourceOutcome.mapValue((int successValue) => successValue + 1);

        expect(sourceOutcome.getOrElse(-1), equals(4));
      });

      test('andThen leaves the source intact', () {
        final Result<int> sourceOutcome = Result<int>.ok(4);

        sourceOutcome.andThen(
          (int successValue) => Result<int>.ok(successValue + 1),
        );

        expect(sourceOutcome.getOrElse(-1), equals(4));
      });

      test('when leaves the source intact', () {
        final Result<int> sourceOutcome = Result<int>.ok(4);

        sourceOutcome.when(
          ok: (int successValue) => successValue + 1,
          failure: (Exception failureCause) => -1,
        );

        expect(sourceOutcome.getOrElse(-1), equals(4));
      });

      test('getOrElse leaves the source intact', () {
        final Result<int> sourceOutcome = Result<int>.failure(
          Exception('offline'),
        );

        sourceOutcome.getOrElse(99);

        expect(sourceOutcome.isFailure, isTrue);
        expect(sourceOutcome.getOrElse(0), equals(0));
      });
    });

    group('documented examples stay runnable', () {
      test('Result.ok example', () {
        final Result<int> outcome = Result<int>.ok(21);
        final int answer = outcome.getOrElse(0);

        expect(answer, equals(21));
      });

      test('Result.failure example', () {
        final Result<int> outcome = Result<int>.failure(Exception('offline'));

        expect(outcome.isFailure, isTrue);
      });

      test('isOk example', () {
        expect(Result<int>.ok(1).isOk, isTrue);
        expect(Result<int>.failure(Exception('offline')).isOk, isFalse);
      });

      test('isFailure example', () {
        expect(Result<int>.failure(Exception('offline')).isFailure, isTrue);
        expect(Result<int>.ok(1).isFailure, isFalse);
      });

      test('when example', () {
        final String label = Result<int>.ok(3).when(
          ok: (int successValue) => 'ok:$successValue',
          failure: (Exception failureCause) => 'failure',
        );

        expect(label, equals('ok:3'));
      });

      test('getOrElse example', () {
        expect(Result<int>.ok(7).getOrElse(0), equals(7));
        expect(
          Result<int>.failure(Exception('offline')).getOrElse(0),
          equals(0),
        );
      });

      test('mapValue example', () {
        final Result<int> doubled = Result<int>.ok(21)
            .mapValue((int successValue) => successValue * 2);

        expect(doubled.getOrElse(0), equals(42));
      });

      test('andThen example', () {
        final Result<int> chained = Result<int>.ok(21)
            .andThen((int successValue) => Result<int>.ok(successValue + 1));

        expect(chained.getOrElse(0), equals(22));
      });

      test('Ok example', () {
        expect(const Ok<int>(21).value, equals(21));
      });

      test('Failure example', () {
        final Exception rootCause = Exception('offline');
        final Failure<int> outcome = Failure<int>(rootCause);

        expect(outcome.isFailure, isTrue);
        expect(outcome.cause, same(rootCause));
      });

      group('equality', () {
        test('ok equals ok with an equal value', () {
          expect(Result<int>.ok(21), equals(Result<int>.ok(21)));
          expect(Result<int>.ok(21) == Result<int>.ok(22), isFalse);
          expect(
            Result<int>.ok(21) == Result<int>.failure(Exception()),
            isFalse,
          );
        });

        test('failure equals failure with the identical cause', () {
          final Exception rootCause = Exception('offline');
          expect(
            Result<int>.failure(rootCause),
            equals(Result<int>.failure(rootCause)),
          );
          expect(
            Result<int>.failure(Exception('a')) ==
                Result<int>.failure(Exception('a')),
            isFalse,
          );
        });

        test('renders sides for debugging', () {
          expect(Result<int>.ok(21).toString(), equals('Ok(21)'));
          expect(
            Result<int>.failure(Exception('offline')).toString(),
            startsWith('Failure('),
          );
        });
      });
    });
  });
}
