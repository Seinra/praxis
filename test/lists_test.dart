import 'package:praxis/src/lists.dart';
import 'package:test/test.dart';

void main() {
  group('findElement', () {
    final List<
      ({
        String label,
        List<int> elements,
        bool Function(int) shouldMatch,
        int? expected,
        bool expectedPresent,
      })
    >
    findCases =
        <
          ({
            String label,
            List<int> elements,
            bool Function(int) shouldMatch,
            int? expected,
            bool expectedPresent,
          })
        >[
          (
            label: 'returns the first match when several qualify',
            elements: <int>[72, 91, 85, 91],
            shouldMatch: (score) => score > 80,
            expected: 91,
            expectedPresent: true,
          ),
          (
            label: 'finds a single matching element',
            elements: <int>[70, 71, 72],
            shouldMatch: (score) => score == 71,
            expected: 71,
            expectedPresent: true,
          ),
          (
            label: 'reports absence when nothing matches',
            elements: <int>[70, 71],
            shouldMatch: (score) => score > 100,
            expected: null,
            expectedPresent: false,
          ),
          (
            label: 'scans negative numbers in order',
            elements: <int>[-5, -2, -9],
            shouldMatch: (score) => score < -4,
            expected: -5,
            expectedPresent: true,
          ),
        ];

    for (final testCase in findCases) {
      test(testCase.label, () {
        final found = findElement<int>(
          List<int>.of(testCase.elements),
          testCase.shouldMatch,
        );
        expect(found.present, equals(testCase.expectedPresent));
        expect(found.value, equals(testCase.expected));
      });
    }

    test('finds words by length', () {
      const List<String> words = <String>['apple', 'fig', 'kiwi'];
      final found = findElement<String>(words, (word) => word.length == 4);
      expect(found.present, isTrue);
      expect(found.value, equals('kiwi'));
    });

    test('returns absence on empty input without calling the predicate', () {
      int calls = 0;
      final found = findElement<int>(<int>[], (score) {
        calls += 1;
        return true;
      });
      expect(found.present, isFalse);
      expect(found.value, isNull);
      expect(calls, equals(0));
    });

    test('distinguishes a found null from absence via the flag', () {
      const List<int?> nullableScores = <int?>[null, 1];
      final hit = findElement<int?>(
        nullableScores,
        (candidate) => candidate == null,
      );
      expect(hit.present, isTrue);
      expect(hit.value, isNull);
      final miss = findElement<int?>(
        nullableScores,
        (candidate) => candidate == 99,
      );
      expect(miss.present, isFalse);
      expect(miss.value, isNull);
    });

    test('leaves the input untouched', () {
      final List<int> scores = <int>[72, 91, 85];
      final List<int> snapshot = List<int>.of(scores);
      findElement<int>(scores, (score) => score > 80);
      expect(scores, equals(snapshot));
    });
  });

  group('minElement', () {
    final List<
      ({String label, List<int> elements, int? expected, bool expectedPresent})
    >
    minCases =
        <
          ({
            String label,
            List<int> elements,
            int? expected,
            bool expectedPresent,
          })
        >[
          (
            label: 'finds the smallest of several',
            elements: <int>[3, 1, 2],
            expected: 1,
            expectedPresent: true,
          ),
          (
            label: 'returns the lone element',
            elements: <int>[7],
            expected: 7,
            expectedPresent: true,
          ),
          (
            label: 'handles negative numbers',
            elements: <int>[-2, -8, -3],
            expected: -8,
            expectedPresent: true,
          ),
          (
            label: 'keeps the first of duplicate minima',
            elements: <int>[4, 2, 2, 5],
            expected: 2,
            expectedPresent: true,
          ),
          (
            label: 'handles descending input',
            elements: <int>[5, 4, 3],
            expected: 3,
            expectedPresent: true,
          ),
        ];

    for (final testCase in minCases) {
      test(testCase.label, () {
        final lowest = minElement<int>(List<int>.of(testCase.elements));
        expect(lowest.present, equals(testCase.expectedPresent));
        expect(lowest.value, equals(testCase.expected));
      });
    }

    test('orders words lexicographically', () {
      const List<String> words = <String>['pear', 'fig', 'kiwi'];
      final lowest = minElement<String>(words);
      expect(lowest.present, isTrue);
      expect(lowest.value, equals('fig'));
    });

    test('returns absence on empty input', () {
      final lowest = minElement<int>(<int>[]);
      expect(lowest.present, isFalse);
      expect(lowest.value, isNull);
    });

    test('leaves the input untouched', () {
      final List<int> scores = <int>[3, 1, 2];
      final List<int> snapshot = List<int>.of(scores);
      minElement<int>(scores);
      expect(scores, equals(snapshot));
    });
  });

  group('maxElement', () {
    final List<
      ({String label, List<int> elements, int? expected, bool expectedPresent})
    >
    maxCases =
        <
          ({
            String label,
            List<int> elements,
            int? expected,
            bool expectedPresent,
          })
        >[
          (
            label: 'finds the largest of several',
            elements: <int>[3, 1, 2],
            expected: 3,
            expectedPresent: true,
          ),
          (
            label: 'returns the lone element',
            elements: <int>[7],
            expected: 7,
            expectedPresent: true,
          ),
          (
            label: 'handles negative numbers',
            elements: <int>[-2, -8, -3],
            expected: -2,
            expectedPresent: true,
          ),
          (
            label: 'keeps the first of duplicate maxima',
            elements: <int>[4, 5, 5, 1],
            expected: 5,
            expectedPresent: true,
          ),
          (
            label: 'handles ascending input',
            elements: <int>[1, 2, 3],
            expected: 3,
            expectedPresent: true,
          ),
        ];

    for (final testCase in maxCases) {
      test(testCase.label, () {
        final highest = maxElement<int>(List<int>.of(testCase.elements));
        expect(highest.present, equals(testCase.expectedPresent));
        expect(highest.value, equals(testCase.expected));
      });
    }

    test('orders words lexicographically', () {
      const List<String> words = <String>['fig', 'pear', 'kiwi'];
      final highest = maxElement<String>(words);
      expect(highest.present, isTrue);
      expect(highest.value, equals('pear'));
    });

    test('returns absence on empty input', () {
      final highest = maxElement<int>(<int>[]);
      expect(highest.present, isFalse);
      expect(highest.value, isNull);
    });

    test('leaves the input untouched', () {
      final List<int> scores = <int>[3, 1, 2];
      final List<int> snapshot = List<int>.of(scores);
      maxElement<int>(scores);
      expect(scores, equals(snapshot));
    });
  });

  group('chunkElements', () {
    final List<
      ({
        String label,
        List<int> elements,
        int chunkSize,
        List<List<int>> expected,
      })
    >
    chunkCases =
        <
          ({
            String label,
            List<int> elements,
            int chunkSize,
            List<List<int>> expected,
          })
        >[
          (
            label: 'splits evenly sized input',
            elements: <int>[1, 2, 3, 4],
            chunkSize: 2,
            expected: <List<int>>[
              <int>[1, 2],
              <int>[3, 4],
            ],
          ),
          (
            label: 'leaves a short final chunk',
            elements: <int>[1, 2, 3, 4, 5],
            chunkSize: 2,
            expected: <List<int>>[
              <int>[1, 2],
              <int>[3, 4],
              <int>[5],
            ],
          ),
          (
            label: 'yields one chunk when the size covers the input',
            elements: <int>[1, 2],
            chunkSize: 5,
            expected: <List<int>>[
              <int>[1, 2],
            ],
          ),
          (
            label: 'yields singletons when the size is one',
            elements: <int>[1, 2, 3],
            chunkSize: 1,
            expected: <List<int>>[
              <int>[1],
              <int>[2],
              <int>[3],
            ],
          ),
        ];

    for (final testCase in chunkCases) {
      test(testCase.label, () {
        final chunks = chunkElements<int>(
          List<int>.of(testCase.elements),
          testCase.chunkSize,
        );
        expect(chunks, equals(testCase.expected));
      });
    }

    test('chunks words as fresh lists', () {
      const List<String> words = <String>['a', 'b', 'c'];
      final chunks = chunkElements<String>(words, 2);
      expect(
        chunks,
        equals(<List<String>>[
          <String>['a', 'b'],
          <String>['c'],
        ]),
      );
    });

    test('returns an empty list for empty input', () {
      final chunks = chunkElements<int>(<int>[], 2);
      expect(chunks, isEmpty);
    });

    test('rejects a non-positive chunk size', () {
      expect(() => chunkElements<int>(<int>[1, 2], 0), throwsArgumentError);
      expect(() => chunkElements<int>(<int>[1, 2], -2), throwsArgumentError);
    });

    test('returns fresh chunks and leaves the input untouched', () {
      final List<int> scores = <int>[1, 2, 3];
      final List<int> snapshot = List<int>.of(scores);
      final chunks = chunkElements<int>(scores, 2);
      expect(chunks, isNot(same(scores)));
      chunks[0].add(99);
      expect(scores, equals(snapshot));
      expect(
        chunks,
        equals(<List<int>>[
          <int>[1, 2, 99],
          <int>[3],
        ]),
      );
    });
  });

  group('partitionElements', () {
    final List<
      ({
        String label,
        List<int> elements,
        List<int> expectedMatching,
        List<int> expectedRest,
      })
    >
    partitionCases =
        <
          ({
            String label,
            List<int> elements,
            List<int> expectedMatching,
            List<int> expectedRest,
          })
        >[
          (
            label: 'splits mixed input preserving order',
            elements: <int>[1, 2, 3, 4],
            expectedMatching: <int>[2, 4],
            expectedRest: <int>[1, 3],
          ),
          (
            label: 'keeps encounter order on shuffled input',
            elements: <int>[4, 1, 3, 2],
            expectedMatching: <int>[4, 2],
            expectedRest: <int>[1, 3],
          ),
          (
            label: 'yields empty rest when everything matches',
            elements: <int>[2, 4],
            expectedMatching: <int>[2, 4],
            expectedRest: <int>[],
          ),
          (
            label: 'yields empty matching when nothing matches',
            elements: <int>[1, 3],
            expectedMatching: <int>[],
            expectedRest: <int>[1, 3],
          ),
        ];

    for (final testCase in partitionCases) {
      test(testCase.label, () {
        final split = partitionElements<int>(
          List<int>.of(testCase.elements),
          (number) => number.isEven,
        );
        expect(split.matching, equals(testCase.expectedMatching));
        expect(split.rest, equals(testCase.expectedRest));
      });
    }

    test('partitions words by length', () {
      const List<String> words = <String>['fig', 'pear', 'kiwi', 'plum'];
      final split = partitionElements<String>(
        words,
        (word) => word.length == 4,
      );
      expect(split.matching, equals(<String>['pear', 'kiwi', 'plum']));
      expect(split.rest, equals(<String>['fig']));
    });

    test('returns two empty lists on empty input', () {
      int calls = 0;
      final split = partitionElements<int>(<int>[], (number) {
        calls += 1;
        return true;
      });
      expect(split.matching, isEmpty);
      expect(split.rest, isEmpty);
      expect(calls, equals(0));
    });

    test('returns fresh lists and leaves the input untouched', () {
      final List<int> scores = <int>[1, 2, 3, 4];
      final List<int> snapshot = List<int>.of(scores);
      final split = partitionElements<int>(scores, (number) => number.isEven);
      expect(split.matching, isNot(same(scores)));
      expect(split.rest, isNot(same(scores)));
      split.matching.add(99);
      split.rest.add(100);
      expect(scores, equals(snapshot));
    });
  });

  group('documented examples', () {
    test('findElement example prints the first score above 80', () {
      final List<int> scores = <int>[72, 91, 85];
      final found = findElement(scores, (score) => score > 80);
      expect(found.present, isTrue);
      expect(found.value, equals(91));
    });

    test('minElement example prints 1', () {
      final lowest = minElement(<int>[3, 1, 2]);
      expect(lowest.present, isTrue);
      expect(lowest.value, equals(1));
    });

    test('maxElement example prints pear', () {
      final highest = maxElement(<String>['fig', 'pear', 'kiwi']);
      expect(highest.present, isTrue);
      expect(highest.value, equals('pear'));
    });

    test('chunkElements example groups five scores by two', () {
      final chunks = chunkElements(<int>[1, 2, 3, 4, 5], 2);
      expect(
        chunks,
        equals(<List<int>>[
          <int>[1, 2],
          <int>[3, 4],
          <int>[5],
        ]),
      );
    });

    test('partitionElements example splits evens from odds', () {
      final split = partitionElements(<int>[
        1,
        2,
        3,
        4,
      ], (number) => number.isEven);
      expect(split.matching, equals(<int>[2, 4]));
      expect(split.rest, equals(<int>[1, 3]));
    });
  });
}
