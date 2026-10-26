// Companion pins for docs/quickstart.md.
//
// The quickstart pipeline runs here with the same logic as the page and
// asserts the exact output lines shown there, so the doc cannot drift from
// the library.
import 'dart:async';

import 'package:praxis/src/lists.dart';
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

/// The quickstart pipeline from docs/quickstart.md step 2.
void _runQuickstartPipeline() {
  final Result<int> current = Result<int>.ok(21);
  final Result<int> doubled = current.mapValue(
    (int successValue) => successValue * 2,
  );
  print(doubled.getOrElse(0));

  final List<int> numbers = <int>[1, 2, 3];
  final ({int? value, bool present}) found = findElement(
    numbers,
    (int candidate) => candidate > 1,
  );
  print('${found.value} ${found.present}');
}

void main() {
  test('quickstart pipeline prints the documented lines', () async {
    expect(
      await _capturePrints(_runQuickstartPipeline),
      equals(<String>['42', '2 true']),
    );
  });

  test('mapValue carries failures through untouched', () {
    final Result<int> mappedOutcome = Result<int>.failure(Exception('offline'))
        .mapValue((int successValue) => successValue * 2);

    expect(mappedOutcome.isFailure, isTrue);
    expect(mappedOutcome.getOrElse(-1), equals(-1));
  });

  test('findElement reports absence without throwing', () {
    final ({int? value, bool present}) missedOutcome = findElement(
      <int>[],
      (int candidate) => candidate > 1,
    );

    expect(missedOutcome.present, isFalse);
    expect(missedOutcome.value, isNull);
  });
}
