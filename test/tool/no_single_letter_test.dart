// End-to-end pins for the `no_single_letter` house rule.
//
// The plugin runs for real: each test analyzes a scratch package with the
// rule enabled and asserts the exact reported spans.
@Timeout(Duration(minutes: 5))
library;

import 'package:test/test.dart';

import 'lint_fixture.dart';

const String _localsFlagged = '''
void main() {
  var x = 1;
  print(x);
}
''';

const String _paramsFlagged = '''
int add(int a, int b) {
  return a + b;
}

void configure([int? r, int timeout = 5]) {
  print('\$r \$timeout');
}

void greet({required String n}) {
  print(n);
}
''';

List<LintFinding> _ruleFindings(List<LintFinding> findings) => findings
    .where((LintFinding finding) => finding.code == 'no_single_letter')
    .toList();

Future<List<LintFinding>> _analyze(Map<String, String> sources) =>
    runPluginAnalysis(
      sources: sources,
      rules: const <String, bool>{
        'no_single_letter': true,
        'no_banned_names': false,
      },
    );

const String _loopIndexExempt = '''
void main() {
  final List<int> scores = <int>[1, 2, 3];
  int runningTotal = 0;
  for (var i = 0; i < scores.length; i++) {
    runningTotal += scores[i];
  }
  for (var score in scores) {
    runningTotal += score;
  }
  for (var e in scores) {
    runningTotal += e;
  }
  for (var index = 0; index < scores.length; index++) {
    var q = scores[index];
    runningTotal += q;
  }
  print(runningTotal);
}
''';

const String _fieldsAndTopLevelSkipped = '''
int t = 0;

class Counter {
  int? c;

  Counter(this.c);

  int bump() {
    t += c ?? 0;
    return t;
  }
}

void main() {
  final Counter counter = Counter(1);
  print(counter.bump());
}
''';

const String _wildcardAndPatterns = '''
void main() {
  var _ = 1;
  print('wildcard');
  var (first, s) = (1, 2);
  print('\$first \$s');
  final List<int> rows = <int>[1];
  for (var (outer, o) in rows.map((int row) => (row, row))) {
    print('\$outer \$o');
  }
}
''';

const String _suppressionHonored = '''
void main() {
  // ignore: praxis_lints/no_single_letter
  var x = 1;
  print(x);
}
''';

void main() {
  test('flags single-letter locals', () async {
    final List<LintFinding> findings = _ruleFindings(
      await _analyze(<String, String>{'locals_flagged.dart': _localsFlagged}),
    );
    final List<LintFinding> inFile = findingsIn(
      findings,
      'locals_flagged.dart',
    );

    expect(
      inFile.map((LintFinding finding) => finding.toString()),
      hasLength(1),
      reason: 'expected exactly one no_single_letter finding, got:\n$findings',
    );
    expect(inFile.single.line, equals(2));
    expect(inFile.single.column, equals(7));
  });

  test('flags single-letter parameters', () async {
    final List<LintFinding> findings = _ruleFindings(
      await _analyze(<String, String>{'params_flagged.dart': _paramsFlagged}),
    );
    final List<LintFinding> inFile = findingsIn(
      findings,
      'params_flagged.dart',
    );

    final List<String> positions =
        inFile
            .map((LintFinding finding) => '${finding.line}:${finding.column}')
            .toList()
          ..sort();
    expect(
      positions,
      equals(<String>['1:13', '1:20', '5:22', '9:29']),
      reason: 'expected a, b, r, n flags, got:\n$findings',
    );
  });

  test('exempts loop-header indices but flags body locals', () async {
    final List<LintFinding> findings = _ruleFindings(
      await _analyze(<String, String>{
        'loop_index_exempt.dart': _loopIndexExempt,
      }),
    );
    final List<LintFinding> inFile = findingsIn(
      findings,
      'loop_index_exempt.dart',
    );

    expect(
      inFile
          .map((LintFinding finding) => '${finding.line}:${finding.column}')
          .toList(),
      equals(<String>['14:9']),
      reason: 'expected only the body-local q flag, got:\n$findings',
    );
  });

  test('skips fields, top-level variables, and field formals', () async {
    final List<LintFinding> findings = _ruleFindings(
      await _analyze(<String, String>{
        'fields_and_top_level_skipped.dart': _fieldsAndTopLevelSkipped,
      }),
    );

    expect(
      findingsIn(findings, 'fields_and_top_level_skipped.dart'),
      isEmpty,
      reason: 'expected zero findings, got:\n$findings',
    );
  });

  test('exempts wildcards, flags pattern bindings', () async {
    final List<LintFinding> findings = _ruleFindings(
      await _analyze(<String, String>{
        'wildcard_and_patterns.dart': _wildcardAndPatterns,
      }),
    );
    final List<LintFinding> inFile = findingsIn(
      findings,
      'wildcard_and_patterns.dart',
    );

    expect(
      inFile
          .map((LintFinding finding) => '${finding.line}:${finding.column}')
          .toList(),
      equals(<String>['4:15']),
      reason: 'expected only the pattern-bound s flag, got:\n$findings',
    );
  });

  test('honors ignore comments', () async {
    final List<LintFinding> findings = _ruleFindings(
      await _analyze(<String, String>{
        'suppression_honored.dart': _suppressionHonored,
      }),
    );

    expect(
      findingsIn(findings, 'suppression_honored.dart'),
      isEmpty,
      reason: 'expected the ignore comment to suppress, got:\n$findings',
    );
  });

  test('reports deterministically across runs', () async {
    final Map<String, String> sources = <String, String>{
      'locals_flagged.dart': _localsFlagged,
      'params_flagged.dart': _paramsFlagged,
    };
    final List<String> first = (await _analyze(
      sources,
    )).map((LintFinding finding) => finding.toString()).toList()..sort();
    final List<String> second = (await _analyze(
      sources,
    )).map((LintFinding finding) => finding.toString()).toList()..sort();

    expect(second, equals(first));
    expect(first, isNotEmpty);
  });
}
