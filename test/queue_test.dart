import 'package:praxis/src/queue.dart';
import 'package:test/test.dart';

void main() {
  group('FifoQueue.enqueue and FifoQueue.dequeue', () {
    test('dequeues enqueued values first-in first-out', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      waitingScores.enqueue(1);
      waitingScores.enqueue(2);
      waitingScores.enqueue(3);
      final ({int? value, bool present}) firstServed = waitingScores.dequeue();
      expect(firstServed.present, isTrue);
      expect(firstServed.value, equals(1));
      final ({int? value, bool present}) secondServed = waitingScores.dequeue();
      expect(secondServed.present, isTrue);
      expect(secondServed.value, equals(2));
      final ({int? value, bool present}) thirdServed = waitingScores.dequeue();
      expect(thirdServed.present, isTrue);
      expect(thirdServed.value, equals(3));
    });

    test('reports absent instead of throwing on an empty queue', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      final ({int? value, bool present}) served = waitingScores.dequeue();
      expect(served.present, isFalse);
      expect(served.value, isNull);
    });

    test('keeps an enqueued null distinct from an absent dequeue', () {
      final FifoQueue<int?> waitingScores = FifoQueue<int?>();
      waitingScores.enqueue(null);
      final ({int? value, bool present}) served = waitingScores.dequeue();
      expect(served.present, isTrue);
      expect(served.value, isNull);
    });

    test('preserves order across interleaved enqueues and dequeues', () {
      final FifoQueue<String> waitingWords = FifoQueue<String>();
      waitingWords.enqueue('ann');
      waitingWords.enqueue('bob');
      expect(waitingWords.dequeue().value, equals('ann'));
      waitingWords.enqueue('cid');
      expect(waitingWords.dequeue().value, equals('bob'));
      expect(waitingWords.dequeue().value, equals('cid'));
      expect(waitingWords.isEmpty, isTrue);
    });

    test('keeps order after the compaction threshold', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      for (int score = 0; score < 200; score += 1) {
        waitingScores.enqueue(score);
      }
      for (int score = 0; score < 150; score += 1) {
        final ({int? value, bool present}) served = waitingScores.dequeue();
        expect(served.present, isTrue);
        expect(served.value, equals(score));
      }
      expect(waitingScores.length, equals(50));
      for (int score = 150; score < 200; score += 1) {
        final ({int? value, bool present}) served = waitingScores.dequeue();
        expect(served.present, isTrue);
        expect(served.value, equals(score));
      }
      expect(waitingScores.isEmpty, isTrue);
    });

    test('reuses the queue cleanly after a full drain', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      waitingScores.enqueue(1);
      waitingScores.enqueue(2);
      waitingScores.dequeue();
      waitingScores.dequeue();
      expect(waitingScores.isEmpty, isTrue);
      waitingScores.enqueue(3);
      final ({int? value, bool present}) served = waitingScores.dequeue();
      expect(served.present, isTrue);
      expect(served.value, equals(3));
      expect(waitingScores.isEmpty, isTrue);
    });

    test('leaves the filling list untouched', () {
      final List<int> sourceScores = <int>[1, 2, 3];
      final List<int> snapshotScores = List<int>.of(sourceScores);
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      for (final int score in sourceScores) {
        waitingScores.enqueue(score);
      }
      while (waitingScores.isNotEmpty) {
        waitingScores.dequeue();
      }
      expect(sourceScores, equals(snapshotScores));
    });
  });

  group('FifoQueue.peek', () {
    test('reads the front value without removing it', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      waitingScores.enqueue(72);
      waitingScores.enqueue(91);
      final ({int? value, bool present}) frontScore = waitingScores.peek();
      expect(frontScore.present, isTrue);
      expect(frontScore.value, equals(72));
      expect(waitingScores.length, equals(2));
      final ({int? value, bool present}) frontAgain = waitingScores.peek();
      expect(frontAgain.value, equals(72));
      expect(waitingScores.length, equals(2));
    });

    test('reports absent instead of throwing on an empty queue', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      final ({int? value, bool present}) frontScore = waitingScores.peek();
      expect(frontScore.present, isFalse);
      expect(frontScore.value, isNull);
    });

    test('tracks the front across interleaved dequeues', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      waitingScores.enqueue(1);
      waitingScores.enqueue(2);
      expect(waitingScores.peek().value, equals(1));
      waitingScores.dequeue();
      expect(waitingScores.peek().value, equals(2));
    });
  });

  group('FifoQueue.length and emptiness', () {
    test('starts empty with zero length', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      expect(waitingScores.length, equals(0));
      expect(waitingScores.isEmpty, isTrue);
      expect(waitingScores.isNotEmpty, isFalse);
    });

    test('counts enqueues and dequeues', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      waitingScores.enqueue(1);
      expect(waitingScores.length, equals(1));
      expect(waitingScores.isEmpty, isFalse);
      expect(waitingScores.isNotEmpty, isTrue);
      waitingScores.enqueue(2);
      expect(waitingScores.length, equals(2));
      waitingScores.dequeue();
      expect(waitingScores.length, equals(1));
      waitingScores.dequeue();
      expect(waitingScores.length, equals(0));
      expect(waitingScores.isEmpty, isTrue);
    });

    test('empty dequeues never drive the length negative', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      waitingScores.dequeue();
      waitingScores.dequeue();
      expect(waitingScores.length, equals(0));
      expect(waitingScores.isEmpty, isTrue);
    });
  });

  group('documented examples', () {
    test('class example peeks the front score', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      waitingScores.enqueue(72);
      waitingScores.enqueue(91);
      final ({int? value, bool present}) frontScore = waitingScores.peek();
      expect(frontScore.present, isTrue);
      expect(frontScore.value, equals(72));
    });

    test('enqueue example grows the length to one', () {
      final FifoQueue<String> waitingWords = FifoQueue<String>();
      waitingWords.enqueue('fig');
      expect(waitingWords.length, equals(1));
    });

    test('dequeue example removes and returns the front word', () {
      final FifoQueue<String> waitingWords = FifoQueue<String>();
      waitingWords.enqueue('fig');
      waitingWords.enqueue('pear');
      final ({String? value, bool present}) frontWord = waitingWords.dequeue();
      expect(frontWord.present, isTrue);
      expect(frontWord.value, equals('fig'));
      expect(waitingWords.length, equals(1));
    });

    test('peek example reads without removing', () {
      final FifoQueue<String> waitingWords = FifoQueue<String>();
      waitingWords.enqueue('fig');
      final ({String? value, bool present}) frontWord = waitingWords.peek();
      expect(frontWord.present, isTrue);
      expect(frontWord.value, equals('fig'));
      expect(waitingWords.length, equals(1));
    });

    test('length example counts waiting values', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      waitingScores.enqueue(72);
      waitingScores.enqueue(91);
      expect(waitingScores.length, equals(2));
    });

    test('isEmpty example starts true then flips', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      expect(waitingScores.isEmpty, isTrue);
      waitingScores.enqueue(72);
      expect(waitingScores.isEmpty, isFalse);
    });

    test('isNotEmpty example starts false then flips', () {
      final FifoQueue<int> waitingScores = FifoQueue<int>();
      expect(waitingScores.isNotEmpty, isFalse);
      waitingScores.enqueue(72);
      expect(waitingScores.isNotEmpty, isTrue);
    });
  });
}
