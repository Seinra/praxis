import 'package:praxis/src/pool.dart';
import 'package:test/test.dart';

void main() {
  group('Pool.new', () {
    test('documents maxSize and starts idle empty', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        maxSize: 2,
      );
      expect(bufferPool.maxSize, equals(2));
      expect(bufferPool.idleCount, equals(0));
    });

    test('zero and negative caps throw ArgumentError', () {
      Pool<StringBuffer> buildWithCap(int capValue) =>
          Pool<StringBuffer>(create: StringBuffer.new, maxSize: capValue);

      expect(() => buildWithCap(0), throwsArgumentError);
      expect(() => buildWithCap(-2), throwsArgumentError);
    });
  });

  group('Pool.acquire', () {
    test('empty pool creates via factory', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        maxSize: 2,
      );
      final StringBuffer borrowedBuffer = bufferPool.acquire();
      borrowedBuffer.write('hi');
      expect(borrowedBuffer.toString(), equals('hi'));
    });

    test('exhausted idle creates fresh via factory', () {
      int factoryCalls = 0;
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: () {
          factoryCalls += 1;
          return StringBuffer();
        },
        maxSize: 2,
      );
      final StringBuffer firstBorrowed = bufferPool.acquire();
      final StringBuffer secondBorrowed = bufferPool.acquire();
      expect(factoryCalls, equals(2));
      expect(identical(firstBorrowed, secondBorrowed), isFalse);
    });

    test('factory throws propagate with nothing stored', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: () => throw StateError('factory offline'),
        maxSize: 2,
      );
      expect(bufferPool.acquire, throwsStateError);
      expect(bufferPool.idleCount, equals(0));
    });
  });

  group('Pool.release', () {
    test('released value is reused not copied', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        maxSize: 2,
      );
      final StringBuffer firstBorrowed = bufferPool.acquire();
      bufferPool.release(firstBorrowed);
      expect(bufferPool.idleCount, equals(1));
      final StringBuffer secondBorrowed = bufferPool.acquire();
      expect(identical(firstBorrowed, secondBorrowed), isTrue);
      expect(bufferPool.idleCount, equals(0));
    });

    test('reset runs on release before idle storage', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        reset: (StringBuffer borrowedValue) => borrowedValue.clear(),
        maxSize: 2,
      );
      final StringBuffer borrowedBuffer = bufferPool.acquire();
      borrowedBuffer.write('hi');
      bufferPool.release(borrowedBuffer);
      final StringBuffer recycledBuffer = bufferPool.acquire();
      expect(recycledBuffer.toString(), isEmpty);
      expect(identical(recycledBuffer, borrowedBuffer), isTrue);
    });

    test('without reset the released content is preserved', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        maxSize: 2,
      );
      final StringBuffer borrowedBuffer = bufferPool.acquire();
      borrowedBuffer.write('hi');
      bufferPool.release(borrowedBuffer);
      final StringBuffer recycledBuffer = bufferPool.acquire();
      expect(recycledBuffer.toString(), equals('hi'));
    });

    test('double-release throws ArgumentError and keeps single idle', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        maxSize: 2,
      );
      final StringBuffer borrowedBuffer = bufferPool.acquire();
      bufferPool.release(borrowedBuffer);
      expect(() => bufferPool.release(borrowedBuffer), throwsArgumentError);
      expect(bufferPool.idleCount, equals(1));
    });

    test('full idle discards the extra value', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        maxSize: 1,
      );
      final StringBuffer firstBorrowed = bufferPool.acquire();
      final StringBuffer secondBorrowed = bufferPool.acquire();
      expect(identical(firstBorrowed, secondBorrowed), isFalse);
      bufferPool.release(firstBorrowed);
      expect(bufferPool.idleCount, equals(1));
      bufferPool.release(secondBorrowed);
      expect(bufferPool.idleCount, equals(1));
      final StringBuffer thirdBorrowed = bufferPool.acquire();
      expect(identical(thirdBorrowed, firstBorrowed), isTrue);
    });

    test('reset throws propagate and discard the value', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        reset: (StringBuffer borrowedValue) {
          throw StateError('reset offline');
        },
        maxSize: 2,
      );
      final StringBuffer borrowedBuffer = bufferPool.acquire();
      expect(() => bufferPool.release(borrowedBuffer), throwsStateError);
      expect(bufferPool.idleCount, equals(0));
    });
  });

  group('Pool.use', () {
    test('runs the action and returns its result', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        reset: (StringBuffer borrowedValue) => borrowedValue.clear(),
        maxSize: 2,
      );
      final String greeting = bufferPool.use<String>((
        StringBuffer borrowedValue,
      ) {
        borrowedValue.write('hi');
        return borrowedValue.toString();
      });
      expect(greeting, equals('hi'));
      expect(bufferPool.idleCount, equals(1));
    });

    test('action throws still release when reset succeeds', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        reset: (StringBuffer borrowedValue) => borrowedValue.clear(),
        maxSize: 2,
      );
      expect(
        () => bufferPool.use<String>((StringBuffer borrowedValue) {
          borrowedValue.write('hi');
          throw StateError('action offline');
        }),
        throwsStateError,
      );
      expect(bufferPool.idleCount, equals(1));
      final StringBuffer recycledBuffer = bufferPool.acquire();
      expect(recycledBuffer.toString(), isEmpty);
    });

    test('reset throws during use discard the value', () {
      final Pool<StringBuffer> bufferPool = Pool<StringBuffer>(
        create: StringBuffer.new,
        reset: (StringBuffer borrowedValue) {
          throw StateError('reset offline');
        },
        maxSize: 2,
      );
      expect(
        () => bufferPool.use<String>((StringBuffer borrowedValue) => 'hi'),
        throwsStateError,
      );
      expect(bufferPool.idleCount, equals(0));
    });
  });
}
