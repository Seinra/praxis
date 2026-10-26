// Companion suite for the docs unit (foundations + 7 package guides).
//
// Each group replays the runnable example from its guide inside a print
// capture and asserts the EXACT outputs the guide shows, so prose and
// library can never drift apart.
library;

import 'dart:async';

import 'package:praxis/src/either.dart';
import 'package:praxis/src/iterx.dart';
import 'package:praxis/src/lists.dart';
import 'package:praxis/src/mapx.dart';
import 'package:praxis/src/opt.dart';
import 'package:praxis/src/result.dart';
import 'package:praxis/src/set.dart';
import 'package:test/test.dart';

List<String> capturePrints(void Function() body) {
  final List<String> printedLines = <String>[];
  runZoned<void>(
    body,
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        printedLines.add(line);
      },
    ),
  );
  return printedLines;
}

void main() {
  group('foundations guide', () {
    test('example prints the documented outputs', () {
      final List<String> printedLines = capturePrints(() {
        final List<int> doubled = <int>[
          1,
          2,
          3,
        ].map((int score) => score * 2).toList();
        print(doubled);

        print(const Opt<int>.absent().valueOr(0));

        final ({int? value, bool present}) found = findElement(<int>[
          72,
          91,
          85,
        ], (int score) => score > 80);
        print(found.present ? found.value : -1);

        final String label = Result<int>.ok(21).when(
          ok: (int successValue) => 'ok:${successValue * 2}',
          failure: (Exception failureCause) => 'failure',
        );
        print(label);
      });

      expect(printedLines, equals(<String>['[2, 4, 6]', '0', '91', 'ok:42']));
    });
  });

  group('result guide', () {
    test('example prints the documented outputs', () {
      final List<String> printedLines = capturePrints(() {
        final Result<int> doubled = Result<int>.ok(21)
            .mapValue((int successValue) => successValue * 2);
        print(doubled.getOrElse(0));

        final Result<int> offline = Result<int>.failure(Exception('offline'));
        print(offline.getOrElse(-1));

        final String label = doubled.when(
          ok: (int successValue) => 'ok:$successValue',
          failure: (Exception failureCause) => 'failure',
        );
        print(label);
      });

      expect(printedLines, equals(<String>['42', '-1', 'ok:42']));
    });
  });

  group('opt guide', () {
    test('example prints the documented outputs', () {
      final List<String> printedLines = capturePrints(() {
        const Opt<int> presentScore = Opt<int>.present(4);
        print(presentScore.valueOr(0));
        print(
          presentScore.mapValue((int heldValue) => heldValue + 1).valueOr(0),
        );

        const Opt<int> missingScore = Opt<int>.absent();
        print(missingScore.valueOr(9));
        print(missingScore.isAbsent);

        final (int? heldValue, bool presentFlag) = presentScore.split;
        print('$presentFlag:$heldValue');
      });

      expect(printedLines, equals(<String>['4', '5', '9', 'true', 'true:4']));
    });
  });

  group('lists guide', () {
    test('example prints the documented outputs', () {
      final List<String> printedLines = capturePrints(() {
        final ({int? value, bool present}) found = findElement(<int>[
          72,
          91,
          85,
        ], (int score) => score > 80);
        print(found.present ? found.value : -1);

        final ({int? value, bool present}) lowest = minElement(<int>[3, 1, 2]);
        print(lowest.present ? lowest.value : -1);

        print(chunkElements(<int>[1, 2, 3, 4, 5], 2));

        final ({List<int> matching, List<int> rest}) split = partitionElements(
          <int>[1, 2, 3, 4],
          (int number) => number.isEven,
        );
        print(split);
      });

      expect(
        printedLines,
        equals(<String>[
          '91',
          '1',
          '[[1, 2], [3, 4], [5]]',
          '(matching: [2, 4], rest: [1, 3])',
        ]),
      );
    });
  });

  group('either guide', () {
    test('example prints the documented outputs', () {
      final List<String> printedLines = capturePrints(() {
        final Either<String, int> granted = Either<String, int>.right(7);
        print(
          granted.when(
            onLeft: (String lockReason) => 'locked: $lockReason',
            onRight: (int slotCount) => 'ready: $slotCount slots',
          ),
        );

        final Either<String, int> locked = Either<String, int>.left(
          'season pass missing',
        ).mapLeft((String lockReason) => 'LEFT:$lockReason');
        print(locked.isLeft);

        final Result<int> outcome = granted.toResult(
          (String lockReason) => Exception(lockReason),
        );
        print(outcome.getOrElse(0));
      });

      expect(printedLines, equals(<String>['ready: 7 slots', 'true', '7']));
    });
  });

  group('mapx guide', () {
    test('example prints the documented outputs', () {
      final List<String> printedLines = capturePrints(() {
        print(invertEntries(<String, int>{'ann': 1, 'bob': 2, 'cid': 1}));

        print(
          pickEntries(
            <String, int>{'ann': 1, 'bob': 2},
            <String>['ann', 'missing'],
          ),
        );

        print(omitEntries(<String, int>{'ann': 1, 'bob': 2}, <String>['ann']));

        print(mapValues(<String, int>{'ann': 1}, (int score) => score * 2));

        print(
          mapKeys(<String, int>{'ann': 1}, (String name) => name.toUpperCase()),
        );

        print(
          groupEntriesBy(<String, int>{
            'ann': 91,
            'bob': 72,
          }, (String name, int score) => score >= 80 ? 'pass' : 'fail'),
        );
      });

      expect(
        printedLines,
        equals(<String>[
          '{1: [ann, cid], 2: [bob]}',
          '{ann: 1}',
          '{bob: 2}',
          '{ann: 2}',
          '{ANN: 1}',
          '{pass: [91], fail: [72]}',
        ]),
      );
    });
  });

  group('set guide', () {
    test('example prints the documented outputs', () {
      final List<String> printedLines = capturePrints(() {
        print(symmetricDifference(<int>{1, 2, 3}, <int>{3, 4}));
        print(isSubsetOf(<int>{1, 2}, <int>{1, 2, 3}));
        print(isSupersetOf(<int>{1, 2, 3}, <int>{1, 2}));
        print(isDisjointFrom(<int>{1, 2}, <int>{3, 4}));
        print(hasSameMembers(<int>{1, 2}, <int>{2, 1}));
      });

      expect(
        printedLines,
        equals(<String>['{1, 2, 4}', 'true', 'true', 'true', 'true']),
      );
    });
  });

  group('iterx guide', () {
    test('example prints the documented outputs', () {
      final List<String> printedLines = capturePrints(() {
        print(zipIterables(<int>[1, 2, 3], <String>['a', 'b']).toList());

        print(chunkedIterable(<int>[1, 2, 3, 4, 5], 2).toList());

        print(windowedIterable(<int>[1, 2, 3], 2).toList());

        print(cycleIterable(<int>[1, 2]).take(5).toList());

        print(repeatElement(7).take(3).toList());

        print(deduplicateAdjacent(<int>[1, 1, 2, 1]).toList());
      });

      expect(
        printedLines,
        equals(<String>[
          '[(first: 1, second: a), (first: 2, second: b)]',
          '[[1, 2], [3, 4], [5]]',
          '[[1, 2], [2, 3]]',
          '[1, 2, 1, 2, 1]',
          '[7, 7, 7]',
          '[1, 2, 1]',
        ]),
      );
    });
  });
}
