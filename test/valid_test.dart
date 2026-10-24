import 'package:praxis/src/valid.dart';
import 'package:test/test.dart';

bool isEvenNumber(int candidate) => candidate.isEven;

bool isPositiveNumber(int candidate) => candidate > 0;

void main() {
  group('andPredicates', () {
    final List<
      ({
        String label,
        List<Predicate<int>> predicates,
        int candidate,
        bool expected,
      })
    >
    andCases =
        <
          ({
            String label,
            List<Predicate<int>> predicates,
            int candidate,
            bool expected,
          })
        >[
          (
            label: 'holds when every leg holds',
            predicates: <Predicate<int>>[isEvenNumber, isPositiveNumber],
            candidate: 4,
            expected: true,
          ),
          (
            label: 'fails when the last leg fails',
            predicates: <Predicate<int>>[isEvenNumber, isPositiveNumber],
            candidate: -4,
            expected: false,
          ),
          (
            label: 'fails when the first leg fails',
            predicates: <Predicate<int>>[isPositiveNumber, isEvenNumber],
            candidate: -3,
            expected: false,
          ),
          (
            label: 'holds for a single holding leg',
            predicates: <Predicate<int>>[isEvenNumber],
            candidate: 8,
            expected: true,
          ),
        ];

    for (final testCase in andCases) {
      test(testCase.label, () {
        final Predicate<int> combined = andPredicates<int>(
          List<Predicate<int>>.of(testCase.predicates),
        );
        expect(combined(testCase.candidate), equals(testCase.expected));
      });
    }

    test('holds vacuously on empty input', () {
      final Predicate<int> combined = andPredicates<int>(<Predicate<int>>[]);
      expect(combined(7), isTrue);
    });

    test('stops at the first failing leg in left-to-right order', () {
      final List<String> runningOrder = <String>[];
      final Predicate<int> combined = andPredicates<int>(<Predicate<int>>[
        (candidate) {
          runningOrder.add('firstLeg');
          return false;
        },
        (candidate) {
          runningOrder.add('secondLeg');
          return true;
        },
      ]);
      expect(combined(4), isFalse);
      expect(runningOrder, equals(<String>['firstLeg']));
    });

    test('leaves the predicates list untouched', () {
      final List<Predicate<int>> predicates = <Predicate<int>>[
        isEvenNumber,
        isPositiveNumber,
      ];
      final int originalLength = predicates.length;
      andPredicates<int>(predicates)(4);
      expect(predicates.length, equals(originalLength));
    });
  });

  group('orPredicates', () {
    final List<
      ({
        String label,
        List<Predicate<int>> predicates,
        int candidate,
        bool expected,
      })
    >
    orCases =
        <
          ({
            String label,
            List<Predicate<int>> predicates,
            int candidate,
            bool expected,
          })
        >[
          (
            label: 'holds when the first leg holds',
            predicates: <Predicate<int>>[isEvenNumber, isPositiveNumber],
            candidate: 4,
            expected: true,
          ),
          (
            label: 'holds when only the last leg holds',
            predicates: <Predicate<int>>[isEvenNumber, isPositiveNumber],
            candidate: 3,
            expected: true,
          ),
          (
            label: 'fails when every leg fails',
            predicates: <Predicate<int>>[isEvenNumber, isPositiveNumber],
            candidate: -3,
            expected: false,
          ),
          (
            label: 'fails for a single failing leg',
            predicates: <Predicate<int>>[isEvenNumber],
            candidate: 7,
            expected: false,
          ),
        ];

    for (final testCase in orCases) {
      test(testCase.label, () {
        final Predicate<int> combined = orPredicates<int>(
          List<Predicate<int>>.of(testCase.predicates),
        );
        expect(combined(testCase.candidate), equals(testCase.expected));
      });
    }

    test('fails vacuously on empty input', () {
      final Predicate<int> combined = orPredicates<int>(<Predicate<int>>[]);
      expect(combined(4), isFalse);
    });

    test('stops at the first holding leg in left-to-right order', () {
      final List<String> runningOrder = <String>[];
      final Predicate<int> combined = orPredicates<int>(<Predicate<int>>[
        (candidate) {
          runningOrder.add('firstLeg');
          return true;
        },
        (candidate) {
          runningOrder.add('secondLeg');
          return true;
        },
      ]);
      expect(combined(3), isTrue);
      expect(runningOrder, equals(<String>['firstLeg']));
    });

    test('leaves the predicates list untouched', () {
      final List<Predicate<int>> predicates = <Predicate<int>>[
        isEvenNumber,
        isPositiveNumber,
      ];
      final int originalLength = predicates.length;
      orPredicates<int>(predicates)(3);
      expect(predicates.length, equals(originalLength));
    });
  });

  group('notPredicate', () {
    test('negates a holding predicate', () {
      expect(notPredicate<int>(isEvenNumber)(4), isFalse);
    });

    test('negates a failing predicate', () {
      expect(notPredicate<int>(isEvenNumber)(3), isTrue);
    });

    test('answers the same on every call', () {
      final Predicate<int> negated = notPredicate<int>(isPositiveNumber);
      expect(negated(-2), isTrue);
      expect(negated(-2), isTrue);
      expect(negated(2), isFalse);
    });
  });

  group('composition', () {
    test('nests andPredicates inside orPredicates', () {
      final Predicate<int> isPositiveEven = andPredicates<int>(<Predicate<int>>[
        isPositiveNumber,
        isEvenNumber,
      ]);
      final Predicate<int> isPositiveEvenOrZero = orPredicates<int>(
        <Predicate<int>>[isPositiveEven, (candidate) => candidate == 0],
      );
      expect(isPositiveEvenOrZero(4), isTrue);
      expect(isPositiveEvenOrZero(0), isTrue);
      expect(isPositiveEvenOrZero(3), isFalse);
      expect(isPositiveEvenOrZero(-4), isFalse);
    });

    test('negates a combined predicate', () {
      final Predicate<int> isNeitherPositiveNorEven = notPredicate<int>(
        orPredicates<int>(<Predicate<int>>[isPositiveNumber, isEvenNumber]),
      );
      expect(isNeitherPositiveNorEven(-3), isTrue);
      expect(isNeitherPositiveNorEven(3), isFalse);
      expect(isNeitherPositiveNorEven(-4), isFalse);
    });

    test('double negation restores the original check', () {
      final Predicate<int> restored = notPredicate<int>(
        notPredicate<int>(isEvenNumber),
      );
      expect(restored(4), isTrue);
      expect(restored(3), isFalse);
    });

    test('runs the second andPredicates leg when the first holds', () {
      int calls = 0;
      final Predicate<int> combined = andPredicates<int>(<Predicate<int>>[
        (candidate) => true,
        (candidate) {
          calls += 1;
          return candidate.isEven;
        },
      ]);
      expect(combined(4), isTrue);
      expect(calls, equals(1));
    });

    test('runs the second orPredicates leg when the first fails', () {
      int calls = 0;
      final Predicate<int> combined = orPredicates<int>(<Predicate<int>>[
        (candidate) => false,
        (candidate) {
          calls += 1;
          return candidate.isEven;
        },
      ]);
      expect(combined(4), isTrue);
      expect(calls, equals(1));
    });

    test('composes predicates over non-integer candidates', () {
      final Predicate<String> isLongGreeting = andPredicates<String>(
        <Predicate<String>>[
          (candidate) => candidate.startsWith('hello'),
          (candidate) => candidate.length > 8,
        ],
      );
      expect(isLongGreeting('hello, world'), isTrue);
      expect(isLongGreeting('hello'), isFalse);
      expect(isLongGreeting('goodbye, world'), isFalse);
    });

    test('answers the same on repeated calls', () {
      final Predicate<int> combined = andPredicates<int>(<Predicate<int>>[
        isPositiveNumber,
        isEvenNumber,
      ]);
      expect(combined(4), isTrue);
      expect(combined(4), isTrue);
      expect(combined(-3), isFalse);
      expect(combined(-3), isFalse);
    });
  });

  group('alwaysTrue', () {
    test('holds for any candidate', () {
      expect(alwaysTrue<int>(0), isTrue);
      expect(alwaysTrue<String>('anything'), isTrue);
    });

    test('acts as the identity element of andPredicates', () {
      final Predicate<int> combined = andPredicates<int>(<Predicate<int>>[
        alwaysTrue,
        isEvenNumber,
      ]);
      expect(combined(4), isTrue);
      expect(combined(3), isFalse);
    });
  });

  group('alwaysFalse', () {
    test('fails for any candidate', () {
      expect(alwaysFalse<int>(0), isFalse);
      expect(alwaysFalse<String>('anything'), isFalse);
    });

    test('acts as the identity element of orPredicates', () {
      final Predicate<int> combined = orPredicates<int>(<Predicate<int>>[
        alwaysFalse,
        isEvenNumber,
      ]);
      expect(combined(4), isTrue);
      expect(combined(3), isFalse);
    });
  });
}
