// End-to-end pins for the `no_banned_names` house rule.
//
// The plugin runs for real: each test analyzes a scratch package with the
// rule enabled and asserts the exact reported spans.
@Timeout(Duration(minutes: 5))
library;

import 'package:test/test.dart';

import 'lint_fixture.dart';

const String _bannedFlagged = '''
int total(int data, int item) {
  var res = data + item;
  var err = 0;
  var ctx = 'none';
  var req = 1;
  var cfg = 2;
  var usr = 'ann';
  var mgr = 'bo';
  var svc = 'svc';
  var tmp = res + err + req + cfg;
  var temp = tmp;
  var val = temp;
  var obj = val;
  print('\$res \$err \$ctx \$req \$cfg \$usr \$mgr \$svc \$tmp \$temp \$val \$obj');
  return res;
}
''';

const String _nearMissClean = '''
void main() {
  final List<int> database = <int>[1];
  final int items = database.length;
  final int results = items + 1;
  final String error = 'none';
  final String context = 'ctx-free';
  final int dataSize = results;
  final int Res = 1;
  print('\$database \$items \$results \$error \$context \$dataSize \$Res');
}
''';

const String _scopeEdges = '''
String data = 'top';

class Cache {
  String item = 'field';

  String load(String res) {
    return '\$data \$item \$res';
  }
}

void main() {
  final Cache cache = Cache();
  print(cache.load('ok'));
}
''';

const String _suppressionHonored = '''
void main() {
  // ignore: praxis_lints/no_banned_names
  var data = <int>[1];
  print(data);
}
''';

List<LintFinding> _ruleFindings(List<LintFinding> findings) => findings
    .where((LintFinding finding) => finding.code == 'no_banned_names')
    .toList();

Future<List<LintFinding>> _analyze(Map<String, String> sources) =>
    runPluginAnalysis(
      sources: sources,
      rules: const <String, bool>{
        'no_single_letter': false,
        'no_banned_names': true,
      },
    );

void main() {
  test('flags every seeded denylist name', () async {
    final List<LintFinding> findings = _ruleFindings(
      await _analyze(<String, String>{'banned_flagged.dart': _bannedFlagged}),
    );
    final List<LintFinding> inFile = findingsIn(
      findings,
      'banned_flagged.dart',
    );

    final List<String> positions =
        inFile
            .map((LintFinding finding) => '${finding.line}:${finding.column}')
            .toList()
          ..sort();
    expect(
      positions,
      equals(<String>[
        '10:7',
        '11:7',
        '12:7',
        '13:7',
        '1:15',
        '1:25',
        '2:7',
        '3:7',
        '4:7',
        '5:7',
        '6:7',
        '7:7',
        '8:7',
        '9:7',
      ]),
      reason: 'expected all 14 seeded names flagged, got:\n$findings',
    );
  });

  test('ignores near misses and capitalized names', () async {
    final List<LintFinding> findings = _ruleFindings(
      await _analyze(<String, String>{'near_miss_clean.dart': _nearMissClean}),
    );

    expect(
      findingsIn(findings, 'near_miss_clean.dart'),
      isEmpty,
      reason: 'expected zero findings, got:\n$findings',
    );
  });

  test('skips fields and top-level names, flags params', () async {
    final List<LintFinding> findings = _ruleFindings(
      await _analyze(<String, String>{'scope_edges.dart': _scopeEdges}),
    );
    final List<LintFinding> inFile = findingsIn(findings, 'scope_edges.dart');

    expect(
      inFile
          .map((LintFinding finding) => '${finding.line}:${finding.column}')
          .toList(),
      equals(<String>['6:22']),
      reason: 'expected only the res param flag, got:\n$findings',
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
      'banned_flagged.dart': _bannedFlagged,
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
