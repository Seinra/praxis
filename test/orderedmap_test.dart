import 'package:praxis/src/orderedmap.dart';
import 'package:test/test.dart';

void main() {
  group('OrderedMap.put and OrderedMap.get', () {
    test('stores and reads entries by key', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 1);
      scoresByName.put('bob', 2);
      final ({int? value, bool present}) annScore = scoresByName.get('ann');
      expect(annScore.present, isTrue);
      expect(annScore.value, equals(1));
      final ({int? value, bool present}) bobScore = scoresByName.get('bob');
      expect(bobScore.present, isTrue);
      expect(bobScore.value, equals(2));
    });

    test('reports absent for a missing key', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 1);
      final ({int? value, bool present}) missing = scoresByName.get('cid');
      expect(missing.present, isFalse);
      expect(missing.value, isNull);
    });

    test('reports absent on an empty map', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      final ({int? value, bool present}) missing = scoresByName.get('ann');
      expect(missing.present, isFalse);
      expect(missing.value, isNull);
    });

    test('keeps a present null distinct from a missing key', () {
      final OrderedMap<String, int?> scoresByName = OrderedMap<String, int?>();
      scoresByName.put('ann', null);
      final ({int? value, bool present}) annScore = scoresByName.get('ann');
      expect(annScore.present, isTrue);
      expect(annScore.value, isNull);
      final ({int? value, bool present}) missing = scoresByName.get('bob');
      expect(missing.present, isFalse);
    });

    test('upserts keep the first-insertion position', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 1);
      scoresByName.put('bob', 2);
      scoresByName.put('ann', 9);
      final ({int? value, bool present}) annScore = scoresByName.get('ann');
      expect(annScore.value, equals(9));
      expect(scoresByName.keys(), equals(<String>['ann', 'bob']));
      expect(scoresByName.values(), equals(<int>[9, 2]));
    });
  });

  group('OrderedMap.remove', () {
    test('removes the entry and closes the order gap', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 1);
      scoresByName.put('bob', 2);
      scoresByName.put('cid', 3);
      scoresByName.remove('bob');
      expect(scoresByName.keys(), equals(<String>['ann', 'cid']));
      expect(scoresByName.values(), equals(<int>[1, 3]));
      final ({int? value, bool present}) removed = scoresByName.get('bob');
      expect(removed.present, isFalse);
    });

    test('ignores a missing key', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 1);
      scoresByName.remove('missing');
      expect(scoresByName.length, equals(1));
      expect(scoresByName.keys(), equals(<String>['ann']));
    });

    test('re-put after remove takes the back', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 1);
      scoresByName.put('bob', 2);
      scoresByName.remove('ann');
      scoresByName.put('ann', 3);
      expect(scoresByName.keys(), equals(<String>['bob', 'ann']));
      expect(scoresByName.values(), equals(<int>[2, 3]));
    });
  });

  group('OrderedMap.keys and OrderedMap.values', () {
    test('replays insertion order', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('bob', 2);
      scoresByName.put('ann', 1);
      scoresByName.put('cid', 3);
      expect(scoresByName.keys(), equals(<String>['bob', 'ann', 'cid']));
      expect(scoresByName.values(), equals(<int>[2, 1, 3]));
    });

    test('returns empty lists on an empty map', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      expect(scoresByName.keys(), isEmpty);
      expect(scoresByName.values(), isEmpty);
    });

    test('returns fresh lists that leave the map untouched', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 1);
      scoresByName.put('bob', 2);
      final List<String> replayedKeys = scoresByName.keys();
      replayedKeys.add('intruder');
      replayedKeys[0] = 'renamed';
      final List<int> replayedValues = scoresByName.values();
      replayedValues.add(99);
      expect(scoresByName.keys(), equals(<String>['ann', 'bob']));
      expect(scoresByName.values(), equals(<int>[1, 2]));
      expect(scoresByName.length, equals(2));
    });
  });

  group('OrderedMap.length and emptiness', () {
    test('starts empty with zero length', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      expect(scoresByName.length, equals(0));
      expect(scoresByName.isEmpty, isTrue);
      expect(scoresByName.isNotEmpty, isFalse);
    });

    test('counts puts and removes', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 1);
      expect(scoresByName.length, equals(1));
      expect(scoresByName.isEmpty, isFalse);
      expect(scoresByName.isNotEmpty, isTrue);
      scoresByName.put('ann', 2);
      expect(scoresByName.length, equals(1));
      scoresByName.remove('ann');
      expect(scoresByName.length, equals(0));
      expect(scoresByName.isEmpty, isTrue);
    });
  });

  group('LruCache', () {
    test('rejects a non-positive capacity', () {
      expect(() => LruCache<String, int>(0), throwsArgumentError);
      expect(() => LruCache<String, int>(-2), throwsArgumentError);
    });

    test('stores and reads entries up to capacity', () {
      final LruCache<String, int> recentScores = LruCache<String, int>(2);
      expect(recentScores.capacity, equals(2));
      recentScores.put('ann', 1);
      recentScores.put('bob', 2);
      expect(recentScores.length, equals(2));
      final ({int? value, bool present}) annScore = recentScores.get('ann');
      expect(annScore.present, isTrue);
      expect(annScore.value, equals(1));
    });

    test('keeps a held null distinct from a missing key', () {
      final LruCache<String, int?> recentScores = LruCache<String, int?>(2);
      recentScores.put('ann', null);
      final ({int? value, bool present}) annScore = recentScores.get('ann');
      expect(annScore.present, isTrue);
      expect(annScore.value, isNull);
      final ({int? value, bool present}) missing = recentScores.get('bob');
      expect(missing.present, isFalse);
      expect(missing.value, isNull);
    });

    test('reports absent for a missing key without touching recency', () {
      final LruCache<String, int> recentScores = LruCache<String, int>(2);
      recentScores.put('ann', 1);
      recentScores.put('bob', 2);
      final ({int? value, bool present}) missing = recentScores.get('cid');
      expect(missing.present, isFalse);
      expect(missing.value, isNull);
      recentScores.put('cid', 3);
      expect(recentScores.get('ann').present, isFalse);
      expect(recentScores.get('bob').value, equals(2));
    });

    test('evicts the least-recently-used entry beyond capacity', () {
      final LruCache<String, int> recentScores = LruCache<String, int>(2);
      recentScores.put('ann', 1);
      recentScores.put('bob', 2);
      recentScores.put('cid', 3);
      expect(recentScores.length, equals(2));
      expect(recentScores.get('ann').present, isFalse);
      expect(recentScores.get('bob').value, equals(2));
      expect(recentScores.get('cid').value, equals(3));
    });

    test('refreshes recency on get hits', () {
      final LruCache<String, int> recentScores = LruCache<String, int>(2);
      recentScores.put('ann', 1);
      recentScores.put('bob', 2);
      recentScores.get('ann');
      recentScores.put('cid', 3);
      expect(recentScores.get('ann').value, equals(1));
      expect(recentScores.get('bob').present, isFalse);
      expect(recentScores.get('cid').value, equals(3));
    });

    test('refreshes recency and value on repeated puts', () {
      final LruCache<String, int> recentScores = LruCache<String, int>(2);
      recentScores.put('ann', 1);
      recentScores.put('bob', 2);
      recentScores.put('ann', 9);
      expect(recentScores.length, equals(2));
      recentScores.put('cid', 3);
      expect(recentScores.get('ann').value, equals(9));
      expect(recentScores.get('bob').present, isFalse);
    });

    test('holds a single entry at capacity one', () {
      final LruCache<String, int> recentScores = LruCache<String, int>(1);
      recentScores.put('ann', 1);
      recentScores.put('bob', 2);
      expect(recentScores.length, equals(1));
      expect(recentScores.get('ann').present, isFalse);
      expect(recentScores.get('bob').value, equals(2));
    });

    test('starts empty and tracks emptiness', () {
      final LruCache<String, int> recentScores = LruCache<String, int>(2);
      expect(recentScores.length, equals(0));
      expect(recentScores.isEmpty, isTrue);
      expect(recentScores.isNotEmpty, isFalse);
      recentScores.put('ann', 1);
      expect(recentScores.isEmpty, isFalse);
      expect(recentScores.isNotEmpty, isTrue);
    });
  });

  group('documented examples', () {
    test('class example reads the second score', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 91);
      scoresByName.put('bob', 72);
      expect(scoresByName.keys(), equals(<String>['ann', 'bob']));
    });

    test('put example stores the score', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 91);
      expect(scoresByName.get('ann').value, equals(91));
    });

    test('get example reads a present score', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 91);
      final ({int? value, bool present}) annScore = scoresByName.get('ann');
      expect(annScore.present, isTrue);
      expect(annScore.value, equals(91));
    });

    test('remove example drops the entry', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 91);
      scoresByName.put('bob', 72);
      scoresByName.remove('ann');
      expect(scoresByName.keys(), equals(<String>['bob']));
    });

    test('keys example replays insertion order', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('bob', 72);
      scoresByName.put('ann', 91);
      expect(scoresByName.keys(), equals(<String>['bob', 'ann']));
    });

    test('values example replays values in key order', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('bob', 72);
      scoresByName.put('ann', 91);
      expect(scoresByName.values(), equals(<int>[72, 91]));
    });

    test('length example counts held entries', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      scoresByName.put('ann', 91);
      scoresByName.put('bob', 72);
      expect(scoresByName.length, equals(2));
    });

    test('isEmpty example starts true then flips', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      expect(scoresByName.isEmpty, isTrue);
      scoresByName.put('ann', 91);
      expect(scoresByName.isEmpty, isFalse);
    });

    test('isNotEmpty example starts false then flips', () {
      final OrderedMap<String, int> scoresByName = OrderedMap<String, int>();
      expect(scoresByName.isNotEmpty, isFalse);
      scoresByName.put('ann', 91);
      expect(scoresByName.isNotEmpty, isTrue);
    });

    test('LruCache example evicts the least-recently-used name', () {
      final LruCache<String, int> recentScores = LruCache<String, int>(2);
      recentScores.put('ann', 91);
      recentScores.put('bob', 72);
      recentScores.put('cid', 85);
      expect(recentScores.get('ann').present, isFalse);
      expect(recentScores.get('bob').value, equals(72));
    });

    test('LruCache capacity example reads the bound', () {
      final LruCache<String, int> recentScores = LruCache<String, int>(2);
      expect(recentScores.capacity, equals(2));
    });
  });
}
