import 'package:praxis/src/mathx.dart';
import 'package:test/test.dart';

void main() {
  group('isPrime', () {
    test('reports small primes as prime', () {
      for (final int prime in <int>[2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]) {
        expect(isPrime(prime), isTrue, reason: 'isPrime($prime)');
      }
    });

    test('reports composites as not prime', () {
      for (final int composite in <int>[
        4,
        6,
        8,
        9,
        10,
        12,
        15,
        21,
        25,
        27,
        49,
        100,
      ]) {
        expect(isPrime(composite), isFalse, reason: 'isPrime($composite)');
      }
    });

    test('reports below-two inputs as not prime', () {
      for (final int candidate in <int>[-17, -2, -1, 0, 1]) {
        expect(isPrime(candidate), isFalse, reason: 'isPrime($candidate)');
      }
    });

    test('reports two as prime and other evens as not prime', () {
      expect(isPrime(2), isTrue);
      expect(isPrime(1000000), isFalse);
      expect(isPrime(104730), isFalse);
    });

    test('reports a large prime as prime', () {
      expect(isPrime(104729), isTrue);
    });

    test('reports prime squares as composite', () {
      expect(isPrime(49), isFalse);
      expect(isPrime(121), isFalse);
    });

    test('is pure across repeated calls', () {
      expect(isPrime(104729), equals(isPrime(104729)));
      expect(isPrime(9), equals(isPrime(9)));
    });
  });

  group('primesUpTo', () {
    test('lists the primes up to ten', () {
      expect(primesUpTo(10), equals(<int>[2, 3, 5, 7]));
    });

    test('lists the primes up to thirty', () {
      expect(primesUpTo(30), equals(<int>[2, 3, 5, 7, 11, 13, 17, 19, 23, 29]));
    });

    test('keeps an inclusive prime bound', () {
      expect(primesUpTo(13).last, equals(13));
      expect(primesUpTo(14), equals(primesUpTo(13)));
    });

    test('returns two alone at the smallest prime bound', () {
      expect(primesUpTo(2), equals(<int>[2]));
    });

    test('returns empty below the smallest prime', () {
      expect(primesUpTo(0), isEmpty);
      expect(primesUpTo(1), isEmpty);
    });

    test('counts twenty-five primes up to one hundred', () {
      final List<int> primes = primesUpTo(100);
      expect(primes.length, equals(25));
      expect(primes.first, equals(2));
      expect(primes.last, equals(97));
    });

    test('rejects a negative bound', () {
      expect(() => primesUpTo(-1), throwsArgumentError);
      expect(() => primesUpTo(-17), throwsArgumentError);
    });

    test('returns a fresh list that never aliases', () {
      final List<int> firstCall = primesUpTo(10);
      firstCall.add(999);
      expect(primesUpTo(10), equals(<int>[2, 3, 5, 7]));
    });
  });

  group('lcm', () {
    test('combines four and six into twelve', () {
      expect(lcm(4, 6), equals(12));
    });

    test('combines coprime pairs into their product', () {
      expect(lcm(7, 13), equals(91));
    });

    test('returns the larger when one divides the other', () {
      expect(lcm(6, 12), equals(12));
      expect(lcm(6, 6), equals(6));
    });

    test('returns zero when either side is zero', () {
      expect(lcm(0, 5), equals(0));
      expect(lcm(5, 0), equals(0));
      expect(lcm(0, 0), equals(0));
    });

    test('returns a non-negative multiple for negative inputs', () {
      expect(lcm(-4, 6), equals(12));
      expect(lcm(4, -6), equals(12));
      expect(lcm(-4, -6), equals(12));
    });

    test('divides before multiplying on overflow-adjacent pairs', () {
      const int firstNumber = 1 << 32;
      const int secondNumber = 3 << 32;
      expect(lcm(firstNumber, secondNumber), equals(3 << 32));
    });

    test('agrees with the gcd-factored definition', () {
      for (final (int, int) pair in <(int, int)>[(12, 18), (21, 6), (35, 49)]) {
        final int firstNumber = pair.$1;
        final int secondNumber = pair.$2;
        final int divisor = firstNumber.gcd(secondNumber);
        final int expected = divisor == 0
            ? 0
            : (firstNumber ~/ divisor * secondNumber).abs();
        expect(
          lcm(firstNumber, secondNumber),
          equals(expected),
          reason: 'lcm($firstNumber, $secondNumber)',
        );
      }
    });

    test('is pure across repeated calls', () {
      expect(lcm(4, 6), equals(lcm(4, 6)));
      expect(lcm(-4, 6), equals(12));
    });
  });

  group('documented examples', () {
    test('isPrime example answers seven, nine, and one', () {
      expect(isPrime(7), isTrue);
      expect(isPrime(9), isFalse);
      expect(isPrime(1), isFalse);
    });

    test('primesUpTo example lists primes up to ten', () {
      expect(primesUpTo(10), equals(<int>[2, 3, 5, 7]));
    });

    test('lcm example combines four and six with a zero case', () {
      expect(lcm(4, 6), equals(12));
      expect(lcm(0, 5), equals(0));
    });

    test('lcm example stays exact on overflow-adjacent pairs', () {
      expect(lcm(1 << 32, 3 << 32), equals(3 << 32));
    });
  });
}
