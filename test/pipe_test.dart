import 'package:praxis/src/pipe.dart';
import 'package:test/test.dart';

int addOne(int firstValue) => firstValue + 1;

int doubleValue(int pipedValue) => pipedValue * 2;

String showCount(int pipedValue) => 'count:$pipedValue';

void main() {
  group('pipe', () {
    test('applies the first step then the second step', () {
      final int Function(int) addOneThenDouble = pipe<int, int, int>(
        addOne,
        doubleValue,
      );
      expect(addOneThenDouble(3), equals(8));
    });

    test('threads types across a three-stage nested pipeline', () {
      final String Function(int) rendered = pipe<int, int, String>(
        pipe<int, int, int>(addOne, doubleValue),
        showCount,
      );
      expect(rendered(3), equals('count:8'));
    });

    test('runs legs left to right exactly once per call', () {
      final List<String> runningOrder = <String>[];
      final int Function(int) pipeline = pipe<int, int, int>(
        (int firstValue) {
          runningOrder.add('firstStep');
          return firstValue + 1;
        },
        (int pipedValue) {
          runningOrder.add('secondStep');
          return pipedValue * 2;
        },
      );
      expect(runningOrder, isEmpty);
      expect(pipeline(3), equals(8));
      expect(runningOrder, equals(<String>['firstStep', 'secondStep']));
    });

    test('re-runs both legs on every call without memoizing', () {
      int firstCalls = 0;
      int secondCalls = 0;
      final int Function(int) pipeline = pipe<int, int, int>(
        (int firstValue) {
          firstCalls += 1;
          return firstValue + 1;
        },
        (int pipedValue) {
          secondCalls += 1;
          return pipedValue * 2;
        },
      );
      expect(pipeline(1), equals(4));
      expect(pipeline(1), equals(4));
      expect(firstCalls, equals(2));
      expect(secondCalls, equals(2));
    });

    test('behaves as the second step beside an identity first step', () {
      final int Function(int) pipeline = pipe<int, int, int>(
        (int firstValue) => firstValue,
        doubleValue,
      );
      expect(pipeline(21), equals(42));
    });

    test('propagates a first-step failure before the second step runs', () {
      bool secondRan = false;
      final int Function(int) pipeline = pipe<int, int, int>(
        (int firstValue) => throw Exception('first step failed'),
        (int pipedValue) {
          secondRan = true;
          return pipedValue;
        },
      );
      expect(() => pipeline(0), throwsA(isA<Exception>()));
      expect(secondRan, isFalse);
    });

    test('propagates a second-step failure to the caller', () {
      bool firstRan = false;
      final int Function(int) pipeline = pipe<int, int, int>((int firstValue) {
        firstRan = true;
        return firstValue + 1;
      }, (int pipedValue) => throw Exception('second step failed'));
      expect(() => pipeline(0), throwsA(isA<Exception>()));
      expect(firstRan, isTrue);
    });
  });

  group('compose', () {
    test('applies the inner step then the outer step', () {
      final int Function(int) doubleAfterAddOne = compose<int, int, int>(
        doubleValue,
        addOne,
      );
      expect(doubleAfterAddOne(3), equals(8));
    });

    test('threads types across a three-stage nested composition', () {
      final String Function(int) rendered = compose<int, int, String>(
        showCount,
        compose<int, int, int>(doubleValue, addOne),
      );
      expect(rendered(3), equals('count:8'));
    });

    test('runs legs right to left exactly once per call', () {
      final List<String> runningOrder = <String>[];
      final int Function(int) pipeline = compose<int, int, int>(
        (int outerValue) {
          runningOrder.add('outerStep');
          return outerValue * 2;
        },
        (int innerValue) {
          runningOrder.add('innerStep');
          return innerValue + 1;
        },
      );
      expect(runningOrder, isEmpty);
      expect(pipeline(3), equals(8));
      expect(runningOrder, equals(<String>['innerStep', 'outerStep']));
    });

    test('re-runs both legs on every call without memoizing', () {
      int outerCalls = 0;
      int innerCalls = 0;
      final int Function(int) pipeline = compose<int, int, int>(
        (int outerValue) {
          outerCalls += 1;
          return outerValue * 2;
        },
        (int innerValue) {
          innerCalls += 1;
          return innerValue + 1;
        },
      );
      expect(pipeline(1), equals(4));
      expect(pipeline(1), equals(4));
      expect(outerCalls, equals(2));
      expect(innerCalls, equals(2));
    });

    test('behaves as the inner step beside an identity outer step', () {
      final int Function(int) pipeline = compose<int, int, int>(
        (int outerValue) => outerValue,
        addOne,
      );
      expect(pipeline(41), equals(42));
    });

    test('propagates an inner-step failure before the outer step runs', () {
      bool outerRan = false;
      final int Function(int) pipeline = compose<int, int, int>((
        int outerValue,
      ) {
        outerRan = true;
        return outerValue;
      }, (int innerValue) => throw Exception('inner step failed'));
      expect(() => pipeline(0), throwsA(isA<Exception>()));
      expect(outerRan, isFalse);
    });

    test('agrees with pipe on mirrored legs', () {
      final int Function(int) leftToRight = pipe<int, int, int>(
        addOne,
        doubleValue,
      );
      final int Function(int) rightToLeft = compose<int, int, int>(
        doubleValue,
        addOne,
      );
      for (final int candidate in <int>[0, 1, 7, 41]) {
        expect(rightToLeft(candidate), equals(leftToRight(candidate)));
      }
    });
  });
}
