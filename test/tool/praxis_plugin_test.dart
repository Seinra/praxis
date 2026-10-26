// Smoke pin for the plugin entrypoint: both rules fire in one run.
//
// The per-rule suites prove each rule's behavior; this file proves the
// entrypoint registers both and that the two rules do not interfere.
@Timeout(Duration(minutes: 5))
library;

import 'package:test/test.dart';

import 'lint_fixture.dart';

const String _bothRules = '''
void main() {
  var x = 1;
  var data = <int>[x];
  print(data);
}
''';

void main() {
  test('registers and runs both rules together', () async {
    final List<LintFinding> findings = await runPluginAnalysis(
      sources: <String, String>{'both_rules.dart': _bothRules},
      rules: const <String, bool>{
        'no_single_letter': true,
        'no_banned_names': true,
      },
    );
    final List<LintFinding> inFile = findingsIn(findings, 'both_rules.dart');

    expect(
      inFile
          .map(
            (LintFinding finding) =>
                '${finding.code}@${finding.line}:${finding.column}',
          )
          .toList(),
      equals(<String>['no_single_letter@2:7', 'no_banned_names@3:7']),
      reason: 'expected one finding per rule, got:\n$findings',
    );
  });

  test('disabled rules stay silent', () async {
    final List<LintFinding> findings = await runPluginAnalysis(
      sources: <String, String>{'both_rules.dart': _bothRules},
      rules: const <String, bool>{
        'no_single_letter': false,
        'no_banned_names': false,
      },
    );

    expect(
      findingsIn(findings, 'both_rules.dart'),
      isEmpty,
      reason: 'expected zero findings with both rules off, got:\n$findings',
    );
  });
}
