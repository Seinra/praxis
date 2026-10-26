import 'package:praxis/praxis.dart';
import 'package:test/test.dart';

/// Companion suite for docs unit C (guides `repo` + `httpx` + `stack` +
/// `queue` + `orderedmap` + `task` + `pipe`): hand-asserts the exact
/// outputs each guide shows, Axiom `guides_test.go` pattern.
void main() {
  group('repo guide', () {
    test('stores two lessons and reports the snapshot', () {
      final Repository<String, String> lessonStore = Repository<String, String>(
        keyOf: (String candidate) => candidate,
      );
      lessonStore.put('lesson-a');
      lessonStore.put('lesson-b');
      expect(lessonStore.get('lesson-a').isPresent, isTrue);
      expect(lessonStore.list(), equals(<String>['lesson-a', 'lesson-b']));
      expect(lessonStore.remove('lesson-a'), isTrue);
      expect(lessonStore.list(), equals(<String>['lesson-b']));
    });
  });

  group('httpx guide', () {
    test('decodes the typed title and flags the missing lesson', () async {
      HttpxTransport fakeTransport(String bodyText, {int statusCode = 200}) {
        return (HttpxRequest outgoingRequest) async =>
            HttpxResponse(statusCode: statusCode, bodyText: bodyText);
      }

      String readTitle(Map<String, Object?> decodedJson) =>
          decodedJson['title'] as String;

      final Result<String> lessonOutcome = await httpxGet<String>(
        fakeTransport('{"title":"Intro to Generics"}'),
        HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/a')),
        readTitle,
      );
      expect(lessonOutcome.getOrElse('missing'), equals('Intro to Generics'));

      final Result<String> missingOutcome = await httpxGet<String>(
        fakeTransport('missing lesson', statusCode: 404),
        HttpxRequest.get(Uri.parse('https://catalyst.example/lessons/missing')),
        readTitle,
      );
      expect(missingOutcome.isFailure, isTrue);
    });
  });

  group('stack guide', () {
    test('pops most-recent-first and reports the depth', () {
      final Stack<int> heldScores = Stack<int>();
      heldScores.push(72);
      heldScores.push(91);
      expect(heldScores.pop().value, equals(91));
      expect(heldScores.peek().value, equals(72));
      expect(heldScores.length, equals(1));
    });
  });

  group('queue guide', () {
    test('serves longest-waiting-first and reports the depth', () {
      final FifoQueue<String> waitingWords = FifoQueue<String>();
      waitingWords.enqueue('fig');
      waitingWords.enqueue('pear');
      expect(waitingWords.dequeue().value, equals('fig'));
      expect(waitingWords.peek().value, equals('pear'));
      expect(waitingWords.length, equals(1));
    });
  });

  group('orderedmap guide', () {
    test('replays insertion order and evicts least-recently-used', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 91);
      scoresByName.put('bob', 72);
      expect(scoresByName.keys(), equals(<String>['ann', 'bob']));
      expect(scoresByName.get('ann').value, equals(91));

      final LruCache<String, int> recentScores = LruCache<String, int>(2);
      recentScores.put('ann', 91);
      recentScores.put('bob', 72);
      recentScores.put('cid', 85);
      expect(recentScores.get('ann').present, isFalse);
      expect(recentScores.length, equals(2));
    });
  });

  group('task guide', () {
    test('joins one shared outcome twice', () async {
      final Task<int> backgroundTask = Task<int>.spawn(() async => 42);
      final Result<int> outcome = await backgroundTask.join();
      expect(outcome.getOrElse(0), equals(42));
      final Result<int> secondOutcome = await backgroundTask.join();
      expect(identical(outcome, secondOutcome), isTrue);
    });
  });

  group('pipe guide', () {
    test('names the two-step pipeline in both orders', () {
      final int Function(int) addOneThenDouble = pipe<int, int, int>(
        (int firstValue) => firstValue + 1,
        (int pipedValue) => pipedValue * 2,
      );
      expect(addOneThenDouble(3), equals(8));

      final int Function(int) doubleAfterAddOne = compose<int, int, int>(
        (int outerValue) => outerValue * 2,
        (int innerValue) => innerValue + 1,
      );
      expect(doubleAfterAddOne(3), equals(8));
    });
  });

  group('absence record plumbing', () {
    test('proves the Opt read used by the repo guide', () {
      const Opt<String> absentLesson = Opt<String>.absent();
      expect(absentLesson.isPresent, isFalse);
    });
  });
}
