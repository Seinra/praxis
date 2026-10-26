/// Integer number-theory helpers over [int], layered on `dart:core`.
///
/// Reach for these when the question is pure number theory over a whole
/// number: testing primality, listing the primes up to a bound, or
/// combining two numbers into their least common multiple. Reach for the
/// SDK directly when it already names the operation ([int.abs],
/// [int.compareTo], `~/`, `%`, [int.gcd], and `dart:math`
/// `max`/`min`/`pow`/`sqrt`): this package never reimplements SDK-owned
/// surface. Every helper is pure: integers travel by value and the one
/// list returned is always fresh.
///
/// Which function?
///
/// | When you want to ...                                  | Reach for ... |
/// | ----------------------------------------------------- | ------------- |
/// | Test whether a whole number is prime                  | [isPrime]     |
/// | List the primes up to a bound, inclusive              | [primesUpTo]  |
/// | Combine two whole numbers into their shared multiple  | [lcm]         |
///
/// YAGNI kills (DART-SDK): [int.gcd] owns the greatest common divisor
/// (verified `12.gcd(18) == 6` with the `(0, 0) == 0` convention), so no
/// wrapper ships here and [lcm] reuses it; [int.abs], [int.compareTo],
/// `~/`, and `%` own their arithmetic, and `dart:math` owns
/// `max`/`min`/`pow`/`sqrt`, so none of those are wrapped either.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
library;

/// Reports whether [candidate] is a prime number.
///
/// | When you want to ...                 | Reach for ... |
/// | ------------------------------------ | ------------- |
/// | Test whether a whole number is prime | [isPrime]     |
///
/// `dart:core` and `dart:math` name no primality test: [int] answers
/// remainder questions (`%`, `~/`) but never asks them, and `dart:math`
/// owns only continuous helpers (`max`, `min`, `pow`, `sqrt`)
/// (DART-SDK). [isPrime] fills that gap with trial division over odd
/// divisors up to the square root, written as
/// `divisor <= candidate ~/ divisor` so the bound itself cannot overflow,
/// mirroring the Axiom `mathx` precedent where values below two yield
/// false and the even fast-path skips the loop (AXIOM-SISTER).
///
/// Values below `2` (including negatives, zero, and one) yield `false`:
/// there is no divisor story to tell there. Two yields `true`; every
/// other even yields `false` without looping. Never throws: below-two
/// input is a normal outcome, not a programmer error.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final bool seven = isPrime(7);
/// print(seven); // true
///
/// final bool nine = isPrime(9);
/// print(nine); // false
/// ```
bool isPrime(int candidate) {
  if (candidate < 2) {
    return false;
  }
  if (candidate == 2) {
    return true;
  }
  if (candidate % 2 == 0) {
    return false;
  }
  for (int divisor = 3; divisor <= candidate ~/ divisor; divisor += 2) {
    if (candidate % divisor == 0) {
      return false;
    }
  }
  return true;
}

/// Lists the prime numbers from `2` up to [upperBound], inclusive.
///
/// | When you want to ...                     | Reach for ... |
/// | ---------------------------------------- | ------------- |
/// | List the primes up to a bound, inclusive | [primesUpTo]  |
///
/// `dart:core` and `dart:math` name no prime sieve: [int] answers
/// remainder questions but never enumerates primes (DART-SDK).
/// [primesUpTo] fills that gap with one sieve pass reusing the overflow-safe
/// bound idiom (marking from `divisor * divisor` while
/// `divisor <= upperBound ~/ divisor`, so the start of each marking run
/// always fits). Axiom ships no sieve at all
/// (`IsPrime`/`Gcd`/`Lcm` only), so this extends the same discipline to
/// generation with an explicit bound contract (AXIOM-SISTER).
///
/// Throws an [ArgumentError] when [upperBound] is negative: a negative
/// bound is a programmer error, not a domain outcome. Bounds `0` and `1`
/// yield a fresh empty list. Allocates one flag per integer up to
/// [upperBound], so callers cap bounds from untrusted input instead of
/// sieving them raw. Returns a fresh list on every call.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final List<int> primes = primesUpTo(10);
/// print(primes); // [2, 3, 5, 7]
/// ```
List<int> primesUpTo(int upperBound) {
  if (upperBound < 0) {
    throw ArgumentError.value(
      upperBound,
      'upperBound',
      'needs upperBound >= 0',
    );
  }
  if (upperBound < 2) {
    return <int>[];
  }
  final List<bool> isComposite = List<bool>.filled(upperBound + 1, false);
  for (int divisor = 2; divisor <= upperBound ~/ divisor; divisor++) {
    if (!isComposite[divisor]) {
      for (
        int multiple = divisor * divisor;
        multiple <= upperBound;
        multiple += divisor
      ) {
        isComposite[multiple] = true;
      }
    }
  }
  final List<int> primes = <int>[];
  for (int candidate = 2; candidate <= upperBound; candidate++) {
    if (!isComposite[candidate]) {
      primes.add(candidate);
    }
  }
  return primes;
}

/// Returns the least common multiple of [firstNumber] and [secondNumber].
///
/// | When you want to ...                                 | Reach for ... |
/// | ---------------------------------------------------- | ------------- |
/// | Combine two whole numbers into their shared multiple | [lcm]         |
///
/// `dart:core` names no least common multiple: [int.gcd] owns only the
/// greatest common divisor (DART-SDK). [lcm] fills that gap by factoring
/// out that [int.gcd] divisor first and dividing before multiplying, so
/// pairs whose naive product overflows still land exact when the true
/// multiple fits, mirroring the Axiom `mathx` divide-before-multiply
/// discipline (AXIOM-SISTER).
///
/// Either input zero yields zero (so `lcm(0, 0)` is `0` by convention,
/// never a division-by-zero). Negative inputs yield a non-negative
/// multiple. When the true multiple exceeds the 64-bit range the result
/// follows Dart [int] wrap semantics; callers past that range reach for
/// [BigInt] instead. Never throws for domain inputs.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final int shared = lcm(4, 6);
/// print(shared); // 12
///
/// final int absent = lcm(0, 5);
/// print(absent); // 0
/// ```
int lcm(int firstNumber, int secondNumber) {
  if (firstNumber == 0 || secondNumber == 0) {
    return 0;
  }
  final int divisor = firstNumber.gcd(secondNumber);
  return (firstNumber ~/ divisor * secondNumber).abs();
}
