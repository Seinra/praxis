import 'package:praxis/src/iterx.dart';
import 'package:test/test.dart';

void main() {
  group('zipIterables', () {
    final List<
      ({
        String label,
        List<int> firstElements,
        List<String> secondElements,
        List<({int first, String second})> expected,
      })
    >
    zipCases =
        <
          ({
            String label,
            List<int> firstElements,
            List<String> secondElements,
            List<({int first, String second})> expected,
          })
        >[
          (
            label: 'pairs positionally when lengths match',
            firstElements: <int>[1, 2],
            secondElements: <String>['a', 'b'],
            expected: <({int first, String second})>[
              (first: 1, second: 'a'),
              (first: 2, second: 'b'),
            ],
          ),
          (
            label: 'stops at the shorter first side',
            firstElements: <int>[1],
            secondElements: <String>['a', 'b', 'c'],
            expected: <({int first, String second})>[(first: 1, second: 'a')],
          ),
          (
            label: 'stops at the shorter second side',
            firstElements: <int>[1, 2, 3],
            secondElements: <String>['a'],
            expected: <({int first, String second})>[(first: 1, second: 'a')],
          ),
          (
            label: 'yields nothing when the first side is empty',
            firstElements: <int>[],
            secondElements: <String>['a'],
            expected: <({int first, String second})>[],
          ),
          (
            label: 'yields nothing when the second side is empty',
            firstElements: <int>[1, 2],
            secondElements: <String>[],
            expected: <({int first, String second})>[],
          ),
        ];

    for (final testCase in zipCases) {
      test(testCase.label, () {
        final paired = zipIterables<int, String>(
          List<int>.of(testCase.firstElements),
          List<String>.of(testCase.secondElements),
        );
        expect(paired.toList(), equals(testCase.expected));
      });
    }

    test('pairs words with scores', () {
      final paired = zipIterables<String, int>(
        <String>['fig', 'pear'],
        <int>[1, 2, 3],
      );
      expect(
        paired.toList(),
        equals(<({String first, int second})>[
          (first: 'fig', second: 1),
          (first: 'pear', second: 2),
        ]),
      );
    });

    test('pulls nothing until iterated', () {
      int firstPulls = 0;
      int secondPulls = 0;
      Iterable<int> firstSource() sync* {
        for (int index = 0; index < 5; index++) {
          firstPulls += 1;
          yield index;
        }
      }

      Iterable<String> secondSource() sync* {
        for (int index = 0; index < 5; index++) {
          secondPulls += 1;
          yield 'v$index';
        }
      }

      final paired = zipIterables<int, String>(firstSource(), secondSource());
      expect(firstPulls, equals(0));
      expect(secondPulls, equals(0));
      expect(paired.first, equals((first: 0, second: 'v0')));
      expect(firstPulls, equals(1));
      expect(secondPulls, equals(1));
    });

    test('stops pulling both sides when the caller stops early', () {
      int firstPulls = 0;
      int secondPulls = 0;
      Iterable<int> firstSource() sync* {
        for (int index = 0; index < 10; index++) {
          firstPulls += 1;
          yield index;
        }
      }

      Iterable<String> secondSource() sync* {
        for (int index = 0; index < 10; index++) {
          secondPulls += 1;
          yield 'v$index';
        }
      }

      final paired = zipIterables<int, String>(
        firstSource(),
        secondSource(),
      ).take(2).toList();
      expect(paired, hasLength(2));
      expect(firstPulls, equals(2));
      expect(secondPulls, equals(2));
    });

    test('re-iterating re-runs both sources', () {
      int pulls = 0;
      Iterable<int> countedSource() sync* {
        for (int index = 0; index < 2; index++) {
          pulls += 1;
          yield index;
        }
      }

      final paired = zipIterables<int, String>(countedSource(), <String>[
        'a',
        'b',
      ]);
      expect(paired.toList(), hasLength(2));
      expect(paired.toList(), hasLength(2));
      expect(pulls, equals(4));
    });

    test('leaves list inputs untouched', () {
      final List<int> firstScores = <int>[1, 2, 3];
      final List<String> secondWords = <String>['a', 'b'];
      final List<int> firstSnapshot = List<int>.of(firstScores);
      final List<String> secondSnapshot = List<String>.of(secondWords);
      zipIterables<int, String>(firstScores, secondWords).toList();
      expect(firstScores, equals(firstSnapshot));
      expect(secondWords, equals(secondSnapshot));
    });
  });

  group('chunkedIterable', () {
    final List<
      ({
        String label,
        List<int> sourceElements,
        int chunkSize,
        List<List<int>> expected,
      })
    >
    chunkCases =
        <
          ({
            String label,
            List<int> sourceElements,
            int chunkSize,
            List<List<int>> expected,
          })
        >[
          (
            label: 'splits evenly sized input',
            sourceElements: <int>[1, 2, 3, 4],
            chunkSize: 2,
            expected: <List<int>>[
              <int>[1, 2],
              <int>[3, 4],
            ],
          ),
          (
            label: 'leaves a short final chunk',
            sourceElements: <int>[1, 2, 3, 4, 5],
            chunkSize: 2,
            expected: <List<int>>[
              <int>[1, 2],
              <int>[3, 4],
              <int>[5],
            ],
          ),
          (
            label: 'yields one chunk when the size covers the input',
            sourceElements: <int>[1, 2],
            chunkSize: 5,
            expected: <List<int>>[
              <int>[1, 2],
            ],
          ),
          (
            label: 'yields singletons when the size is one',
            sourceElements: <int>[1, 2, 3],
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
        final chunks = chunkedIterable<int>(
          List<int>.of(testCase.sourceElements),
          testCase.chunkSize,
        );
        expect(chunks.toList(), equals(testCase.expected));
      });
    }

    test('chunks words as fresh lists', () {
      final chunks = chunkedIterable<String>(<String>[
        'a',
        'b',
        'c',
      ], 2).toList();
      expect(
        chunks,
        equals(<List<String>>[
          <String>['a', 'b'],
          <String>['c'],
        ]),
      );
    });

    test('yields nothing on empty input', () {
      int calls = 0;
      Iterable<int> emptySource() sync* {
        for (final candidate in <int>[]) {
          calls += 1;
          yield candidate;
        }
      }

      expect(chunkedIterable<int>(emptySource(), 2).toList(), isEmpty);
      expect(calls, equals(0));
    });

    test('rejects a non-positive chunk size without pulling the source', () {
      int pulls = 0;
      Iterable<int> countedSource() sync* {
        pulls += 1;
        yield 1;
      }

      expect(
        () => chunkedIterable<int>(countedSource(), 0),
        throwsArgumentError,
      );
      expect(
        () => chunkedIterable<int>(countedSource(), -2),
        throwsArgumentError,
      );
      expect(pulls, equals(0));
    });

    test('pulls nothing until iterated', () {
      int pulls = 0;
      Iterable<int> countedSource() sync* {
        for (int index = 0; index < 6; index++) {
          pulls += 1;
          yield index;
        }
      }

      final chunks = chunkedIterable<int>(countedSource(), 2);
      expect(pulls, equals(0));
      expect(chunks.first, equals(<int>[0, 1]));
      expect(pulls, equals(2));
    });

    test('stays lazy over an infinite source', () {
      final chunks = chunkedIterable<int>(
        repeatElement<int>(1),
        2,
      ).take(2).toList();
      expect(
        chunks,
        equals(<List<int>>[
          <int>[1, 1],
          <int>[1, 1],
        ]),
      );
    });

    test('returns fresh chunks and leaves the input untouched', () {
      final List<int> scores = <int>[1, 2, 3];
      final List<int> snapshot = List<int>.of(scores);
      final chunks = chunkedIterable<int>(scores, 2).toList();
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

  group('windowedIterable', () {
    final List<
      ({
        String label,
        List<int> sourceElements,
        int windowSize,
        List<List<int>> expected,
      })
    >
    windowCases =
        <
          ({
            String label,
            List<int> sourceElements,
            int windowSize,
            List<List<int>> expected,
          })
        >[
          (
            label: 'slides by one over three elements',
            sourceElements: <int>[1, 2, 3],
            windowSize: 2,
            expected: <List<int>>[
              <int>[1, 2],
              <int>[2, 3],
            ],
          ),
          (
            label: 'yields singletons when the size is one',
            sourceElements: <int>[1, 2],
            windowSize: 1,
            expected: <List<int>>[
              <int>[1],
              <int>[2],
            ],
          ),
          (
            label: 'yields one window when the size covers the input',
            sourceElements: <int>[1, 2],
            windowSize: 2,
            expected: <List<int>>[
              <int>[1, 2],
            ],
          ),
          (
            label: 'yields nothing when the size exceeds the input',
            sourceElements: <int>[1, 2],
            windowSize: 5,
            expected: <List<int>>[],
          ),
        ];

    for (final testCase in windowCases) {
      test(testCase.label, () {
        final windows = windowedIterable<int>(
          List<int>.of(testCase.sourceElements),
          testCase.windowSize,
        );
        expect(windows.toList(), equals(testCase.expected));
      });
    }

    test('slides words by one', () {
      final windows = windowedIterable<String>(<String>[
        'a',
        'b',
        'c',
      ], 2).toList();
      expect(
        windows,
        equals(<List<String>>[
          <String>['a', 'b'],
          <String>['b', 'c'],
        ]),
      );
    });

    test('yields nothing on empty input', () {
      expect(windowedIterable<int>(<int>[], 2).toList(), isEmpty);
    });

    test('rejects a non-positive window size without pulling the source', () {
      int pulls = 0;
      Iterable<int> countedSource() sync* {
        pulls += 1;
        yield 1;
      }

      expect(
        () => windowedIterable<int>(countedSource(), 0),
        throwsArgumentError,
      );
      expect(
        () => windowedIterable<int>(countedSource(), -3),
        throwsArgumentError,
      );
      expect(pulls, equals(0));
    });

    test('pulls nothing until iterated', () {
      int pulls = 0;
      Iterable<int> countedSource() sync* {
        for (int index = 0; index < 4; index++) {
          pulls += 1;
          yield index;
        }
      }

      final windows = windowedIterable<int>(countedSource(), 2);
      expect(pulls, equals(0));
      expect(windows.first, equals(<int>[0, 1]));
      expect(pulls, equals(2));
    });

    test('stays lazy over an infinite source', () {
      final windows = windowedIterable<int>(
        repeatElement<int>(4),
        2,
      ).take(2).toList();
      expect(
        windows,
        equals(<List<int>>[
          <int>[4, 4],
          <int>[4, 4],
        ]),
      );
    });

    test('returns fresh windows and leaves the input untouched', () {
      final List<int> scores = <int>[1, 2, 3];
      final List<int> snapshot = List<int>.of(scores);
      final windows = windowedIterable<int>(scores, 2).toList();
      windows[0].add(99);
      expect(scores, equals(snapshot));
      expect(
        windows,
        equals(<List<int>>[
          <int>[1, 2, 99],
          <int>[2, 3],
        ]),
      );
    });
  });

  group('cycleIterable', () {
    test('repeats the source in order through a bounded take', () {
      expect(
        cycleIterable<int>(<int>[1, 2]).take(5).toList(),
        equals(<int>[1, 2, 1, 2, 1]),
      );
    });

    test('repeats words in order', () {
      expect(
        cycleIterable<String>(<String>['a', 'b']).take(3).toList(),
        equals(<String>['a', 'b', 'a']),
      );
    });

    test('yields nothing on empty input', () {
      expect(cycleIterable<int>(<int>[]).take(3).toList(), isEmpty);
    });

    test('repeats a singleton', () {
      expect(
        cycleIterable<int>(<int>[9]).take(3).toList(),
        equals(<int>[9, 9, 9]),
      );
    });

    test('pulls nothing until iterated', () {
      int pulls = 0;
      Iterable<int> countedSource() sync* {
        for (int index = 0; index < 2; index++) {
          pulls += 1;
          yield index;
        }
      }

      final cycled = cycleIterable<int>(countedSource());
      expect(pulls, equals(0));
      expect(cycled.take(3).toList(), equals(<int>[0, 1, 0]));
      expect(pulls, equals(2));
    });

    test('buffers incrementally and repeats without re-pulling the source', () {
      int pulls = 0;
      Iterable<int> countedSource() sync* {
        for (int index = 0; index < 2; index++) {
          pulls += 1;
          yield index;
        }
      }

      final cycled = cycleIterable<int>(countedSource());
      expect(cycled.take(5).toList(), equals(<int>[0, 1, 0, 1, 0]));
      expect(pulls, equals(2));
    });

    test('leaves list inputs untouched', () {
      final List<int> scores = <int>[1, 2];
      final List<int> snapshot = List<int>.of(scores);
      cycleIterable<int>(scores).take(4).toList();
      expect(scores, equals(snapshot));
    });
  });

  group('repeatElement', () {
    test('repeats one value through a bounded take', () {
      expect(repeatElement<int>(7).take(3).toList(), equals(<int>[7, 7, 7]));
    });

    test('repeats words', () {
      expect(
        repeatElement<String>('hi').take(2).toList(),
        equals(<String>['hi', 'hi']),
      );
    });

    test('yields nothing when the caller takes none', () {
      expect(repeatElement<int>(7).take(0).toList(), isEmpty);
    });

    test('stays lazy: an unbounded repeat never terminates on its own', () {
      final repeated = repeatElement<int>(5);
      expect(repeated.take(1).toList(), equals(<int>[5]));
      expect(repeated.take(4).toList(), equals(<int>[5, 5, 5, 5]));
    });

    test('supports a null element', () {
      expect(
        repeatElement<int?>(null).take(2).toList(),
        equals(<int?>[null, null]),
      );
    });
  });

  group('deduplicateAdjacent', () {
    final List<({String label, List<int> sourceElements, List<int> expected})>
    dedupeCases =
        <({String label, List<int> sourceElements, List<int> expected})>[
          (
            label: 'collapses each adjacent run keeping the first',
            sourceElements: <int>[1, 1, 2, 2, 2, 3],
            expected: <int>[1, 2, 3],
          ),
          (
            label: 'keeps non-adjacent duplicates',
            sourceElements: <int>[1, 2, 1],
            expected: <int>[1, 2, 1],
          ),
          (
            label: 'collapses an all-equal input to one',
            sourceElements: <int>[4, 4, 4],
            expected: <int>[4],
          ),
          (
            label: 'keeps a singleton',
            sourceElements: <int>[8],
            expected: <int>[8],
          ),
          (
            label: 'keeps already distinct input',
            sourceElements: <int>[1, 2, 3],
            expected: <int>[1, 2, 3],
          ),
        ];

    for (final testCase in dedupeCases) {
      test(testCase.label, () {
        expect(
          deduplicateAdjacent<int>(List<int>.of(testCase.sourceElements))
              .toList(),
          equals(testCase.expected),
        );
      });
    }

    test('collapses adjacent words keeping the first of each run', () {
      expect(
        deduplicateAdjacent<String>(<String>['a', 'a', 'b', 'a']).toList(),
        equals(<String>['a', 'b', 'a']),
      );
    });

    test('yields nothing on empty input', () {
      expect(deduplicateAdjacent<int>(<int>[]).toList(), isEmpty);
    });

    test('distinguishes null runs from values', () {
      expect(
        deduplicateAdjacent<int?>(<int?>[null, null, 1, 1, null]).toList(),
        equals(<int?>[null, 1, null]),
      );
    });

    test('pulls nothing until iterated', () {
      int pulls = 0;
      Iterable<int> countedSource() sync* {
        for (int index = 0; index < 3; index++) {
          pulls += 1;
          yield index;
        }
      }

      final deduped = deduplicateAdjacent<int>(countedSource());
      expect(pulls, equals(0));
      expect(deduped.first, equals(0));
      expect(pulls, equals(1));
    });

    test('stays lazy over an infinite constant source', () {
      expect(
        deduplicateAdjacent<int>(repeatElement<int>(5)).take(1).toList(),
        equals(<int>[5]),
      );
    });

    test('stops pulling when the caller stops early', () {
      int pulls = 0;
      Iterable<int> countedSource() sync* {
        for (int index = 0; index < 10; index++) {
          pulls += 1;
          yield index ~/ 2;
        }
      }

      final deduped = deduplicateAdjacent<int>(countedSource())
          .take(2)
          .toList();
      expect(deduped, equals(<int>[0, 1]));
      expect(pulls, lessThan(10));
    });

    test('leaves list inputs untouched', () {
      final List<int> scores = <int>[1, 1, 2];
      final List<int> snapshot = List<int>.of(scores);
      deduplicateAdjacent<int>(scores).toList();
      expect(scores, equals(snapshot));
    });
  });

  group('documented examples', () {
    test('zipIterables example pairs two lists stopping at the shorter', () {
      final paired = zipIterables(<int>[1, 2, 3], <String>['a', 'b']);
      expect(
        paired.toList(),
        equals(<({int first, String second})>[
          (first: 1, second: 'a'),
          (first: 2, second: 'b'),
        ]),
      );
    });

    test('chunkedIterable example groups five scores by two', () {
      final chunks = chunkedIterable(<int>[1, 2, 3, 4, 5], 2);
      expect(
        chunks.toList(),
        equals(<List<int>>[
          <int>[1, 2],
          <int>[3, 4],
          <int>[5],
        ]),
      );
    });

    test('windowedIterable example slides pairs over three scores', () {
      final windows = windowedIterable(<int>[1, 2, 3], 2);
      expect(
        windows.toList(),
        equals(<List<int>>[
          <int>[1, 2],
          <int>[2, 3],
        ]),
      );
    });

    test('cycleIterable example repeats two scores five times in order', () {
      final cycled = cycleIterable(<int>[1, 2]).take(5);
      expect(cycled.toList(), equals(<int>[1, 2, 1, 2, 1]));
    });

    test('repeatElement example repeats one score three times', () {
      final repeated = repeatElement(7).take(3);
      expect(repeated.toList(), equals(<int>[7, 7, 7]));
    });

    test('deduplicateAdjacent example collapses runs keeping order', () {
      final uniqueRuns = deduplicateAdjacent(<int>[1, 1, 2, 1]);
      expect(uniqueRuns.toList(), equals(<int>[1, 2, 1]));
    });
  });
}
