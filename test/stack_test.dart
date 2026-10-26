import 'package:praxis/src/stack.dart';
import 'package:test/test.dart';

void main() {
  group('Stack.push and Stack.pop', () {
    test('pops pushed values last-in first-out', () {
      final Stack<int> heldScores = Stack<int>();
      heldScores.push(1);
      heldScores.push(2);
      heldScores.push(3);
      final ({int? value, bool present}) thirdPopped = heldScores.pop();
      expect(thirdPopped.present, isTrue);
      expect(thirdPopped.value, equals(3));
      final ({int? value, bool present}) secondPopped = heldScores.pop();
      expect(secondPopped.present, isTrue);
      expect(secondPopped.value, equals(2));
      final ({int? value, bool present}) firstPopped = heldScores.pop();
      expect(firstPopped.present, isTrue);
      expect(firstPopped.value, equals(1));
    });

    test('reports absent instead of throwing on an empty stack', () {
      final Stack<int> heldScores = Stack<int>();
      final ({int? value, bool present}) popped = heldScores.pop();
      expect(popped.present, isFalse);
      expect(popped.value, isNull);
    });

    test('keeps a pushed null distinct from an absent pop', () {
      final Stack<int?> heldScores = Stack<int?>();
      heldScores.push(null);
      final ({int? value, bool present}) popped = heldScores.pop();
      expect(popped.present, isTrue);
      expect(popped.value, isNull);
    });

    test('drains to empty through repeated pops', () {
      final Stack<String> heldWords = Stack<String>();
      heldWords.push('fig');
      heldWords.push('pear');
      heldWordsPopAll(heldWords);
      expect(heldWords.isEmpty, isTrue);
      final ({String? value, bool present}) popped = heldWords.pop();
      expect(popped.present, isFalse);
    });

    test('leaves the filling list untouched', () {
      final List<int> sourceScores = <int>[1, 2, 3];
      final List<int> snapshotScores = List<int>.of(sourceScores);
      final Stack<int> heldScores = Stack<int>();
      for (final int score in sourceScores) {
        heldScores.push(score);
      }
      while (heldScores.isNotEmpty) {
        heldScores.pop();
      }
      expect(sourceScores, equals(snapshotScores));
    });
  });

  group('Stack.peek', () {
    test('reads the top value without removing it', () {
      final Stack<int> heldScores = Stack<int>();
      heldScores.push(72);
      heldScores.push(91);
      final ({int? value, bool present}) topScore = heldScores.peek();
      expect(topScore.present, isTrue);
      expect(topScore.value, equals(91));
      expect(heldScores.length, equals(2));
      final ({int? value, bool present}) topAgain = heldScores.peek();
      expect(topAgain.value, equals(91));
      expect(heldScores.length, equals(2));
    });

    test('reports absent instead of throwing on an empty stack', () {
      final Stack<int> heldScores = Stack<int>();
      final ({int? value, bool present}) topScore = heldScores.peek();
      expect(topScore.present, isFalse);
      expect(topScore.value, isNull);
    });

    test('tracks the top across interleaved pushes and pops', () {
      final Stack<int> heldScores = Stack<int>();
      heldScores.push(1);
      heldScores.push(2);
      expect(heldScores.peek().value, equals(2));
      heldScores.pop();
      expect(heldScores.peek().value, equals(1));
      heldScores.push(3);
      expect(heldScores.peek().value, equals(3));
    });
  });

  group('Stack.length and emptiness', () {
    test('starts empty with zero length', () {
      final Stack<int> heldScores = Stack<int>();
      expect(heldScores.length, equals(0));
      expect(heldScores.isEmpty, isTrue);
      expect(heldScores.isNotEmpty, isFalse);
    });

    test('counts pushes and pops', () {
      final Stack<int> heldScores = Stack<int>();
      heldScores.push(1);
      expect(heldScores.length, equals(1));
      expect(heldScores.isEmpty, isFalse);
      expect(heldScores.isNotEmpty, isTrue);
      heldScores.push(2);
      expect(heldScores.length, equals(2));
      heldScores.pop();
      expect(heldScores.length, equals(1));
      heldScores.pop();
      expect(heldScores.length, equals(0));
      expect(heldScores.isEmpty, isTrue);
    });

    test('empty pops never drive the length negative', () {
      final Stack<int> heldScores = Stack<int>();
      heldScores.pop();
      heldScores.pop();
      expect(heldScores.length, equals(0));
      expect(heldScores.isEmpty, isTrue);
    });
  });

  group('documented examples', () {
    test('class example peeks the top score', () {
      final Stack<int> heldScores = Stack<int>();
      heldScores.push(72);
      heldScores.push(91);
      final ({int? value, bool present}) topScore = heldScores.peek();
      expect(topScore.present, isTrue);
      expect(topScore.value, equals(91));
    });

    test('push example grows the length to one', () {
      final Stack<String> heldWords = Stack<String>();
      heldWords.push('fig');
      expect(heldWords.length, equals(1));
    });

    test('pop example removes and returns the top word', () {
      final Stack<String> heldWords = Stack<String>();
      heldWords.push('fig');
      heldWords.push('pear');
      final ({String? value, bool present}) topWord = heldWords.pop();
      expect(topWord.present, isTrue);
      expect(topWord.value, equals('pear'));
      expect(heldWords.length, equals(1));
    });

    test('peek example reads without removing', () {
      final Stack<String> heldWords = Stack<String>();
      heldWords.push('fig');
      final ({String? value, bool present}) topWord = heldWords.peek();
      expect(topWord.present, isTrue);
      expect(topWord.value, equals('fig'));
      expect(heldWords.length, equals(1));
    });

    test('length example counts held values', () {
      final Stack<int> heldScores = Stack<int>();
      heldScores.push(72);
      heldScores.push(91);
      expect(heldScores.length, equals(2));
    });

    test('isEmpty example starts true then flips', () {
      final Stack<int> heldScores = Stack<int>();
      expect(heldScores.isEmpty, isTrue);
      heldScores.push(72);
      expect(heldScores.isEmpty, isFalse);
    });

    test('isNotEmpty example starts false then flips', () {
      final Stack<int> heldScores = Stack<int>();
      expect(heldScores.isNotEmpty, isFalse);
      heldScores.push(72);
      expect(heldScores.isNotEmpty, isTrue);
    });
  });
}

void heldWordsPopAll(Stack<String> heldWords) {
  while (heldWords.isNotEmpty) {
    heldWords.pop();
  }
}
