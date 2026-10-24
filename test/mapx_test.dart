import 'package:praxis/src/mapx.dart';
import 'package:test/test.dart';

void main() {
  group('invertEntries', () {
    test('groups keys sharing a value preserving encounter order', () {
      final Map<String, int> entries = <String, int>{
        'ann': 1,
        'bob': 2,
        'cid': 1,
      };
      final Map<int, List<String>> grouped = invertEntries<String, int>(
        Map<String, int>.of(entries),
      );
      expect(grouped.length, equals(2));
      expect(grouped[1], equals(<String>['ann', 'cid']));
      expect(grouped[2], equals(<String>['bob']));
    });

    test('keeps distinct values on separate groups', () {
      final Map<int, List<String>> grouped = invertEntries<String, int>(
        <String, int>{'fig': 1, 'pear': 2},
      );
      expect(grouped.length, equals(2));
      expect(grouped[1], equals(<String>['fig']));
      expect(grouped[2], equals(<String>['pear']));
    });

    test('keeps a singleton entry as a singleton group', () {
      final Map<int, List<String>> grouped = invertEntries<String, int>(
        <String, int>{'fig': 7},
      );
      expect(grouped.length, equals(1));
      expect(grouped[7], equals(<String>['fig']));
    });

    test('returns a fresh empty map for empty input', () {
      final Map<int, List<String>> grouped = invertEntries<String, int>(
        <String, int>{},
      );
      expect(grouped, isEmpty);
    });

    test('returns fresh lists and leaves the input untouched', () {
      final Map<String, int> entries = <String, int>{'ann': 1, 'cid': 1};
      final Map<String, int> snapshot = Map<String, int>.of(entries);
      final Map<int, List<String>> grouped = invertEntries<String, int>(
        entries,
      );
      expect(grouped, isNot(same(entries)));
      grouped[1]!.add('intruder');
      expect(entries, equals(snapshot));
      expect(entries.containsKey('intruder'), isFalse);
    });
  });

  group('pickEntries', () {
    final List<
      ({
        String label,
        Map<String, int> entries,
        List<String> wantedKeys,
        Map<String, int> expected,
      })
    >
    pickCases =
        <
          ({
            String label,
            Map<String, int> entries,
            List<String> wantedKeys,
            Map<String, int> expected,
          })
        >[
          (
            label: 'keeps only the requested present keys',
            entries: <String, int>{'ann': 1, 'bob': 2, 'cid': 3},
            wantedKeys: <String>['ann', 'cid'],
            expected: <String, int>{'ann': 1, 'cid': 3},
          ),
          (
            label: 'ignores missing keys',
            entries: <String, int>{'ann': 1, 'bob': 2},
            wantedKeys: <String>['ann', 'missing'],
            expected: <String, int>{'ann': 1},
          ),
          (
            label: 'yields empty when no wanted key is present',
            entries: <String, int>{'ann': 1},
            wantedKeys: <String>['missing'],
            expected: <String, int>{},
          ),
          (
            label: 'yields empty for empty input',
            entries: <String, int>{},
            wantedKeys: <String>['ann'],
            expected: <String, int>{},
          ),
          (
            label: 'yields empty when no keys are wanted',
            entries: <String, int>{'ann': 1},
            wantedKeys: <String>[],
            expected: <String, int>{},
          ),
        ];

    for (final testCase in pickCases) {
      test(testCase.label, () {
        final Map<String, int> picked = pickEntries<String, int>(
          Map<String, int>.of(testCase.entries),
          List<String>.of(testCase.wantedKeys),
        );
        expect(picked, equals(testCase.expected));
      });
    }

    test('picks word scores by name', () {
      const Map<String, int> entries = <String, int>{'fig': 1, 'pear': 2};
      final Map<String, int> picked = pickEntries<String, int>(
        entries,
        <String>['pear', 'missing'],
      );
      expect(picked, equals(<String, int>{'pear': 2}));
    });

    test('keeps a present-null value', () {
      const Map<String, int?> entries = <String, int?>{'ann': null};
      final Map<String, int?> picked = pickEntries<String, int?>(
        entries,
        <String>['ann'],
      );
      expect(picked.containsKey('ann'), isTrue);
      expect(picked['ann'], isNull);
    });

    test('returns a fresh map and leaves both inputs untouched', () {
      final Map<String, int> entries = <String, int>{'ann': 1, 'bob': 2};
      final Map<String, int> snapshot = Map<String, int>.of(entries);
      final List<String> wantedKeys = <String>['ann'];
      final List<String> wantedSnapshot = List<String>.of(wantedKeys);
      final Map<String, int> picked = pickEntries<String, int>(
        entries,
        wantedKeys,
      );
      expect(picked, isNot(same(entries)));
      picked['ann'] = 99;
      expect(entries, equals(snapshot));
      expect(wantedKeys, equals(wantedSnapshot));
    });
  });

  group('omitEntries', () {
    final List<
      ({
        String label,
        Map<String, int> entries,
        List<String> excludedKeys,
        Map<String, int> expected,
      })
    >
    omitCases =
        <
          ({
            String label,
            Map<String, int> entries,
            List<String> excludedKeys,
            Map<String, int> expected,
          })
        >[
          (
            label: 'drops the listed keys keeping the rest',
            entries: <String, int>{'ann': 1, 'bob': 2, 'cid': 3},
            excludedKeys: <String>['bob'],
            expected: <String, int>{'ann': 1, 'cid': 3},
          ),
          (
            label: 'ignores missing keys',
            entries: <String, int>{'ann': 1, 'bob': 2},
            excludedKeys: <String>['missing'],
            expected: <String, int>{'ann': 1, 'bob': 2},
          ),
          (
            label: 'yields a copy when nothing is excluded',
            entries: <String, int>{'ann': 1, 'bob': 2},
            excludedKeys: <String>[],
            expected: <String, int>{'ann': 1, 'bob': 2},
          ),
          (
            label: 'yields empty when every key is excluded',
            entries: <String, int>{'ann': 1, 'bob': 2},
            excludedKeys: <String>['ann', 'bob'],
            expected: <String, int>{},
          ),
          (
            label: 'yields empty for empty input',
            entries: <String, int>{},
            excludedKeys: <String>['ann'],
            expected: <String, int>{},
          ),
        ];

    for (final testCase in omitCases) {
      test(testCase.label, () {
        final Map<String, int> kept = omitEntries<String, int>(
          Map<String, int>.of(testCase.entries),
          List<String>.of(testCase.excludedKeys),
        );
        expect(kept, equals(testCase.expected));
      });
    }

    test('omits word scores by name', () {
      const Map<String, int> entries = <String, int>{'fig': 1, 'pear': 2};
      final Map<String, int> kept = omitEntries<String, int>(entries, <String>[
        'fig',
      ]);
      expect(kept, equals(<String, int>{'pear': 2}));
    });

    test('complements pickEntries on the same key set', () {
      const Map<String, int> entries = <String, int>{
        'ann': 1,
        'bob': 2,
        'cid': 3,
      };
      const List<String> excludedKeys = <String>['bob'];
      final Map<String, int> kept = omitEntries<String, int>(
        entries,
        excludedKeys,
      );
      final Map<String, int> picked = pickEntries<String, int>(
        entries,
        excludedKeys,
      );
      expect(kept.keys.contains('bob'), isFalse);
      expect(picked, equals(<String, int>{'bob': 2}));
      expect(kept.length + picked.length, equals(entries.length));
    });

    test('returns a fresh map and leaves both inputs untouched', () {
      final Map<String, int> entries = <String, int>{'ann': 1, 'bob': 2};
      final Map<String, int> snapshot = Map<String, int>.of(entries);
      final List<String> excludedKeys = <String>['ann'];
      final List<String> excludedSnapshot = List<String>.of(excludedKeys);
      final Map<String, int> kept = omitEntries<String, int>(
        entries,
        excludedKeys,
      );
      expect(kept, isNot(same(entries)));
      kept['bob'] = 99;
      expect(entries, equals(snapshot));
      expect(excludedKeys, equals(excludedSnapshot));
    });
  });

  group('mapValues', () {
    test('transforms every value keeping keys unchanged', () {
      final Map<String, int> mapped = mapValues<String, int, int>(<String, int>{
        'ann': 1,
        'bob': 2,
      }, (score) => score * 2);
      expect(mapped, equals(<String, int>{'ann': 2, 'bob': 4}));
    });

    test('changes the value type through the transform', () {
      final Map<String, int> mapped = mapValues<String, String, int>(
        <String, String>{'fig': 'fig', 'pear': 'pear'},
        (word) => word.length,
      );
      expect(mapped, equals(<String, int>{'fig': 3, 'pear': 4}));
    });

    test('returns empty without calling the transform on empty input', () {
      int calls = 0;
      final Map<String, int> mapped = mapValues<String, int, int>(
        <String, int>{},
        (score) {
          calls += 1;
          return score * 2;
        },
      );
      expect(mapped, isEmpty);
      expect(calls, equals(0));
    });

    test('returns a fresh map and leaves the input untouched', () {
      final Map<String, int> entries = <String, int>{'ann': 1, 'bob': 2};
      final Map<String, int> snapshot = Map<String, int>.of(entries);
      final Map<String, int> mapped = mapValues<String, int, int>(
        entries,
        (score) => score * 2,
      );
      expect(mapped, isNot(same(entries)));
      mapped['ann'] = 99;
      expect(entries, equals(snapshot));
    });
  });

  group('mapKeys', () {
    test('remaps every key keeping values unchanged', () {
      final Map<String, int> remapped = mapKeys<String, int, String>(
        <String, int>{'ann': 1, 'bob': 2},
        (name) => name.toUpperCase(),
      );
      expect(remapped, equals(<String, int>{'ANN': 1, 'BOB': 2}));
    });

    test('changes the key type through the key function', () {
      final Map<int, String> remapped = mapKeys<String, String, int>(
        <String, String>{'fig': 'sweet', 'pear': 'juicy'},
        (name) => name.length,
      );
      expect(remapped.length, equals(2));
      expect(remapped[3], equals('sweet'));
      expect(remapped[4], equals('juicy'));
    });

    test('lets the last encountered key win on collision', () {
      final Map<String, int> remapped = mapKeys<String, int, String>(
        <String, int>{'ann': 1, 'ANN': 2},
        (name) => name.toUpperCase(),
      );
      expect(remapped.length, equals(1));
      expect(remapped['ANN'], equals(2));
    });

    test('returns empty without calling the key function on empty input', () {
      int calls = 0;
      final Map<String, int> remapped = mapKeys<String, int, String>(
        <String, int>{},
        (name) {
          calls += 1;
          return name.toUpperCase();
        },
      );
      expect(remapped, isEmpty);
      expect(calls, equals(0));
    });

    test('returns a fresh map and leaves the input untouched', () {
      final Map<String, int> entries = <String, int>{'ann': 1, 'bob': 2};
      final Map<String, int> snapshot = Map<String, int>.of(entries);
      final Map<String, int> remapped = mapKeys<String, int, String>(
        entries,
        (name) => name.toUpperCase(),
      );
      expect(remapped, isNot(same(entries)));
      remapped['ANN'] = 99;
      expect(entries, equals(snapshot));
    });
  });

  group('groupEntriesBy', () {
    test('groups values by a derived key preserving encounter order', () {
      final Map<String, List<int>> grouped =
          groupEntriesBy<String, int, String>(<String, int>{
            'ann': 91,
            'bob': 72,
            'cid': 85,
          }, (name, score) => score >= 80 ? 'pass' : 'fail');
      expect(grouped.length, equals(2));
      expect(grouped['pass'], equals(<int>[91, 85]));
      expect(grouped['fail'], equals(<int>[72]));
    });

    test('collects every value under one group when all share it', () {
      final Map<String, List<int>> grouped =
          groupEntriesBy<String, int, String>(<String, int>{
            'ann': 1,
            'bob': 2,
          }, (name, score) => 'held');
      expect(grouped.length, equals(1));
      expect(grouped['held'], equals(<int>[1, 2]));
    });

    test('groups by key content independently of values', () {
      final Map<int, List<int>> grouped = groupEntriesBy<String, int, int>(
        <String, int>{'fig': 1, 'pear': 2, 'plum': 3},
        (name, score) => name.length,
      );
      expect(grouped[3], equals(<int>[1]));
      expect(grouped[4], equals(<int>[2, 3]));
    });

    test('returns empty without calling the group function on empty input', () {
      int calls = 0;
      final Map<String, List<int>> grouped =
          groupEntriesBy<String, int, String>(<String, int>{}, (name, score) {
            calls += 1;
            return 'held';
          });
      expect(grouped, isEmpty);
      expect(calls, equals(0));
    });

    test('returns fresh lists and leaves the input untouched', () {
      final Map<String, int> entries = <String, int>{'ann': 91, 'bob': 72};
      final Map<String, int> snapshot = Map<String, int>.of(entries);
      final Map<String, List<int>> grouped =
          groupEntriesBy<String, int, String>(
            entries,
            (name, score) => score >= 80 ? 'pass' : 'fail',
          );
      expect(grouped['pass'], isNot(same(entries)));
      grouped['pass']!.add(99);
      expect(entries, equals(snapshot));
    });
  });

  group('documented examples', () {
    test('invertEntries example groups names by shared score', () {
      final Map<int, List<String>> grouped = invertEntries(<String, int>{
        'ann': 1,
        'bob': 2,
        'cid': 1,
      });
      expect(grouped[1]!.contains('ann'), isTrue);
      expect(grouped[1]!.contains('cid'), isTrue);
      expect(grouped[2], equals(<String>['bob']));
    });

    test('pickEntries example keeps only the requested name', () {
      final Map<String, int> picked = pickEntries(
        <String, int>{'ann': 1, 'bob': 2},
        <String>['ann', 'missing'],
      );
      expect(picked, equals(<String, int>{'ann': 1}));
    });

    test('omitEntries example drops the listed name', () {
      final Map<String, int> kept = omitEntries(
        <String, int>{'ann': 1, 'bob': 2},
        <String>['ann'],
      );
      expect(kept, equals(<String, int>{'bob': 2}));
    });

    test('mapValues example doubles every score', () {
      final Map<String, int> doubled = mapValues(<String, int>{
        'ann': 1,
      }, (score) => score * 2);
      expect(doubled, equals(<String, int>{'ann': 2}));
    });

    test('mapKeys example uppercases every name', () {
      final Map<String, int> upper = mapKeys(<String, int>{
        'ann': 1,
      }, (name) => name.toUpperCase());
      expect(upper, equals(<String, int>{'ANN': 1}));
    });

    test('groupEntriesBy example splits passing from failing scores', () {
      final Map<String, List<int>> grouped = groupEntriesBy(<String, int>{
        'ann': 91,
        'bob': 72,
      }, (name, score) => score >= 80 ? 'pass' : 'fail');
      expect(grouped['pass'], equals(<int>[91]));
      expect(grouped['fail'], equals(<int>[72]));
    });
  });
}
