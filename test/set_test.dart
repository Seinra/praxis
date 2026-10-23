import 'package:praxis/src/set.dart';
import 'package:test/test.dart';

void main() {
  group('symmetricDifference', () {
    final List<
      ({
        String label,
        Set<int> firstSets,
        Set<int> secondSets,
        Set<int> expected,
      })
    >
    differenceCases =
        <
          ({
            String label,
            Set<int> firstSets,
            Set<int> secondSets,
            Set<int> expected,
          })
        >[
          (
            label: 'keeps members held by exactly one side',
            firstSets: <int>{1, 2, 3},
            secondSets: <int>{3, 4},
            expected: <int>{1, 2, 4},
          ),
          (
            label: 'yields empty when both sides match',
            firstSets: <int>{1, 2},
            secondSets: <int>{2, 1},
            expected: <int>{},
          ),
          (
            label: 'returns the lone side when the other is empty',
            firstSets: <int>{1, 2},
            secondSets: <int>{},
            expected: <int>{1, 2},
          ),
          (
            label: 'returns the lone side when the first is empty',
            firstSets: <int>{},
            secondSets: <int>{3, 4},
            expected: <int>{3, 4},
          ),
          (
            label: 'yields empty for two empty sides',
            firstSets: <int>{},
            secondSets: <int>{},
            expected: <int>{},
          ),
          (
            label: 'keeps everything when sides share nothing',
            firstSets: <int>{1, 2},
            secondSets: <int>{3, 4},
            expected: <int>{1, 2, 3, 4},
          ),
        ];

    for (final testCase in differenceCases) {
      test(testCase.label, () {
        final differed = symmetricDifference<int>(
          Set<int>.of(testCase.firstSets),
          Set<int>.of(testCase.secondSets),
        );
        expect(differed.length, equals(testCase.expected.length));
        expect(differed.containsAll(testCase.expected), isTrue);
        expect(testCase.expected.containsAll(differed), isTrue);
      });
    }

    test('differs words by either-side exclusivity', () {
      const Set<String> firstSets = <String>{'fig', 'pear'};
      const Set<String> secondSets = <String>{'pear', 'kiwi'};
      final differed = symmetricDifference<String>(firstSets, secondSets);
      expect(differed.length, equals(2));
      expect(differed.contains('fig'), isTrue);
      expect(differed.contains('kiwi'), isTrue);
    });

    test('returns a fresh set and leaves both inputs untouched', () {
      final Set<int> firstSets = <int>{1, 2, 3};
      final Set<int> secondSets = <int>{3, 4};
      final Set<int> firstSnapshot = Set<int>.of(firstSets);
      final Set<int> secondSnapshot = Set<int>.of(secondSets);
      final differed = symmetricDifference<int>(firstSets, secondSets);
      expect(differed, isNot(same(firstSets)));
      expect(differed, isNot(same(secondSets)));
      differed.add(99);
      expect(firstSets.containsAll(firstSnapshot), isTrue);
      expect(firstSnapshot.containsAll(firstSets), isTrue);
      expect(secondSets.containsAll(secondSnapshot), isTrue);
      expect(secondSnapshot.containsAll(secondSets), isTrue);
      expect(firstSets.contains(99), isFalse);
      expect(secondSets.contains(99), isFalse);
    });
  });

  group('isSubsetOf', () {
    final List<
      ({String label, Set<int> firstSets, Set<int> secondSets, bool expected})
    >
    subsetCases =
        <
          ({
            String label,
            Set<int> firstSets,
            Set<int> secondSets,
            bool expected,
          })
        >[
          (
            label: 'reports true when every member is held',
            firstSets: <int>{1, 2},
            secondSets: <int>{1, 2, 3},
            expected: true,
          ),
          (
            label: 'reports true for equal holdings',
            firstSets: <int>{1, 2},
            secondSets: <int>{2, 1},
            expected: true,
          ),
          (
            label: 'reports false when one member escapes',
            firstSets: <int>{1, 4},
            secondSets: <int>{1, 2, 3},
            expected: false,
          ),
          (
            label: 'reports false when the first side is larger',
            firstSets: <int>{1, 2, 3, 4},
            secondSets: <int>{1, 2},
            expected: false,
          ),
          (
            label: 'reports true for empty against anything',
            firstSets: <int>{},
            secondSets: <int>{1, 2},
            expected: true,
          ),
          (
            label: 'reports true for empty against empty',
            firstSets: <int>{},
            secondSets: <int>{},
            expected: true,
          ),
          (
            label: 'reports false for non-empty against empty',
            firstSets: <int>{1},
            secondSets: <int>{},
            expected: false,
          ),
        ];

    for (final testCase in subsetCases) {
      test(testCase.label, () {
        expect(
          isSubsetOf<int>(
            Set<int>.of(testCase.firstSets),
            Set<int>.of(testCase.secondSets),
          ),
          equals(testCase.expected),
        );
      });
    }

    test('checks word holdings by membership', () {
      expect(isSubsetOf<String>({'fig'}, {'fig', 'pear'}), isTrue);
      expect(isSubsetOf<String>({'fig', 'plum'}, {'fig', 'pear'}), isFalse);
    });

    test('leaves both inputs untouched', () {
      final Set<int> firstSets = <int>{1, 2};
      final Set<int> secondSets = <int>{1, 2, 3};
      final Set<int> firstSnapshot = Set<int>.of(firstSets);
      final Set<int> secondSnapshot = Set<int>.of(secondSets);
      isSubsetOf<int>(firstSets, secondSets);
      expect(firstSets.containsAll(firstSnapshot), isTrue);
      expect(secondSets.containsAll(secondSnapshot), isTrue);
    });
  });

  group('isSupersetOf', () {
    final List<
      ({String label, Set<int> firstSets, Set<int> secondSets, bool expected})
    >
    supersetCases =
        <
          ({
            String label,
            Set<int> firstSets,
            Set<int> secondSets,
            bool expected,
          })
        >[
          (
            label: 'reports true when every other member is held',
            firstSets: <int>{1, 2, 3},
            secondSets: <int>{1, 2},
            expected: true,
          ),
          (
            label: 'reports true for equal holdings',
            firstSets: <int>{1, 2},
            secondSets: <int>{2, 1},
            expected: true,
          ),
          (
            label: 'reports false when one other member escapes',
            firstSets: <int>{1, 2, 3},
            secondSets: <int>{1, 4},
            expected: false,
          ),
          (
            label: 'reports true for anything against empty',
            firstSets: <int>{1, 2},
            secondSets: <int>{},
            expected: true,
          ),
          (
            label: 'reports true for empty against empty',
            firstSets: <int>{},
            secondSets: <int>{},
            expected: true,
          ),
          (
            label: 'reports false for empty against non-empty',
            firstSets: <int>{},
            secondSets: <int>{1},
            expected: false,
          ),
        ];

    for (final testCase in supersetCases) {
      test(testCase.label, () {
        expect(
          isSupersetOf<int>(
            Set<int>.of(testCase.firstSets),
            Set<int>.of(testCase.secondSets),
          ),
          equals(testCase.expected),
        );
      });
    }

    test('checks word holdings by membership', () {
      expect(isSupersetOf<String>({'fig', 'pear'}, {'fig'}), isTrue);
      expect(isSupersetOf<String>({'fig'}, {'fig', 'plum'}), isFalse);
    });

    test('agrees with the swapped subset check', () {
      const Set<int> firstSets = <int>{1, 2, 3};
      const Set<int> secondSets = <int>{2, 3};
      expect(
        isSupersetOf<int>(firstSets, secondSets),
        equals(isSubsetOf<int>(secondSets, firstSets)),
      );
    });

    test('leaves both inputs untouched', () {
      final Set<int> firstSets = <int>{1, 2, 3};
      final Set<int> secondSets = <int>{1, 2};
      final Set<int> firstSnapshot = Set<int>.of(firstSets);
      final Set<int> secondSnapshot = Set<int>.of(secondSets);
      isSupersetOf<int>(firstSets, secondSets);
      expect(firstSets.containsAll(firstSnapshot), isTrue);
      expect(secondSets.containsAll(secondSnapshot), isTrue);
    });
  });

  group('isDisjointFrom', () {
    final List<
      ({String label, Set<int> firstSets, Set<int> secondSets, bool expected})
    >
    disjointCases =
        <
          ({
            String label,
            Set<int> firstSets,
            Set<int> secondSets,
            bool expected,
          })
        >[
          (
            label: 'reports true when sides share nothing',
            firstSets: <int>{1, 2},
            secondSets: <int>{3, 4},
            expected: true,
          ),
          (
            label: 'reports false when sides share one member',
            firstSets: <int>{1, 2},
            secondSets: <int>{2, 3},
            expected: false,
          ),
          (
            label: 'reports true for empty against anything',
            firstSets: <int>{},
            secondSets: <int>{1, 2},
            expected: true,
          ),
          (
            label: 'reports true for anything against empty',
            firstSets: <int>{1, 2},
            secondSets: <int>{},
            expected: true,
          ),
          (
            label: 'reports true for empty against empty',
            firstSets: <int>{},
            secondSets: <int>{},
            expected: true,
          ),
          (
            label: 'reports false for identical holdings',
            firstSets: <int>{1, 2},
            secondSets: <int>{2, 1},
            expected: false,
          ),
        ];

    for (final testCase in disjointCases) {
      test(testCase.label, () {
        expect(
          isDisjointFrom<int>(
            Set<int>.of(testCase.firstSets),
            Set<int>.of(testCase.secondSets),
          ),
          equals(testCase.expected),
        );
      });
    }

    test('checks word holdings by membership', () {
      expect(isDisjointFrom<String>({'fig'}, {'pear'}), isTrue);
      expect(isDisjointFrom<String>({'fig'}, {'fig', 'pear'}), isFalse);
    });

    test('is symmetric across argument order', () {
      const Set<int> firstSets = <int>{1, 2};
      const Set<int> secondSets = <int>{3, 4};
      const Set<int> overlapping = <int>{2, 3};
      expect(
        isDisjointFrom<int>(firstSets, secondSets),
        equals(isDisjointFrom<int>(secondSets, firstSets)),
      );
      expect(
        isDisjointFrom<int>(firstSets, overlapping),
        equals(isDisjointFrom<int>(overlapping, firstSets)),
      );
    });

    test('leaves both inputs untouched', () {
      final Set<int> firstSets = <int>{1, 2};
      final Set<int> secondSets = <int>{3, 4};
      final Set<int> firstSnapshot = Set<int>.of(firstSets);
      final Set<int> secondSnapshot = Set<int>.of(secondSets);
      isDisjointFrom<int>(firstSets, secondSets);
      expect(firstSets.containsAll(firstSnapshot), isTrue);
      expect(secondSets.containsAll(secondSnapshot), isTrue);
    });
  });

  group('hasSameMembers', () {
    final List<
      ({String label, Set<int> firstSets, Set<int> secondSets, bool expected})
    >
    sameCases =
        <
          ({
            String label,
            Set<int> firstSets,
            Set<int> secondSets,
            bool expected,
          })
        >[
          (
            label: 'reports true for equal holdings in any order',
            firstSets: <int>{1, 2, 3},
            secondSets: <int>{3, 2, 1},
            expected: true,
          ),
          (
            label: 'reports true for two empty sides',
            firstSets: <int>{},
            secondSets: <int>{},
            expected: true,
          ),
          (
            label: 'reports false when one member differs',
            firstSets: <int>{1, 2, 3},
            secondSets: <int>{1, 2, 4},
            expected: false,
          ),
          (
            label: 'reports false when sizes differ',
            firstSets: <int>{1, 2},
            secondSets: <int>{1, 2, 3},
            expected: false,
          ),
          (
            label: 'reports false for empty against non-empty',
            firstSets: <int>{},
            secondSets: <int>{1},
            expected: false,
          ),
          (
            label: 'reports false for non-empty against empty',
            firstSets: <int>{1},
            secondSets: <int>{},
            expected: false,
          ),
        ];

    for (final testCase in sameCases) {
      test(testCase.label, () {
        expect(
          hasSameMembers<int>(
            Set<int>.of(testCase.firstSets),
            Set<int>.of(testCase.secondSets),
          ),
          equals(testCase.expected),
        );
      });
    }

    test('compares word holdings structurally, not by identity', () {
      final Set<String> firstSets = <String>{'fig', 'pear'};
      final Set<String> secondSets = <String>{'pear', 'fig'};
      expect(identical(firstSets, secondSets), isFalse);
      expect(hasSameMembers<String>(firstSets, secondSets), isTrue);
      expect(hasSameMembers<String>(firstSets, {'fig'}), isFalse);
    });

    test('is symmetric across argument order', () {
      const Set<int> firstSets = <int>{1, 2};
      const Set<int> secondSets = <int>{2, 3};
      expect(
        hasSameMembers<int>(firstSets, secondSets),
        equals(hasSameMembers<int>(secondSets, firstSets)),
      );
    });

    test('leaves both inputs untouched', () {
      final Set<int> firstSets = <int>{1, 2};
      final Set<int> secondSets = <int>{2, 1};
      final Set<int> firstSnapshot = Set<int>.of(firstSets);
      final Set<int> secondSnapshot = Set<int>.of(secondSets);
      hasSameMembers<int>(firstSets, secondSets);
      expect(firstSets.containsAll(firstSnapshot), isTrue);
      expect(secondSets.containsAll(secondSnapshot), isTrue);
    });
  });

  group('documented examples', () {
    test('symmetricDifference example keeps either-side members', () {
      final differed = symmetricDifference(<int>{1, 2, 3}, <int>{3, 4});
      expect(differed.length, equals(3));
      expect(differed.containsAll(<int>{1, 2, 4}), isTrue);
    });

    test('isSubsetOf example checks inclusion order', () {
      expect(isSubsetOf(<int>{1, 2}, <int>{1, 2, 3}), isTrue);
    });

    test('isSupersetOf example checks the reverse inclusion', () {
      expect(isSupersetOf(<int>{1, 2, 3}, <int>{1, 2}), isTrue);
    });

    test('isDisjointFrom example reports shared nothing', () {
      expect(isDisjointFrom(<int>{1, 2}, <int>{3, 4}), isTrue);
    });

    test('hasSameMembers example compares by membership', () {
      expect(hasSameMembers(<int>{1, 2}, <int>{2, 1}), isTrue);
    });
  });
}
