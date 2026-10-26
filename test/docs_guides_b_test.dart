import 'dart:async';

import 'package:praxis/praxis.dart';
import 'package:test/test.dart';

/// Companion suite for the T2 docs unit (`docs/guides/` set B).
///
/// Each group replays the runnable example from one guide and hand-asserts
/// the EXACT outputs shown there (Axiom `guides_test.go` pattern: mirror,
/// never copy). A green run means every printed output in the seven guides
/// is evidence-backed by `lib/` behavior.
void main() {
  group('guide valid (docs/guides/valid.md)', () {
    test('composed predicates report the guide outputs', () {
      final Predicate<int> isPositiveEven = andPredicates<int>(<Predicate<int>>[
        (int candidate) => candidate > 0,
        (int candidate) => candidate.isEven,
      ]);
      expect(isPositiveEven(4), isTrue);
      expect(isPositiveEven(-4), isFalse);

      final Predicate<int> isZeroOrEven = orPredicates<int>(<Predicate<int>>[
        (int candidate) => candidate == 0,
        (int candidate) => candidate.isEven,
      ]);
      expect(isZeroOrEven(3), isFalse);
      expect(isZeroOrEven(4), isTrue);

      final Predicate<int> isOdd = notPredicate<int>(
        (int candidate) => candidate.isEven,
      );
      expect(isOdd(3), isTrue);
    });
  });

  group('guide strings (docs/guides/strings.md)', () {
    test('rune helpers report the guide outputs', () {
      final List<String> words = splitWords('  go   rust\tzig\n');
      expect(words, equals(<String>['go', 'rust', 'zig']));

      final List<String> chunks = chunkString('héllo', 2);
      expect(chunks, equals(<String>['hé', 'll', 'o']));

      expect(truncateRunes('héllo', 2), equals('hé'));
      expect(takeRunes('héllo', 2), equals('hé'));
      expect(dropRunes('héllo', 2), equals('llo'));

      final String kept = truncateWithEllipsis('héllo world', 8);
      expect(kept, equals('héllo w…'));
      expect(defaultEllipsisMark, equals('…'));
    });
  });

  group('guide mathx (docs/guides/mathx.md)', () {
    test('number-theory helpers report the guide outputs', () {
      expect(isPrime(7), isTrue);
      expect(isPrime(9), isFalse);

      final List<int> primes = primesUpTo(10);
      expect(primes, equals(<int>[2, 3, 5, 7]));

      expect(lcm(4, 6), equals(12));
      expect(lcm(0, 5), equals(0));
    });
  });

  group('guide flow (docs/guides/flow.md)', () {
    test('bounded combinators report the guide outputs', () async {
      final List<int> doubledOutputs = await flowMap<int, int>(
        <int>[1, 2, 3],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) async =>
            candidateInput * 2,
      );
      expect(doubledOutputs, equals(<int>[2, 4, 6]));

      final int winnerOutput = await flowFirst<int, int>(
        <int>[1, 2, 3],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) async {
          if (candidateInput != 1) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          return candidateInput * 10;
        },
      );
      expect(winnerOutput, equals(10));

      final List<Result<int>> collectedOutcomes = await flowCollect<int, int>(
        <int>[1, 2],
        maxInflight: 2,
        transform: (int candidateInput, FlowScope scope) async =>
            candidateInput * 2,
      ).toList();
      expect(collectedOutcomes.length, equals(2));
      expect(
        collectedOutcomes.every((Result<int> outcome) => outcome.isOk),
        isTrue,
      );
    });
  });

  group('guide pool (docs/guides/pool.md)', () {
    test('borrow and scoped use report the guide outputs', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        reset: (StringBuffer borrowedValue) => borrowedValue.clear(),
        maxSize: 2,
      );
      final StringBuffer borrowedBuffer = bufferPool.acquire();
      borrowedBuffer.write('hi');
      bufferPool.release(borrowedBuffer);
      expect(bufferPool.idleCount, equals(1));

      final String greeting = bufferPool.use<String>((
        StringBuffer borrowedValue,
      ) {
        borrowedValue.write('hi');
        return borrowedValue.toString();
      });
      expect(greeting, equals('hi'));
    });
  });

  group('guide singleflight (docs/guides/singleflight.md)', () {
    test('same-key callers share one execution', () async {
      final SingleflightGroup<String, int> flightGroup =
          SingleflightGroup<String, int>();
      int executionCount = 0;
      Future<int> loadUser() => flightGroup.call('user:7', () async {
        executionCount += 1;
        return 42;
      });
      final List<int> sharedResults = await Future.wait(<Future<int>>[
        loadUser(),
        loadUser(),
      ]);
      expect(sharedResults, equals(<int>[42, 42]));
      expect(executionCount, equals(1));
    });
  });

  group('guide di (docs/guides/di.md)', () {
    test('named singletons resolve, drop, and reset', () {
      final ServiceContainer services = ServiceContainer();
      services.register<String>('greeting', () => 'hello');
      services.register<int>('answer', () => 42);
      expect(services.resolve<String>('greeting'), equals('hello'));
      expect(services.resolve<int>('answer'), equals(42));

      services.unregister('greeting');
      expect(services.resolve<int>('answer'), equals(42));
      expect(() => services.resolve<String>('greeting'), throwsStateError);
      services.reset();
      expect(() => services.resolve<int>('answer'), throwsStateError);
    });
  });
}
