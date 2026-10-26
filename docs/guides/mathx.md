# mathx — primality, prime lists, and least common multiples

You ask pure number-theory questions over whole numbers: `isPrime` tests
primality, `primesUpTo` lists the primes up to an inclusive bound, and `lcm`
combines two numbers into their least common multiple. You pass integers by
value and receive a fresh list back, so every helper stays pure.

**Version:** Praxis `0.1.0`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';`. You hold the candidate
integer or the bound to sieve up to.

## Quick path

1. Test one number: `isPrime(7)`.
2. List the primes up to a bound: `primesUpTo(10)`.
3. Combine two numbers: `lcm(4, 6)`.

## Which function?

The package doc (`lib/src/mathx.dart`) is the source; this table mirrors its
"Which function?" table:

| When you want to ...                                  | Reach for ... |
| ----------------------------------------------------- | ------------- |
| Test whether a whole number is prime                  | [isPrime]     |
| List the primes up to a bound, inclusive              | [primesUpTo]  |
| Combine two whole numbers into their shared multiple  | [lcm]         |

## Example

Runnable — asserted by `test/docs_guides_b_test.dart` (same outputs):

```dart
import 'package:praxis/praxis.dart';

void main() {
  print(isPrime(7)); // true
  print(isPrime(9)); // false

  final List<int> primes = primesUpTo(10);
  print(primes); // [2, 3, 5, 7]

  print(lcm(4, 6)); // 12
  print(lcm(0, 5)); // 0
}
```

Expected output:

```text
true
false
[2, 3, 5, 7]
12
0
```

Values below `2` (including negatives, zero, and one) yield `false` from
`isPrime` — there is no divisor story to tell there, so below-two input is
a normal outcome, never a throw. Bounds `0` and `1` yield a fresh empty
list from `primesUpTo`. Either `lcm` input zero yields zero by convention.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| Below-two is `false`, never a throw | `isPrime` over negatives, `0`, or `1` reports `false`; `2` yields `true` and other evens skip the loop. |
| Bounds are inclusive, negatives throw | `primesUpTo(10)` includes `10` when prime; a negative bound throws `ArgumentError` because it is a programmer error. Bounds `0` and `1` yield a fresh empty list. |
| Zero in, zero out for `lcm` | `lcm(0, 5)` is `0`, and `lcm(0, 0)` is `0` by convention — never a division-by-zero. Negatives yield a non-negative multiple. |
| `int.gcd` stays the divisor | This package never wraps `int.gcd`: `lcm` reuses it and divides before multiplying, so pairs whose naive product overflows still land exact when the true multiple fits. |
| Fresh lists, pure calls | `primesUpTo` returns a fresh list on every call; nothing here mutates input. |

> [!WARNING]
> `primesUpTo` allocates one flag per integer up to the bound, so you cap
> bounds from untrusted input before sieving them raw. And when the true
> multiple exceeds the 64-bit range, `lcm` follows Dart `int` wrap semantics
> — you reach for `BigInt` past that range instead.

## When to use the stdlib directly

You stay with `dart:core` and `dart:math` when they already name the
operation: `int.gcd` owns the greatest common divisor, `int.abs`,
`int.compareTo`, `~/`, and `%` own their arithmetic, and `dart:math` owns
`max`, `min`, `pow`, and `sqrt`. None of those are wrapped here. You reach
for `mathx` when the question is primality, prime generation, or the shared
multiple the SDK never names.

## Next step

When prime work fans out — testing many candidates or combining many pairs
— you keep the helpers pure and run them under `flowMap` with an in-flight
cap instead of sequential loops. See `docs/guides/flow.md`.
