import 'package:praxis/src/either.dart';
import 'package:praxis/src/result.dart';
import 'package:test/test.dart';

String renderLocked(String lockReason) => 'locked: $lockReason';

String renderReady(int slotCount) => 'ready: $slotCount slots';

int doubleSlots(int slotCount) => slotCount * 2;

String shoutReason(String lockReason) => 'LEFT:$lockReason';

void main() {
  group('Either', () {
    group('constructs each side', () {
      test('left holds the first side', () {
        final Either<String, int> locked = Either<String, int>.left(
          'season pass missing',
        );

        expect(locked.isLeft, isTrue);
        expect(locked.isRight, isFalse);
        expect(
          locked.when(onLeft: renderLocked, onRight: renderReady),
          equals('locked: season pass missing'),
        );
      });

      test('right holds the second side', () {
        final Either<String, int> granted = Either<String, int>.right(7);

        expect(granted.isRight, isTrue);
        expect(granted.isLeft, isFalse);
        expect(
          granted.when(onLeft: renderLocked, onRight: renderReady),
          equals('ready: 7 slots'),
        );
      });

      test('holds two values of the same type on different sides', () {
        final Either<String, String> locked = Either<String, String>.left(
          'season pass missing',
        );
        final Either<String, String> granted = Either<String, String>.right(
          'Frozen Depths',
        );

        String describePack(Either<String, String> packOutcome) {
          return packOutcome.when(
            onLeft: (String lockReason) => 'locked: $lockReason',
            onRight: (String packTitle) => 'ready: $packTitle',
          );
        }

        expect(describePack(locked), equals('locked: season pass missing'));
        expect(describePack(granted), equals('ready: Frozen Depths'));
      });
    });

    group('asks the side', () {
      final List<
        ({
          String description,
          Either<String, int> outcome,
          bool expectedIsLeft,
          bool expectedIsRight,
        })
      >
      sideCases =
          <
            ({
              String description,
              Either<String, int> outcome,
              bool expectedIsLeft,
              bool expectedIsRight,
            })
          >[
            (
              description: 'left reports the first side',
              outcome: Either<String, int>.left('season pass missing'),
              expectedIsLeft: true,
              expectedIsRight: false,
            ),
            (
              description: 'right reports the second side',
              outcome: Either<String, int>.right(7),
              expectedIsLeft: false,
              expectedIsRight: true,
            ),
          ];

      for (final sideCase in sideCases) {
        test(sideCase.description, () {
          expect(sideCase.outcome.isLeft, equals(sideCase.expectedIsLeft));
          expect(sideCase.outcome.isRight, equals(sideCase.expectedIsRight));
        });
      }
    });

    group('splits explicitly with when', () {
      String describeOutcome(Either<String, int> outcome) {
        return outcome.when(onLeft: renderLocked, onRight: renderReady);
      }

      test('left takes the first branch', () {
        expect(
          describeOutcome(Either<String, int>.left('season pass missing')),
          equals('locked: season pass missing'),
        );
      });

      test('right takes the second branch', () {
        expect(
          describeOutcome(Either<String, int>.right(7)),
          equals('ready: 7 slots'),
        );
      });

      final List<
        ({String description, Either<String, int> outcome, String expected})
      >
      splitCases =
          <
            ({String description, Either<String, int> outcome, String expected})
          >[
            (
              description: 'locked reason splits to its label',
              outcome: Either<String, int>.left('locked'),
              expected: 'locked: locked',
            ),
            (
              description: 'seven slots splits to its label',
              outcome: Either<String, int>.right(7),
              expected: 'ready: 7 slots',
            ),
            (
              description: 'zero slots splits to its label',
              outcome: Either<String, int>.right(0),
              expected: 'ready: 0 slots',
            ),
          ];

      for (final splitCase in splitCases) {
        test(splitCase.description, () {
          expect(
            describeOutcome(splitCase.outcome),
            equals(splitCase.expected),
          );
        });
      }
    });

    group('transforms the second side with mapRight', () {
      Either<String, int> doubleGranted(Either<String, int> outcome) {
        return outcome.mapRight(doubleSlots);
      }

      test('right maps the second value', () {
        final Either<String, int> mapped = doubleGranted(
          Either<String, int>.right(21),
        );

        expect(mapped.isRight, isTrue);
        expect(
          mapped.when(
            onLeft: (String lockReason) => -1,
            onRight: (int slotCount) => slotCount,
          ),
          equals(42),
        );
      });

      final List<
        ({
          String description,
          Either<String, int> sourceOutcome,
          String expectedLabel,
          bool expectedIsLeft,
        })
      >
      mapCases =
          <
            ({
              String description,
              Either<String, int> sourceOutcome,
              String expectedLabel,
              bool expectedIsLeft,
            })
          >[
            (
              description: 'twenty-one slots double to forty-two',
              sourceOutcome: Either<String, int>.right(21),
              expectedLabel: 'ready: 42 slots',
              expectedIsLeft: false,
            ),
            (
              description: 'zero slots double to zero',
              sourceOutcome: Either<String, int>.right(0),
              expectedLabel: 'ready: 0 slots',
              expectedIsLeft: false,
            ),
            (
              description: 'locked reason carries through untouched',
              sourceOutcome: Either<String, int>.left('locked'),
              expectedLabel: 'locked: locked',
              expectedIsLeft: true,
            ),
          ];

      for (final mapCase in mapCases) {
        test(mapCase.description, () {
          final Either<String, int> mapped = doubleGranted(
            mapCase.sourceOutcome,
          );

          expect(mapped.isLeft, equals(mapCase.expectedIsLeft));
          expect(
            mapped.when(onLeft: renderLocked, onRight: renderReady),
            equals(mapCase.expectedLabel),
          );
        });
      }

      test('left carries through without running transform', () {
        final Either<String, int> sourceOutcome = Either<String, int>.left(
          'locked',
        );
        int transformCalls = 0;
        final Either<String, String> mappedOutcome = sourceOutcome.mapRight((
          int slotCount,
        ) {
          transformCalls += 1;
          return 'slots:$slotCount';
        });

        expect(transformCalls, equals(0));
        expect(mappedOutcome.isLeft, isTrue);
        expect(
          mappedOutcome.when(
            onLeft: (String lockReason) => lockReason,
            onRight: (String label) => label,
          ),
          equals('locked'),
        );
      });
    });

    group('transforms the first side with mapLeft', () {
      Either<String, int> shoutLocked(Either<String, int> outcome) {
        return outcome.mapLeft(shoutReason);
      }

      test('left maps the first value', () {
        final Either<String, int> mapped = shoutLocked(
          Either<String, int>.left('locked'),
        );

        expect(mapped.isLeft, isTrue);
        expect(
          mapped.when(
            onLeft: (String lockReason) => lockReason,
            onRight: (int slotCount) => 'unexpected',
          ),
          equals('LEFT:locked'),
        );
      });

      final List<
        ({
          String description,
          Either<String, int> sourceOutcome,
          String expectedLabel,
          bool expectedIsRight,
        })
      >
      mapCases =
          <
            ({
              String description,
              Either<String, int> sourceOutcome,
              String expectedLabel,
              bool expectedIsRight,
            })
          >[
            (
              description: 'locked reason maps to its shout',
              sourceOutcome: Either<String, int>.left('locked'),
              expectedLabel: 'LEFT:locked',
              expectedIsRight: false,
            ),
            (
              description: 'nine slots carry through untouched',
              sourceOutcome: Either<String, int>.right(9),
              expectedLabel: 'ready: 9 slots',
              expectedIsRight: true,
            ),
          ];

      for (final mapCase in mapCases) {
        test(mapCase.description, () {
          final Either<String, int> mapped = shoutLocked(mapCase.sourceOutcome);

          expect(mapped.isRight, equals(mapCase.expectedIsRight));
          expect(
            mapped.when(
              onLeft: (String lockReason) => lockReason,
              onRight: renderReady,
            ),
            equals(mapCase.expectedLabel),
          );
        });
      }

      test('right carries through without running transform', () {
        final Either<String, int> sourceOutcome = Either<String, int>.right(5);
        int transformCalls = 0;
        final Either<String, int> mappedOutcome = sourceOutcome.mapLeft((
          String lockReason,
        ) {
          transformCalls += 1;
          return 'unreachable:$lockReason';
        });

        expect(transformCalls, equals(0));
        expect(mappedOutcome.isRight, isTrue);
        expect(
          mappedOutcome.when(onLeft: renderLocked, onRight: renderReady),
          equals('ready: 5 slots'),
        );
      });
    });

    group('exchanges the sides with swap', () {
      test('left becomes a right holding the same payload', () {
        final Either<int, String> swapped = Either<String, int>.left('locked')
            .swap();

        expect(swapped.isRight, isTrue);
        expect(
          swapped.when(
            onLeft: (int slotCount) => 'unexpected',
            onRight: (String lockReason) => lockReason,
          ),
          equals('locked'),
        );
      });

      test('right becomes a left holding the same payload', () {
        final Either<int, String> swapped = Either<String, int>.right(3).swap();

        expect(swapped.isLeft, isTrue);
        expect(
          swapped.when(
            onLeft: (int slotCount) => 'slots:$slotCount',
            onRight: (String lockReason) => 'unexpected',
          ),
          equals('slots:3'),
        );
      });

      final List<({String description, Either<String, int> sourceOutcome})>
      roundTripCases =
          <({String description, Either<String, int> sourceOutcome})>[
            (
              description: 'left survives a double swap',
              sourceOutcome: Either<String, int>.left('locked'),
            ),
            (
              description: 'right survives a double swap',
              sourceOutcome: Either<String, int>.right(11),
            ),
          ];

      for (final roundTripCase in roundTripCases) {
        test(roundTripCase.description, () {
          final Either<String, int> roundTripped = roundTripCase.sourceOutcome
              .swap()
              .swap();

          expect(
            roundTripped.when(onLeft: renderLocked, onRight: renderReady),
            equals(
              roundTripCase.sourceOutcome.when(
                onLeft: renderLocked,
                onRight: renderReady,
              ),
            ),
          );
          expect(
            roundTripped.isLeft,
            equals(roundTripCase.sourceOutcome.isLeft),
          );
        });
      }
    });

    group('bridges into Result with toResult', () {
      Result<int> bridgeOutcome(Either<String, int> outcome) {
        return outcome.toResult((String lockReason) => Exception(lockReason));
      }

      test('right becomes a success holding the value', () {
        final Result<int> converted = bridgeOutcome(
          Either<String, int>.right(42),
        );

        expect(converted.isOk, isTrue);
        expect(converted.getOrElse(-1), equals(42));
      });

      test('left becomes a failure holding the mapped cause', () {
        final Result<int> converted = bridgeOutcome(
          Either<String, int>.left('season pass missing'),
        );

        expect(converted.isFailure, isTrue);
        expect(converted.getOrElse(-1), equals(-1));
      });

      test('left carries the sentinel cause by identity', () {
        final Exception sentinelCause = Exception('locked');
        final Result<int> converted = Either<String, int>.left('any reason')
            .toResult((String lockReason) => sentinelCause);

        expect(converted.isFailure, isTrue);
        final Exception carriedCause = switch (converted) {
          Ok<int>(value: final heldValue) => throw StateError(
            'expected failure, held $heldValue',
          ),
          Failure<int>(cause: final heldCause) => heldCause,
        };
        expect(carriedCause, same(sentinelCause));
      });

      test('right never runs failureOf', () {
        bool failureOfCalls = false;
        final Result<int> converted = Either<String, int>.right(8)
            .toResult((String lockReason) {
              failureOfCalls = true;
              return Exception(lockReason);
            });

        expect(failureOfCalls, isFalse);
        expect(converted.isOk, isTrue);
        expect(converted.getOrElse(-1), equals(8));
      });
    });

    group('keeps null payloads typed', () {
      test('left holding null still reports the first side', () {
        final Either<String?, int> outcome = Either<String?, int>.left(null);

        expect(outcome.isLeft, isTrue);
        expect(outcome.isRight, isFalse);
        expect(
          outcome.when(
            onLeft: (String? lockReason) =>
                lockReason == null ? 'no reason' : 'has reason',
            onRight: (int slotCount) => 'slots:$slotCount',
          ),
          equals('no reason'),
        );
      });

      test('right holding null still reports the second side', () {
        final Either<String, int?> outcome = Either<String, int?>.right(null);

        expect(outcome.isRight, isTrue);
        expect(outcome.isLeft, isFalse);
        expect(
          outcome.when(
            onLeft: renderLocked,
            onRight: (int? slotCount) =>
                slotCount == null ? 'no slots' : 'has slots',
          ),
          equals('no slots'),
        );
      });
    });

    group('never mutates the source outcome', () {
      test('mapRight leaves the source intact', () {
        final Either<String, int> sourceOutcome = Either<String, int>.right(4);

        sourceOutcome.mapRight((int slotCount) => slotCount + 1);

        expect(
          sourceOutcome.when(onLeft: renderLocked, onRight: renderReady),
          equals('ready: 4 slots'),
        );
      });

      test('mapLeft leaves the source intact', () {
        final Either<String, int> sourceOutcome = Either<String, int>.left(
          'locked',
        );

        sourceOutcome.mapLeft((String lockReason) => 'changed:$lockReason');

        expect(
          sourceOutcome.when(onLeft: renderLocked, onRight: renderReady),
          equals('locked: locked'),
        );
      });

      test('swap leaves the source intact', () {
        final Either<String, int> sourceOutcome = Either<String, int>.left(
          'locked',
        );

        sourceOutcome.swap();

        expect(sourceOutcome.isLeft, isTrue);
      });

      test('when leaves the source intact', () {
        final Either<String, int> sourceOutcome = Either<String, int>.right(4);

        sourceOutcome.when(onLeft: renderLocked, onRight: renderReady);

        expect(
          sourceOutcome.when(onLeft: renderLocked, onRight: renderReady),
          equals('ready: 4 slots'),
        );
      });

      test('toResult leaves the source intact', () {
        final Either<String, int> sourceOutcome = Either<String, int>.right(4);

        sourceOutcome.toResult((String lockReason) => Exception(lockReason));

        expect(sourceOutcome.isRight, isTrue);
      });
    });

    group('documented examples stay runnable', () {
      test('Either example', () {
        final Either<String, String> granted = Either<String, String>.right(
          'Frozen Depths',
        );
        final String label = granted.when(
          onLeft: (String lockReason) => 'locked: $lockReason',
          onRight: (String packTitle) => 'ready: $packTitle',
        );

        expect(label, equals('ready: Frozen Depths'));
      });

      test('Either.left example', () {
        final Either<String, int> locked = Either<String, int>.left(
          'season pass missing',
        );

        expect(locked.isLeft, isTrue);
      });

      test('Either.right example', () {
        final Either<String, int> granted = Either<String, int>.right(7);

        expect(granted.isRight, isTrue);
      });

      test('isLeft example', () {
        expect(Either<String, int>.left('season pass missing').isLeft, isTrue);
        expect(Either<String, int>.right(7).isLeft, isFalse);
      });

      test('isRight example', () {
        expect(Either<String, int>.right(7).isRight, isTrue);
        expect(
          Either<String, int>.left('season pass missing').isRight,
          isFalse,
        );
      });

      test('when example', () {
        final String label = Either<String, int>.right(7).when(
          onLeft: (String lockReason) => 'locked: $lockReason',
          onRight: (int slotCount) => 'ready: $slotCount slots',
        );

        expect(label, equals('ready: 7 slots'));
      });

      test('mapRight example', () {
        final Either<String, int> granted = Either<String, int>.right(21)
            .mapRight((int slotCount) => slotCount * 2);

        expect(
          granted.when(
            onLeft: (String lockReason) => -1,
            onRight: (int slotCount) => slotCount,
          ),
          equals(42),
        );
      });

      test('mapLeft example', () {
        final Either<String, int> locked = Either<String, int>.left('locked')
            .mapLeft((String lockReason) => 'LEFT:$lockReason');

        expect(
          locked.when(
            onLeft: (String lockReason) => lockReason,
            onRight: (int slotCount) => 'unexpected',
          ),
          equals('LEFT:locked'),
        );
      });

      test('swap example', () {
        final Either<int, String> swapped = Either<String, int>.left('locked')
            .swap();

        expect(swapped.isRight, isTrue);
      });

      test('toResult example', () {
        final Result<int> outcome = Either<String, int>.right(7)
            .toResult((String lockReason) => Exception(lockReason));

        expect(outcome.getOrElse(0), equals(7));
      });

      test('Left example', () {
        expect(
          const Left<String, int>('season pass missing').leftValue,
          equals('season pass missing'),
        );
      });

      test('Right example', () {
        expect(const Right<String, int>(7).rightValue, equals(7));
      });
    });

    group('equality', () {
      test('left equals left with an equal payload', () {
        expect(
          Either<String, int>.left('locked'),
          equals(Either<String, int>.left('locked')),
        );
        expect(
          Either<String, int>.left('locked') ==
              Either<String, int>.left('other'),
          isFalse,
        );
        expect(
          Either<String, int>.left('locked') == Either<String, int>.right(7),
          isFalse,
        );
      });

      test('right equals right with an equal payload', () {
        expect(
          Either<String, int>.right(7),
          equals(Either<String, int>.right(7)),
        );
        expect(
          Either<String, int>.right(7) == Either<String, int>.right(8),
          isFalse,
        );
        expect(
          Either<String, int>.right(7) == Either<String, int>.left('locked'),
          isFalse,
        );
      });

      test('equal sides share hash codes', () {
        expect(
          Either<String, int>.left('locked').hashCode,
          equals(Either<String, int>.left('locked').hashCode),
        );
        expect(
          Either<String, int>.right(7).hashCode,
          equals(Either<String, int>.right(7).hashCode),
        );
      });

      test('renders sides for debugging', () {
        expect(
          Either<String, int>.left('locked').toString(),
          equals('Left(locked)'),
        );
        expect(Either<String, int>.right(7).toString(), equals('Right(7)'));
      });
    });
  });
}
