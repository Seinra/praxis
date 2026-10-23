import 'package:praxis/src/opt.dart';
import 'package:test/test.dart';

void main() {
  group('Opt construction', () {
    test('present holds the given held value', () {
      const current = Opt.present(4);

      expect(current.isPresent, isTrue);
      expect(current.isAbsent, isFalse);
      expect(current.valueOr(0), equals(4));
    });

    test('absent holds nothing', () {
      const current = Opt<int>.absent();

      expect(current.isPresent, isFalse);
      expect(current.isAbsent, isTrue);
      expect(current.valueOr(9), equals(9));
    });

    test('present wrapping null stays present (flag, never the value)', () {
      const current = Opt<int?>.present(null);

      expect(current.isPresent, isTrue);
      expect(current.isAbsent, isFalse);
      final (heldValue, presentFlag) = current.split;
      expect(presentFlag, isTrue);
      expect(heldValue, isNull);
    });

    test('direct Some and None constructors agree with factories', () {
      const fromFactory = Opt.present(4);
      const direct = Some<int>(4);
      const absentFactory = Opt<int>.absent();
      const absentDirect = None<int>();

      expect(direct, equals(fromFactory));
      expect(absentDirect, equals(absentFactory));
    });
  });

  group('presence flags', () {
    final flagCases =
        <({String label, Opt<int> current, bool wantPresent, bool wantAbsent})>[
          (
            label: 'present reports present',
            current: const Opt.present(4),
            wantPresent: true,
            wantAbsent: false,
          ),
          (
            label: 'absent reports absent',
            current: const Opt<int>.absent(),
            wantPresent: false,
            wantAbsent: true,
          ),
        ];

    for (final flagCase in flagCases) {
      test(flagCase.label, () {
        expect(flagCase.current.isPresent, equals(flagCase.wantPresent));
        expect(flagCase.current.isAbsent, equals(flagCase.wantAbsent));
      });
    }
  });

  group('split record', () {
    test('present splits to the held value plus true', () {
      const current = Opt.present(4);

      final (heldValue, presentFlag) = current.split;

      expect(presentFlag, isTrue);
      expect(heldValue, equals(4));
    });

    test('absent splits to null plus false', () {
      const current = Opt<int>.absent();

      final (heldValue, presentFlag) = current.split;

      expect(presentFlag, isFalse);
      expect(heldValue, isNull);
    });

    test('present null still splits to true (never trust the value)', () {
      const current = Opt<int?>.present(null);

      final (heldValue, presentFlag) = current.split;

      expect(presentFlag, isTrue);
      expect(heldValue, isNull);
    });
  });

  group('mapValue transforms the present side', () {
    test('maps the held value on present', () {
      const current = Opt.present(4);

      final mapped = current.mapValue((heldValue) => heldValue + 1);

      expect(mapped.valueOr(0), equals(5));
    });

    test('changes the held type on present', () {
      const current = Opt.present(4);

      final mapped = current.mapValue((heldValue) => 'held $heldValue');

      expect(mapped.valueOr('missing'), equals('held 4'));
    });

    test('carries absence through without running transform', () {
      var ranTransform = false;
      const current = Opt<int>.absent();

      final mapped = current.mapValue((heldValue) {
        ranTransform = true;
        return heldValue + 1;
      });

      expect(mapped.isAbsent, isTrue);
      expect(ranTransform, isFalse);
      expect(mapped.valueOr(7), equals(7));
    });

    test('chains left to right', () {
      const current = Opt.present(5);

      final chained = current
          .mapValue((heldValue) => heldValue + 1)
          .mapValue((heldValue) => heldValue * 2);

      expect(chained.valueOr(0), equals(12));
    });

    test('leaves the original untouched', () {
      const current = Opt.present(4);

      current.mapValue((heldValue) => heldValue + 100);

      expect(current.valueOr(0), equals(4));
    });
  });

  group('andThen chains to the next Opt', () {
    test('binds the held value on present', () {
      const current = Opt.present(4);

      final chained = current.andThen(
        (heldValue) => Opt.present('bound $heldValue'),
      );

      expect(chained.valueOr('missing'), equals('bound 4'));
    });

    test('transform may yield absence on present', () {
      const current = Opt.present(4);

      final chained = current.andThen(
        (heldValue) => const Opt<String>.absent(),
      );

      expect(chained.isAbsent, isTrue);
    });

    test('short-circuits on absent without running transform', () {
      var ranTransform = false;
      const current = Opt<int>.absent();

      final chained = current.andThen((heldValue) {
        ranTransform = true;
        return Opt.present('$heldValue');
      });

      expect(chained.isAbsent, isTrue);
      expect(ranTransform, isFalse);
    });

    test('leaves the original untouched', () {
      const current = Opt.present(4);

      current.andThen((heldValue) => Opt.present(heldValue * 2));

      expect(current.valueOr(0), equals(4));
    });
  });

  group('valueOr recovers with an explicit fallback', () {
    final fallbackCases =
        <({String label, Opt<int> current, int fallback, int wantOutcome})>[
          (
            label: 'present ignores the fallback',
            current: const Opt.present(4),
            fallback: 9,
            wantOutcome: 4,
          ),
          (
            label: 'absent takes the fallback',
            current: const Opt<int>.absent(),
            fallback: 9,
            wantOutcome: 9,
          ),
        ];

    for (final fallbackCase in fallbackCases) {
      test(fallbackCase.label, () {
        expect(
          fallbackCase.current.valueOr(fallbackCase.fallback),
          equals(fallbackCase.wantOutcome),
        );
      });
    }
  });

  group('valueOrElse recovers with a lazy fallback', () {
    test('present skips the fallback without running it', () {
      var ranFallback = false;
      const current = Opt.present(5);

      final outcome = current.valueOrElse(() {
        ranFallback = true;
        return 9;
      });

      expect(outcome, equals(5));
      expect(ranFallback, isFalse);
    });

    test('absent runs the fallback', () {
      const current = Opt<int>.absent();

      final outcome = current.valueOrElse(() => 9);

      expect(outcome, equals(9));
    });
  });

  group('orElse falls back to another Opt', () {
    final orElseCases =
        <
          ({
            String label,
            Opt<int> current,
            Opt<int> fallback,
            int wantOutcome,
            bool wantPresent,
          })
        >[
          (
            label: 'present plus present keeps current',
            current: const Opt.present(1),
            fallback: const Opt.present(2),
            wantOutcome: 1,
            wantPresent: true,
          ),
          (
            label: 'absent plus present takes fallback',
            current: const Opt<int>.absent(),
            fallback: const Opt.present(2),
            wantOutcome: 2,
            wantPresent: true,
          ),
          (
            label: 'present plus absent keeps current',
            current: const Opt.present(1),
            fallback: const Opt<int>.absent(),
            wantOutcome: 1,
            wantPresent: true,
          ),
          (
            label: 'absent plus absent stays absent',
            current: const Opt<int>.absent(),
            fallback: const Opt<int>.absent(),
            wantOutcome: 0,
            wantPresent: false,
          ),
        ];

    for (final orElseCase in orElseCases) {
      test(orElseCase.label, () {
        final combined = orElseCase.current.orElse(orElseCase.fallback);

        expect(combined.isPresent, equals(orElseCase.wantPresent));
        expect(combined.valueOr(0), equals(orElseCase.wantOutcome));
      });
    }

    test('leaves the original untouched', () {
      const current = Opt<int>.absent();

      current.orElse(const Opt.present(2));

      expect(current.isAbsent, isTrue);
    });
  });

  group('purity pins', () {
    test('combinators never mutate the original', () {
      const current = Opt.present(4);

      current.mapValue((heldValue) => heldValue + 1);
      current.andThen((heldValue) => Opt.present(heldValue * 2));
      current.orElse(const Opt.present(9));

      expect(current.isPresent, isTrue);
      expect(current.valueOr(0), equals(4));
    });

    test('held mutable values keep identity and contents', () {
      final heldItems = <int>[1, 2];
      final current = Opt.present(heldItems);

      final mapped = current.mapValue((items) => items.length);

      expect(mapped.valueOr(0), equals(2));
      expect(current.valueOr(const <int>[]), same(heldItems));
      expect(heldItems, equals(<int>[1, 2]));
    });
  });

  group('equality and rendering', () {
    test('same held values compare equal with matching hash codes', () {
      const first = Opt.present(4);
      const second = Opt.present(4);

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
    });

    test('absent compares equal to absent', () {
      const first = Opt<int>.absent();
      const second = Opt<int>.absent();

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
    });

    test('present never equals absent', () {
      final present = Opt.present(4);
      final absent = Opt<int>.absent();

      expect(present == absent, isFalse);
      expect(present, isNot(equals(absent)));
    });

    test('renders present and absent for debugging', () {
      expect(const Opt.present(4).toString(), equals('Some(4)'));
      expect(const Opt<int>.absent().toString(), equals('None()'));
    });
  });

  group('sealed patterns', () {
    test('switch over the hierarchy is exhaustive', () {
      String describe(Opt<int> current) => switch (current) {
        Some(heldValue: final held) => 'present $held',
        None() => 'absent',
      };

      expect(describe(const Opt.present(4)), equals('present 4'));
      expect(describe(const Opt<int>.absent()), equals('absent'));
    });
  });

  group('documented examples', () {
    test('construction examples hold', () {
      const held = Opt.present(4);
      const missing = Opt<int>.absent();

      expect(held.isPresent, isTrue);
      expect(held.valueOr(0), equals(4));
      expect(missing.isAbsent, isTrue);
      expect(missing.valueOr(9), equals(9));
    });

    test('presence examples hold', () {
      expect(const Opt.present(4).isPresent, isTrue);
      expect(const Opt<int>.absent().isPresent, isFalse);
      expect(const Opt.present(4).isAbsent, isFalse);
      expect(const Opt<int>.absent().isAbsent, isTrue);
    });

    test('split examples hold', () {
      final (heldValue, presentFlag) = const Opt.present(4).split;
      expect(presentFlag, isTrue);
      expect(heldValue, equals(4));

      final (absentValue, absentFlag) = const Opt<int>.absent().split;
      expect(absentFlag, isFalse);
      expect(absentValue, isNull);
    });

    test('mapValue examples hold', () {
      final mapped = const Opt.present(4)
          .mapValue((heldValue) => heldValue + 1);
      expect(mapped.valueOr(0), equals(5));

      final carried = const Opt<int>.absent().mapValue(
        (heldValue) => heldValue + 1,
      );
      expect(carried.isAbsent, isTrue);
    });

    test('andThen examples hold', () {
      final chained = const Opt.present(4)
          .andThen((heldValue) => Opt.present('bound $heldValue'));
      expect(chained.valueOr('missing'), equals('bound 4'));

      final carried = const Opt<int>.absent().andThen(
        (heldValue) => Opt.present('$heldValue'),
      );
      expect(carried.isAbsent, isTrue);
    });

    test('recovery examples hold', () {
      expect(const Opt.present(4).valueOr(9), equals(4));
      expect(const Opt<int>.absent().valueOr(9), equals(9));
      expect(const Opt.present(5).valueOrElse(() => 9), equals(5));
      expect(const Opt<int>.absent().valueOrElse(() => 9), equals(9));
      expect(
        const Opt.present(1).orElse(const Opt.present(2)).valueOr(0),
        equals(1),
      );
      expect(
        const Opt<int>.absent().orElse(const Opt.present(2)).valueOr(0),
        equals(2),
      );
    });
  });
}
