import 'package:praxis/src/opt.dart';
import 'package:praxis/src/repo.dart';
import 'package:test/test.dart';

/// A Catalyst-flavored course lesson used as the record in every scenario.
final class _Lesson {
  _Lesson(this.slug, this.title);

  final String slug;
  final String title;
}

/// Extracts the slug identity; mirrors how callers supply [keyOf].
String _lessonKeyOf(_Lesson candidate) => candidate.slug;

/// A stock record keyed by an integer identity for the generic-key pin.
final class _Badge {
  _Badge(this.number, this.label);

  final int number;
  final String label;
}

void main() {
  group('Repository.put', () {
    test('stores a record readable under its extracted identity', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('generics-intro', 'Intro to Generics'));
      final Opt<_Lesson> fetchedLesson = lessonStore.get('generics-intro');
      expect(fetchedLesson.isPresent, isTrue);
      expect(
        fetchedLesson.valueOr(_Lesson('fallback', 'Fallback')).title,
        equals('Intro to Generics'),
      );
    });

    test('duplicate put replaces the record and keeps one entry', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('upsert-me', 'First'));
      lessonStore.put(_Lesson('upsert-me', 'Second'));
      expect(
        lessonStore
            .get('upsert-me')
            .valueOr(_Lesson('fallback', 'Fallback'))
            .title,
        equals('Second'),
      );
      expect(lessonStore.list(), hasLength(1));
    });

    test('replaced record keeps its original listing position', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      lessonStore.put(_Lesson('lesson-b', 'Lesson B'));
      lessonStore.put(_Lesson('lesson-a', 'Lesson A revised'));
      final List<String> listedSlugs = lessonStore
          .list()
          .map((_Lesson listedLesson) => listedLesson.slug)
          .toList();
      expect(listedSlugs, equals(<String>['lesson-a', 'lesson-b']));
      expect(
        lessonStore
            .get('lesson-a')
            .valueOr(_Lesson('fallback', 'Fallback'))
            .title,
        equals('Lesson A revised'),
      );
    });

    test('identity comes from keyOf, not object identity', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('shared-slug', 'First write'));
      lessonStore.put(_Lesson('shared-slug', 'Second write'));
      expect(lessonStore.list(), hasLength(1));
    });
  });

  group('Repository.get', () {
    test('missing identity reads as absent, never throws', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      final Opt<_Lesson> fetchedLesson = lessonStore.get('no-such-lesson');
      expect(fetchedLesson.isAbsent, isTrue);
      final (heldLesson, presentFlag) = fetchedLesson.split;
      expect(presentFlag, isFalse);
      expect(heldLesson, isNull);
    });

    test('absent read carries through Opt combinators untouched', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      final Opt<String> mappedTitle = lessonStore
          .get('no-such-lesson')
          .mapValue((_Lesson heldLesson) => heldLesson.title);
      expect(mappedTitle.isAbsent, isTrue);
      expect(
        lessonStore
            .get('no-such-lesson')
            .valueOr(_Lesson('fallback', 'Fallback'))
            .slug,
        equals('fallback'),
      );
    });

    test('present read maps through Opt combinators', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('generics-intro', 'Intro to Generics'));
      final Opt<String> mappedTitle = lessonStore
          .get('generics-intro')
          .mapValue((_Lesson heldLesson) => heldLesson.title);
      expect(mappedTitle.valueOr('missing'), equals('Intro to Generics'));
    });

    test('removed identity reads as absent afterwards', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('retired-lesson', 'Retired'));
      expect(lessonStore.remove('retired-lesson'), isTrue);
      expect(lessonStore.get('retired-lesson').isAbsent, isTrue);
    });
  });

  group('Repository.remove', () {
    test('drops the stored record and reports true', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('retired-lesson', 'Retired'));
      expect(lessonStore.remove('retired-lesson'), isTrue);
      expect(lessonStore.list(), isEmpty);
    });

    test('missing identity reports false and leaves the store intact', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('kept-lesson', 'Kept'));
      expect(lessonStore.remove('no-such-lesson'), isFalse);
      expect(lessonStore.list(), hasLength(1));
      expect(lessonStore.get('kept-lesson').isPresent, isTrue);
    });

    test('re-put after remove stores fresh at the end', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      lessonStore.put(_Lesson('lesson-b', 'Lesson B'));
      expect(lessonStore.remove('lesson-a'), isTrue);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A again'));
      final List<String> listedSlugs = lessonStore
          .list()
          .map((_Lesson listedLesson) => listedLesson.slug)
          .toList();
      expect(listedSlugs, equals(<String>['lesson-b', 'lesson-a']));
    });
  });

  group('Repository.list', () {
    test('empty store lists an empty snapshot', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      final List<_Lesson> listedLessons = lessonStore.list();
      expect(listedLessons, isEmpty);
      expect(listedLessons, isNotNull);
    });

    test('lists every stored record in insertion order', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      lessonStore.put(_Lesson('lesson-b', 'Lesson B'));
      lessonStore.put(_Lesson('lesson-c', 'Lesson C'));
      final List<String> listedSlugs = lessonStore
          .list()
          .map((_Lesson listedLesson) => listedLesson.slug)
          .toList();
      expect(listedSlugs, equals(<String>['lesson-a', 'lesson-b', 'lesson-c']));
    });

    test('each call returns a fresh snapshot', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      final List<_Lesson> firstSnapshot = lessonStore.list();
      final List<_Lesson> secondSnapshot = lessonStore.list();
      expect(identical(firstSnapshot, secondSnapshot), isFalse);
      expect(firstSnapshot, hasLength(1));
    });

    test('mutating a snapshot leaves the store intact', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      final List<_Lesson> snapshotLessons = lessonStore.list();
      snapshotLessons.removeAt(0);
      snapshotLessons.add(_Lesson('forged-lesson', 'Forged'));
      expect(lessonStore.list(), hasLength(1));
      expect(lessonStore.get('lesson-a').isPresent, isTrue);
      expect(lessonStore.get('forged-lesson').isAbsent, isTrue);
    });

    test('later puts never rewrite an earlier snapshot', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      final List<_Lesson> snapshotLessons = lessonStore.list();
      lessonStore.put(_Lesson('lesson-b', 'Lesson B'));
      lessonStore.remove('lesson-a');
      expect(snapshotLessons, hasLength(1));
      expect(snapshotLessons.first.slug, equals('lesson-a'));
      expect(lessonStore.list(), hasLength(1));
    });
  });

  group('Repository identity rules', () {
    test('empty-string identity stays addressable', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('', 'Untitled'));
      expect(lessonStore.get('').isPresent, isTrue);
      expect(lessonStore.list(), hasLength(1));
      expect(lessonStore.remove(''), isTrue);
      expect(lessonStore.get('').isAbsent, isTrue);
    });

    test('neighboring identities read back their own record', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      lessonStore.put(_Lesson('lesson-b', 'Lesson B'));
      expect(
        lessonStore
            .get('lesson-a')
            .valueOr(_Lesson('fallback', 'Fallback'))
            .title,
        equals('Lesson A'),
      );
      expect(
        lessonStore
            .get('lesson-b')
            .valueOr(_Lesson('fallback', 'Fallback'))
            .title,
        equals('Lesson B'),
      );
      expect(lessonStore.get('lesson-c').isAbsent, isTrue);
    });
  });

  group('generic identity', () {
    test('integer identities address records the same way', () {
      final Repository<_Badge, int> badgeStore = Repository<_Badge, int>(
        keyOf: (_Badge candidate) => candidate.number,
      );
      badgeStore.put(_Badge(7, 'Seven'));
      expect(
        badgeStore.get(7).valueOr(_Badge(0, 'Fallback')).label,
        equals('Seven'),
      );
      expect(badgeStore.get(8).isAbsent, isTrue);
      expect(badgeStore.remove(8), isFalse);
      expect(badgeStore.remove(7), isTrue);
      expect(badgeStore.list(), isEmpty);
    });
  });

  group('documented examples stay runnable', () {
    test('Repository example', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      // lessonStore.get('lesson-a').isPresent == true
      expect(lessonStore.get('lesson-a').isPresent, isTrue);
    });

    test('Repository.put example', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      lessonStore.put(_Lesson('lesson-a', 'Lesson A revised'));
      // lessonStore.list() == 1 record holding 'Lesson A revised'
      expect(lessonStore.list(), hasLength(1));
    });

    test('Repository.get example', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      final Opt<_Lesson> fetchedLesson = lessonStore.get('lesson-a');
      // fetchedLesson.isPresent == true
      expect(fetchedLesson.isPresent, isTrue);
    });

    test('Repository.remove example', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      final bool droppedLesson = lessonStore.remove('lesson-a');
      // droppedLesson == true
      expect(droppedLesson, isTrue);
    });

    test('Repository.list example', () {
      final Repository<_Lesson, String> lessonStore =
          Repository<_Lesson, String>(keyOf: _lessonKeyOf);
      lessonStore.put(_Lesson('lesson-a', 'Lesson A'));
      lessonStore.put(_Lesson('lesson-b', 'Lesson B'));
      final List<_Lesson> listedLessons = lessonStore.list();
      // listedLessons.length == 2
      expect(listedLessons, hasLength(2));
    });
  });
}
