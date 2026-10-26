// Companion pins for docs/cookbook.md.
//
// Each recipe runs here with the same logic as the page and asserts the
// exact output lines shown there, so the doc cannot drift from the library.
// Recipe (c) uses a test-local record type; the printed lines are what the
// page pins.
import 'dart:async';

import 'package:praxis/src/di.dart';
import 'package:praxis/src/flow.dart';
import 'package:praxis/src/lists.dart';
import 'package:praxis/src/opt.dart';
import 'package:praxis/src/repo.dart';
import 'package:praxis/src/result.dart';
import 'package:test/test.dart';

/// Runs [body] with print captured, reporting one entry per printed line.
Future<List<String>> _capturePrints(FutureOr<void> Function() body) async {
  final List<String> printedLines = <String>[];
  await runZoned(
    () async => body(),
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        printedLines.add(line);
      },
    ),
  );
  return printedLines;
}

/// Recipe (a) from docs/cookbook.md: the absence ladder.
void _runAbsenceLadder() {
  final List<String> lessons = <String>[
    'generics-intro',
    'slices-deep',
    'maps-fast',
  ];
  // Rung 1: the (value, present) record at your own boundary.
  final ({String? value, bool present}) foundLesson = findElement(
    lessons,
    (String candidate) => candidate == 'slices-deep',
  );
  print('${foundLesson.value} ${foundLesson.present}');
  final ({String? value, bool present}) missedLesson = findElement(
    lessons,
    (String candidate) => candidate == 'nope',
  );
  print('${missedLesson.value == null} ${missedLesson.present}');
  // Rung 2: Opt<String> to chain or transform the absence.
  final Opt<String> maybeLesson = Opt<String>.present(
    foundLesson.value ?? 'nobody',
  );
  print(maybeLesson.valueOr('nobody'));
  print(const Opt<String>.absent().valueOr('nobody'));
  // Rung 3: Result<String> when absence becomes a failure with a cause.
  final Opt<String> missingLesson = Opt<String>.absent();
  final Result<String> lessonOutcome = missingLesson.isPresent
      ? Result<String>.ok(missingLesson.valueOr('nobody'))
      : Result<String>.failure(Exception('lesson not found'));
  print(lessonOutcome.getOrElse('fallback-lesson'));
}

/// Recipe (b) from docs/cookbook.md: the first-success race.
Future<void> _runFirstSuccessRace() async {
  const String fastLesson = 'lesson from fast-mirror';
  final List<String> mirrors = <String>[
    'slow-mirror',
    'fast-mirror',
    'dead-mirror',
  ];
  final String winner = await flowFirst<String, String>(
    mirrors,
    maxInflight: 3,
    transform: (String mirror, FlowScope scope) {
      if (mirror == 'fast-mirror') {
        return Future<String>.value('lesson from $mirror');
      }
      return Future<String>.error(Exception('mirror unreachable: $mirror'));
    },
  );
  print('$winner ${winner == fastLesson}');
}

/// A course lesson addressed by its slug.
final class _Lesson {
  /// Creates a lesson with [slug] identity and [title] content.
  _Lesson(this.slug, this.title);

  /// The identity address for the store.
  final String slug;

  /// The display title.
  final String title;
}

/// Extracts the slug identity; the store never reads the record itself.
String _lessonKeyOf(_Lesson candidate) => candidate.slug;

/// Recipe (c) from docs/cookbook.md: the wired store.
void _runWiredStore() {
  final ServiceContainer services = ServiceContainer();
  services.register<Repository<_Lesson, String>>(
    'lessons',
    () => Repository<_Lesson, String>(keyOf: _lessonKeyOf),
  );
  final Repository<_Lesson, String> lessons = services
      .resolve<Repository<_Lesson, String>>('lessons');
  lessons.put(_Lesson('generics-intro', 'Intro to Generics'));
  final _Lesson fetchedLesson = lessons
      .get('generics-intro')
      .valueOr(_Lesson('fallback', 'Fallback'));
  print(fetchedLesson.title);
  final Repository<_Lesson, String> again = services
      .resolve<Repository<_Lesson, String>>('lessons');
  print(identical(again, lessons));
}

void main() {
  test('absence ladder prints the documented lines', () async {
    expect(
      await _capturePrints(_runAbsenceLadder),
      equals(<String>[
        'slices-deep true',
        'true false',
        'slices-deep',
        'nobody',
        'fallback-lesson',
      ]),
    );
  });

  test('first-success race prints the documented line', () async {
    expect(
      await _capturePrints(_runFirstSuccessRace),
      equals(<String>['lesson from fast-mirror true']),
    );
  });

  test('wired store prints the documented lines', () async {
    expect(
      await _capturePrints(_runWiredStore),
      equals(<String>['Intro to Generics', 'true']),
    );
  });

  test('ladder climbs only as far as the caller needs', () {
    // Plain absence never becomes a failure: Opt answers the flag.
    final Opt<String> missingLesson = Opt<String>.absent();

    expect(missingLesson.isAbsent, isTrue);
    expect(missingLesson.valueOr('nobody'), equals('nobody'));
  });
}
