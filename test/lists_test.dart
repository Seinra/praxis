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

  group('firstElement', () {
    final List<
      ({String label, List<int> elements, int? expected, bool expectedPresent})
    >
    firstCases =
        <
          ({
            String label,
            List<int> elements,
            int? expected,
            bool expectedPresent,
          })
        >[
          (
            label: 'returns the first of several',
            elements: <int>[72, 91, 85],
            expected: 72,
            expectedPresent: true,
          ),
          (
            label: 'returns the lone element',
            elements: <int>[7],
            expected: 7,
            expectedPresent: true,
          ),
          (
            label: 'returns the head of descending input',
            elements: <int>[5, 4, 3],
            expected: 5,
            expectedPresent: true,
          ),
          (
            label: 'returns the head when duplicates follow',
            elements: <int>[4, 2, 2, 5],
            expected: 4,
            expectedPresent: true,
          ),
          (
            label: 'handles negative numbers',
            elements: <int>[-5, -2, -9],
            expected: -5,
            expectedPresent: true,
          ),
        ];

    for (final testCase in firstCases) {
      test(testCase.label, () {
        final first = firstElement<int>(List<int>.of(testCase.elements));
        expect(first.present, equals(testCase.expectedPresent));
        expect(first.value, equals(testCase.expected));
      });
    }

    test('returns the first word', () {
      const List<String> words = <String>['apple', 'fig', 'kiwi'];
      final first = firstElement<String>(words);
      expect(first.present, isTrue);
      expect(first.value, equals('apple'));
    });

    test('returns absence on empty input', () {
      final first = firstElement<int>(<int>[]);
      expect(first.present, isFalse);
      expect(first.value, isNull);
    });

    test('distinguishes a stored null head from absence via the flag', () {
      const List<int?> nullableScores = <int?>[null, 1];
      final hit = firstElement<int?>(nullableScores);
      expect(hit.present, isTrue);
      expect(hit.value, isNull);
      final miss = firstElement<int?>(<int?>[]);
      expect(miss.present, isFalse);
      expect(miss.value, isNull);
    });

    test('leaves the input untouched', () {
      final List<int> scores = <int>[72, 91, 85];
      final List<int> snapshot = List<int>.of(scores);
      firstElement<int>(scores);
      expect(scores, equals(snapshot));
    });
  });

  group('lastElement', () {
    final List<
      ({String label, List<int> elements, int? expected, bool expectedPresent})
    >
    lastCases =
        <
          ({
            String label,
            List<int> elements,
            int? expected,
            bool expectedPresent,
          })
        >[
          (
            label: 'returns the last of several',
            elements: <int>[72, 91, 85],
            expected: 85,
            expectedPresent: true,
          ),
          (
            label: 'returns the lone element',
            elements: <int>[7],
            expected: 7,
            expectedPresent: true,
          ),
          (
            label: 'returns the tail of ascending input',
            elements: <int>[1, 2, 3],
            expected: 3,
            expectedPresent: true,
          ),
          (
            label: 'returns the tail when duplicates lead',
            elements: <int>[4, 2, 2, 5],
            expected: 5,
            expectedPresent: true,
          ),
          (
            label: 'handles negative numbers',
            elements: <int>[-5, -2, -9],
            expected: -9,
            expectedPresent: true,
          ),
        ];

    for (final testCase in lastCases) {
      test(testCase.label, () {
        final last = lastElement<int>(List<int>.of(testCase.elements));
        expect(last.present, equals(testCase.expectedPresent));
        expect(last.value, equals(testCase.expected));
      });
    }

    test('returns the last word', () {
      const List<String> words = <String>['apple', 'fig', 'kiwi'];
      final last = lastElement<String>(words);
      expect(last.present, isTrue);
      expect(last.value, equals('kiwi'));
    });

    test('returns absence on empty input', () {
      final last = lastElement<int>(<int>[]);
      expect(last.present, isFalse);
      expect(last.value, isNull);
    });

    test('distinguishes a stored null tail from absence via the flag', () {
      const List<int?> nullableScores = <int?>[1, null];
      final hit = lastElement<int?>(nullableScores);
      expect(hit.present, isTrue);
      expect(hit.value, isNull);
      final miss = lastElement<int?>(<int?>[]);
      expect(miss.present, isFalse);
      expect(miss.value, isNull);
    });

    test('leaves the input untouched', () {
      final List<int> scores = <int>[72, 91, 85];
      final List<int> snapshot = List<int>.of(scores);
      lastElement<int>(scores);
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

  group('minElementBy', () {
    final List<
      ({
        String label,
        List<int> elements,
        int Function(int) keyOf,
        int? expected,
        bool expectedPresent,
      })
    >
    minByCases =
        <
          ({
            String label,
            List<int> elements,
            int Function(int) keyOf,
            int? expected,
            bool expectedPresent,
          })
        >[
          (
            label: 'finds the smallest by identity',
            elements: <int>[3, 1, 2],
            keyOf: (score) => score,
            expected: 1,
            expectedPresent: true,
          ),
          (
            label: 'finds the largest value through a negated key',
            elements: <int>[3, 1, 2],
            keyOf: (score) => -score,
            expected: 3,
            expectedPresent: true,
          ),
          (
            label: 'keeps the first of duplicate minima',
            elements: <int>[4, 2, 2, 5],
            keyOf: (score) => score,
            expected: 2,
            expectedPresent: true,
          ),
          (
            label: 'handles negative numbers',
            elements: <int>[-2, -8, -3],
            keyOf: (score) => score,
            expected: -8,
            expectedPresent: true,
          ),
          (
            label: 'returns the lone element',
            elements: <int>[7],
            keyOf: (score) => score,
            expected: 7,
            expectedPresent: true,
          ),
        ];

    for (final testCase in minByCases) {
      test(testCase.label, () {
        final lowest = minElementBy<int, int>(
          List<int>.of(testCase.elements),
          testCase.keyOf,
        );
        expect(lowest.present, equals(testCase.expectedPresent));
        expect(lowest.value, equals(testCase.expected));
      });
    }

    test('finds the shortest word by length', () {
      const List<String> words = <String>['pear', 'fig', 'kiwi'];
      final lowest = minElementBy<String, int>(words, (fruit) => fruit.length);
      expect(lowest.present, isTrue);
      expect(lowest.value, equals('fig'));
    });

    test('keeps the first of equal derived keys', () {
      const List<String> words = <String>['pear', 'kiwi', 'plum'];
      final lowest = minElementBy<String, int>(words, (fruit) => fruit.length);
      expect(lowest.present, isTrue);
      expect(lowest.value, equals('pear'));
    });

    test(
      'returns absence on empty input without calling the key extractor',
      () {
        int calls = 0;
        final lowest = minElementBy<int, int>(<int>[], (score) {
          calls += 1;
          return score;
        });
        expect(lowest.present, isFalse);
        expect(lowest.value, isNull);
        expect(calls, equals(0));
      },
    );

    test('distinguishes a stored null minimum from absence via the flag', () {
      final hit = minElementBy<int?, int>(<int?>[
        null,
        1,
      ], (candidate) => candidate ?? -1);
      expect(hit.present, isTrue);
      expect(hit.value, isNull);
      final miss = minElementBy<int?, int>(
        <int?>[],
        (candidate) => candidate ?? -1,
      );
      expect(miss.present, isFalse);
      expect(miss.value, isNull);
    });

    test('leaves the input untouched', () {
      final List<String> words = <String>['pear', 'fig', 'kiwi'];
      final List<String> snapshot = List<String>.of(words);
      minElementBy<String, int>(words, (fruit) => fruit.length);
      expect(words, equals(snapshot));
    });
  });

  group('maxElementBy', () {
    final List<
      ({
        String label,
        List<int> elements,
        int Function(int) keyOf,
        int? expected,
        bool expectedPresent,
      })
    >
    maxByCases =
        <
          ({
            String label,
            List<int> elements,
            int Function(int) keyOf,
            int? expected,
            bool expectedPresent,
          })
        >[
          (
            label: 'finds the largest by identity',
            elements: <int>[3, 1, 2],
            keyOf: (score) => score,
            expected: 3,
            expectedPresent: true,
          ),
          (
            label: 'finds the smallest value through a negated key',
            elements: <int>[3, 1, 2],
            keyOf: (score) => -score,
            expected: 1,
            expectedPresent: true,
          ),
          (
            label: 'keeps the first of duplicate maxima',
            elements: <int>[4, 5, 5, 1],
            keyOf: (score) => score,
            expected: 5,
            expectedPresent: true,
          ),
          (
            label: 'handles negative numbers',
            elements: <int>[-2, -8, -3],
            keyOf: (score) => score,
            expected: -2,
            expectedPresent: true,
          ),
          (
            label: 'returns the lone element',
            elements: <int>[7],
            keyOf: (score) => score,
            expected: 7,
            expectedPresent: true,
          ),
        ];

    for (final testCase in maxByCases) {
      test(testCase.label, () {
        final highest = maxElementBy<int, int>(
          List<int>.of(testCase.elements),
          testCase.keyOf,
        );
        expect(highest.present, equals(testCase.expectedPresent));
        expect(highest.value, equals(testCase.expected));
      });
    }

    test('finds the longest word by length', () {
      const List<String> words = <String>['fig', 'pear', 'kiwi'];
      final highest = maxElementBy<String, int>(words, (fruit) => fruit.length);
      expect(highest.present, isTrue);
      expect(highest.value, equals('pear'));
    });

    test('keeps the first of equal derived keys', () {
      const List<String> words = <String>['kiwi', 'pear', 'plum'];
      final highest = maxElementBy<String, int>(words, (fruit) => fruit.length);
      expect(highest.present, isTrue);
      expect(highest.value, equals('kiwi'));
    });

    test(
      'returns absence on empty input without calling the key extractor',
      () {
        int calls = 0;
        final highest = maxElementBy<int, int>(<int>[], (score) {
          calls += 1;
          return score;
        });
        expect(highest.present, isFalse);
        expect(highest.value, isNull);
        expect(calls, equals(0));
      },
    );

    test('distinguishes a stored null maximum from absence via the flag', () {
      final hit = maxElementBy<int?, int>(<int?>[
        null,
        1,
      ], (candidate) => candidate ?? 99);
      expect(hit.present, isTrue);
      expect(hit.value, isNull);
      final miss = maxElementBy<int?, int>(
        <int?>[],
        (candidate) => candidate ?? 99,
      );
      expect(miss.present, isFalse);
      expect(miss.value, isNull);
    });

    test('leaves the input untouched', () {
      final List<String> words = <String>['fig', 'pear', 'kiwi'];
      final List<String> snapshot = List<String>.of(words);
      maxElementBy<String, int>(words, (fruit) => fruit.length);
      expect(words, equals(snapshot));
    });
  });

  group('sortedElements', () {
    final List<({String label, List<int> elements, List<int> expected})>
    sortedCases = <({String label, List<int> elements, List<int> expected})>[
      (
        label: 'sorts shuffled input',
        elements: <int>[3, 1, 2],
        expected: <int>[1, 2, 3],
      ),
      (
        label: 'keeps already sorted input',
        elements: <int>[1, 2, 3],
        expected: <int>[1, 2, 3],
      ),
      (
        label: 'handles descending input',
        elements: <int>[5, 4, 3],
        expected: <int>[3, 4, 5],
      ),
      (
        label: 'keeps duplicate values',
        elements: <int>[4, 2, 2, 5],
        expected: <int>[2, 2, 4, 5],
      ),
      (
        label: 'handles negative numbers',
        elements: <int>[-2, -8, -3],
        expected: <int>[-8, -3, -2],
      ),
      (
        label: 'returns the lone element',
        elements: <int>[7],
        expected: <int>[7],
      ),
    ];

    for (final testCase in sortedCases) {
      test(testCase.label, () {
        final sorted = sortedElements<int>(
          List<int>.of(testCase.elements),
          null,
        );
        expect(sorted, equals(testCase.expected));
      });
    }

    test('orders words lexicographically with the natural ordering', () {
      const List<String> words = <String>['pear', 'fig', 'kiwi'];
      final sorted = sortedElements<String>(words, null);
      expect(sorted, equals(<String>['fig', 'kiwi', 'pear']));
    });

    test('honours a custom descending comparator', () {
      final sorted = sortedElements<int>(<int>[
        3,
        1,
        2,
      ], (formerNumber, latterNumber) => latterNumber.compareTo(formerNumber));
      expect(sorted, equals(<int>[3, 2, 1]));
    });

    test('returns a fresh empty list for empty input', () {
      final List<int> emptyScores = <int>[];
      final sorted = sortedElements<int>(emptyScores, null);
      expect(sorted, isEmpty);
      expect(sorted, isNot(same(emptyScores)));
    });

    test('sorts stored nulls with a null-aware comparator', () {
      int compareNullable(int? formerNumber, int? latterNumber) {
        if (formerNumber == null) {
          return latterNumber == null ? 0 : -1;
        }
        if (latterNumber == null) {
          return 1;
        }
        return formerNumber.compareTo(latterNumber);
      }

      final sorted = sortedElements<int?>(<int?>[2, null, 1], compareNullable);
      expect(sorted, equals(<int?>[null, 1, 2]));
    });

    test('returns a fresh list and leaves the input untouched', () {
      final List<int> scores = <int>[3, 1, 2];
      final List<int> snapshot = List<int>.of(scores);
      final sorted = sortedElements<int>(scores, null);
      expect(sorted, isNot(same(scores)));
      sorted.add(99);
      expect(scores, equals(snapshot));
      expect(sorted, equals(<int>[1, 2, 3, 99]));
    });
  });

  group('documented examples', () {
    test('findElement example prints the first score above 80', () {
      final List<int> scores = <int>[72, 91, 85];
      final found = findElement(scores, (score) => score > 80);
      expect(found.present, isTrue);
      expect(found.value, equals(91));
    });

    test('firstElement example prints 72', () {
      final first = firstElement(<int>[72, 91, 85]);
      expect(first.present, isTrue);
      expect(first.value, equals(72));
    });

    test('lastElement example prints 85', () {
      final last = lastElement(<int>[72, 91, 85]);
      expect(last.present, isTrue);
      expect(last.value, equals(85));
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

    test('minElementBy example prints fig', () {
      final youngest = minElementBy(<String>[
        'fig',
        'pear',
        'kiwi',
      ], (fruit) => fruit.length);
      expect(youngest.present, isTrue);
      expect(youngest.value, equals('fig'));
    });

    test('maxElementBy example prints pear', () {
      final longest = maxElementBy(<String>[
        'fig',
        'pear',
        'kiwi',
      ], (fruit) => fruit.length);
      expect(longest.present, isTrue);
      expect(longest.value, equals('pear'));
    });

    test('sortedElements example sorts three scores', () {
      final sorted = sortedElements(<int>[3, 1, 2], null);
      expect(sorted, equals(<int>[1, 2, 3]));
    });
  });
}
