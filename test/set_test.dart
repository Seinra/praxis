import 'package:praxis/src/set.dart';
import 'package:test/test.dart';

void main() {
  group('symmetricDifference', () {
    final List<
      ({
        String label,
        Set<int> firstMembers,
        Set<int> secondMembers,
        Set<int> expected,
      })
    >
    differenceCases =
        <
          ({
            String label,
            Set<int> firstMembers,
            Set<int> secondMembers,
            Set<int> expected,
          })
        >[
          (
            label: 'keeps members held by exactly one side',
            firstMembers: <int>{1, 2, 3},
            secondMembers: <int>{3, 4},
            expected: <int>{1, 2, 4},
          ),
          (
            label: 'yields empty when both sides match',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{2, 1},
            expected: <int>{},
          ),
          (
            label: 'returns the lone side when the other is empty',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{},
            expected: <int>{1, 2},
          ),
          (
            label: 'returns the lone side when the first is empty',
            firstMembers: <int>{},
            secondMembers: <int>{3, 4},
            expected: <int>{3, 4},
          ),
          (
            label: 'yields empty for two empty sides',
            firstMembers: <int>{},
            secondMembers: <int>{},
            expected: <int>{},
          ),
          (
            label: 'keeps everything when sides share nothing',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{3, 4},
            expected: <int>{1, 2, 3, 4},
          ),
        ];

    for (final testCase in differenceCases) {
      test(testCase.label, () {
        final difference = symmetricDifference<int>(
          Set<int>.of(testCase.firstMembers),
          Set<int>.of(testCase.secondMembers),
        );
        expect(difference.length, equals(testCase.expected.length));
        expect(difference.containsAll(testCase.expected), isTrue);
        expect(testCase.expected.containsAll(difference), isTrue);
      });
    }

    test('differs words by either-side exclusivity', () {
      const Set<String> firstMembers = <String>{'fig', 'pear'};
      const Set<String> secondMembers = <String>{'pear', 'kiwi'};
      final difference = symmetricDifference<String>(
        firstMembers,
        secondMembers,
      );
      expect(difference.length, equals(2));
      expect(difference.contains('fig'), isTrue);
      expect(difference.contains('kiwi'), isTrue);
    });

    test('returns a fresh set and leaves both inputs untouched', () {
      final Set<int> firstMembers = <int>{1, 2, 3};
      final Set<int> secondMembers = <int>{3, 4};
      final Set<int> firstSnapshot = Set<int>.of(firstMembers);
      final Set<int> secondSnapshot = Set<int>.of(secondMembers);
      final difference = symmetricDifference<int>(firstMembers, secondMembers);
      expect(difference, isNot(same(firstMembers)));
      expect(difference, isNot(same(secondMembers)));
      difference.add(99);
      expect(firstMembers.containsAll(firstSnapshot), isTrue);
      expect(firstSnapshot.containsAll(firstMembers), isTrue);
      expect(secondMembers.containsAll(secondSnapshot), isTrue);
      expect(secondSnapshot.containsAll(secondMembers), isTrue);
      expect(firstMembers.contains(99), isFalse);
      expect(secondMembers.contains(99), isFalse);
    });
  });

  group('isSubsetOf', () {
    final List<
      ({
        String label,
        Set<int> firstMembers,
        Set<int> secondMembers,
        bool expected,
      })
    >
    subsetCases =
        <
          ({
            String label,
            Set<int> firstMembers,
            Set<int> secondMembers,
            bool expected,
          })
        >[
          (
            label: 'reports true when every member is held',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{1, 2, 3},
            expected: true,
          ),
          (
            label: 'reports true for equal holdings',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{2, 1},
            expected: true,
          ),
          (
            label: 'reports false when one member escapes',
            firstMembers: <int>{1, 4},
            secondMembers: <int>{1, 2, 3},
            expected: false,
          ),
          (
            label: 'reports false when the first side is larger',
            firstMembers: <int>{1, 2, 3, 4},
            secondMembers: <int>{1, 2},
            expected: false,
          ),
          (
            label: 'reports true for empty against anything',
            firstMembers: <int>{},
            secondMembers: <int>{1, 2},
            expected: true,
          ),
          (
            label: 'reports true for empty against empty',
            firstMembers: <int>{},
            secondMembers: <int>{},
            expected: true,
          ),
          (
            label: 'reports false for non-empty against empty',
            firstMembers: <int>{1},
            secondMembers: <int>{},
            expected: false,
          ),
        ];

    for (final testCase in subsetCases) {
      test(testCase.label, () {
        expect(
          isSubsetOf<int>(
            Set<int>.of(testCase.firstMembers),
            Set<int>.of(testCase.secondMembers),
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
      final Set<int> firstMembers = <int>{1, 2};
      final Set<int> secondMembers = <int>{1, 2, 3};
      final Set<int> firstSnapshot = Set<int>.of(firstMembers);
      final Set<int> secondSnapshot = Set<int>.of(secondMembers);
      isSubsetOf<int>(firstMembers, secondMembers);
      expect(firstMembers.containsAll(firstSnapshot), isTrue);
      expect(secondMembers.containsAll(secondSnapshot), isTrue);
    });
  });

  group('isSupersetOf', () {
    final List<
      ({
        String label,
        Set<int> firstMembers,
        Set<int> secondMembers,
        bool expected,
      })
    >
    supersetCases =
        <
          ({
            String label,
            Set<int> firstMembers,
            Set<int> secondMembers,
            bool expected,
          })
        >[
          (
            label: 'reports true when every other member is held',
            firstMembers: <int>{1, 2, 3},
            secondMembers: <int>{1, 2},
            expected: true,
          ),
          (
            label: 'reports true for equal holdings',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{2, 1},
            expected: true,
          ),
          (
            label: 'reports false when one other member escapes',
            firstMembers: <int>{1, 2, 3},
            secondMembers: <int>{1, 4},
            expected: false,
          ),
          (
            label: 'reports true for anything against empty',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{},
            expected: true,
          ),
          (
            label: 'reports true for empty against empty',
            firstMembers: <int>{},
            secondMembers: <int>{},
            expected: true,
          ),
          (
            label: 'reports false for empty against non-empty',
            firstMembers: <int>{},
            secondMembers: <int>{1},
            expected: false,
          ),
        ];

    for (final testCase in supersetCases) {
      test(testCase.label, () {
        expect(
          isSupersetOf<int>(
            Set<int>.of(testCase.firstMembers),
            Set<int>.of(testCase.secondMembers),
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
      const Set<int> firstMembers = <int>{1, 2, 3};
      const Set<int> secondMembers = <int>{2, 3};
      expect(
        isSupersetOf<int>(firstMembers, secondMembers),
        equals(isSubsetOf<int>(secondMembers, firstMembers)),
      );
    });

    test('leaves both inputs untouched', () {
      final Set<int> firstMembers = <int>{1, 2, 3};
      final Set<int> secondMembers = <int>{1, 2};
      final Set<int> firstSnapshot = Set<int>.of(firstMembers);
      final Set<int> secondSnapshot = Set<int>.of(secondMembers);
      isSupersetOf<int>(firstMembers, secondMembers);
      expect(firstMembers.containsAll(firstSnapshot), isTrue);
      expect(secondMembers.containsAll(secondSnapshot), isTrue);
    });
  });

  group('isDisjointFrom', () {
    final List<
      ({
        String label,
        Set<int> firstMembers,
        Set<int> secondMembers,
        bool expected,
      })
    >
    disjointCases =
        <
          ({
            String label,
            Set<int> firstMembers,
            Set<int> secondMembers,
            bool expected,
          })
        >[
          (
            label: 'reports true when sides share nothing',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{3, 4},
            expected: true,
          ),
          (
            label: 'reports false when sides share one member',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{2, 3},
            expected: false,
          ),
          (
            label: 'reports true for empty against anything',
            firstMembers: <int>{},
            secondMembers: <int>{1, 2},
            expected: true,
          ),
          (
            label: 'reports true for anything against empty',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{},
            expected: true,
          ),
          (
            label: 'reports true for empty against empty',
            firstMembers: <int>{},
            secondMembers: <int>{},
            expected: true,
          ),
          (
            label: 'reports false for identical holdings',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{2, 1},
            expected: false,
          ),
        ];

    for (final testCase in disjointCases) {
      test(testCase.label, () {
        expect(
          isDisjointFrom<int>(
            Set<int>.of(testCase.firstMembers),
            Set<int>.of(testCase.secondMembers),
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
      const Set<int> firstMembers = <int>{1, 2};
      const Set<int> secondMembers = <int>{3, 4};
      const Set<int> overlapping = <int>{2, 3};
      expect(
        isDisjointFrom<int>(firstMembers, secondMembers),
        equals(isDisjointFrom<int>(secondMembers, firstMembers)),
      );
      expect(
        isDisjointFrom<int>(firstMembers, overlapping),
        equals(isDisjointFrom<int>(overlapping, firstMembers)),
      );
    });

    test('leaves both inputs untouched', () {
      final Set<int> firstMembers = <int>{1, 2};
      final Set<int> secondMembers = <int>{3, 4};
      final Set<int> firstSnapshot = Set<int>.of(firstMembers);
      final Set<int> secondSnapshot = Set<int>.of(secondMembers);
      isDisjointFrom<int>(firstMembers, secondMembers);
      expect(firstMembers.containsAll(firstSnapshot), isTrue);
      expect(secondMembers.containsAll(secondSnapshot), isTrue);
    });
  });

  group('hasSameMembers', () {
    final List<
      ({
        String label,
        Set<int> firstMembers,
        Set<int> secondMembers,
        bool expected,
      })
    >
    sameCases =
        <
          ({
            String label,
            Set<int> firstMembers,
            Set<int> secondMembers,
            bool expected,
          })
        >[
          (
            label: 'reports true for equal holdings in any order',
            firstMembers: <int>{1, 2, 3},
            secondMembers: <int>{3, 2, 1},
            expected: true,
          ),
          (
            label: 'reports true for two empty sides',
            firstMembers: <int>{},
            secondMembers: <int>{},
            expected: true,
          ),
          (
            label: 'reports false when one member differs',
            firstMembers: <int>{1, 2, 3},
            secondMembers: <int>{1, 2, 4},
            expected: false,
          ),
          (
            label: 'reports false when sizes differ',
            firstMembers: <int>{1, 2},
            secondMembers: <int>{1, 2, 3},
            expected: false,
          ),
          (
            label: 'reports false for empty against non-empty',
            firstMembers: <int>{},
            secondMembers: <int>{1},
            expected: false,
          ),
          (
            label: 'reports false for non-empty against empty',
            firstMembers: <int>{1},
            secondMembers: <int>{},
            expected: false,
          ),
        ];

    for (final testCase in sameCases) {
      test(testCase.label, () {
        expect(
          hasSameMembers<int>(
            Set<int>.of(testCase.firstMembers),
            Set<int>.of(testCase.secondMembers),
          ),
          equals(testCase.expected),
        );
      });
    }

    test('compares word holdings structurally, not by identity', () {
      final Set<String> firstMembers = <String>{'fig', 'pear'};
      final Set<String> secondMembers = <String>{'pear', 'fig'};
      expect(identical(firstMembers, secondMembers), isFalse);
      expect(hasSameMembers<String>(firstMembers, secondMembers), isTrue);
      expect(hasSameMembers<String>(firstMembers, {'fig'}), isFalse);
    });

    test('is symmetric across argument order', () {
      const Set<int> firstMembers = <int>{1, 2};
      const Set<int> secondMembers = <int>{2, 3};
      expect(
        hasSameMembers<int>(firstMembers, secondMembers),
        equals(hasSameMembers<int>(secondMembers, firstMembers)),
      );
    });

    test('leaves both inputs untouched', () {
      final Set<int> firstMembers = <int>{1, 2};
      final Set<int> secondMembers = <int>{2, 1};
      final Set<int> firstSnapshot = Set<int>.of(firstMembers);
      final Set<int> secondSnapshot = Set<int>.of(secondMembers);
      hasSameMembers<int>(firstMembers, secondMembers);
      expect(firstMembers.containsAll(firstSnapshot), isTrue);
      expect(secondMembers.containsAll(secondSnapshot), isTrue);
    });
  });

  group('documented examples', () {
    test('symmetricDifference example keeps either-side members', () {
      final difference = symmetricDifference(<int>{1, 2, 3}, <int>{3, 4});
      expect(difference.length, equals(3));
      expect(difference.containsAll(<int>{1, 2, 4}), isTrue);
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
