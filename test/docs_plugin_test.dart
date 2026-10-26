// Companion pins for tools/praxis_lints/README.md.
//
// Every snippet on the plugin page maps to a CI-executed test: the
// violation halves reuse the shapes pinned in test/tool (single-letter
// locals and params, seeded denylist names), and this file pins the gap —
// the packaged clean examples on disk stay silent under their rule while
// the exact README violation text still flags. The README enable snippet
// uses the same top-level `plugins:` plus `diagnostics:` shape this
// harness writes into every scratch package, so the run itself verifies it.
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';

import 'package:test/test.dart';

import 'tool/lint_fixture.dart';

/// The exact `no_single_letter` violation from the plugin README.
const String _singleLetterViolation = '''
void main() {
  var x = 1;
  print(x);
}
''';

/// The exact `no_banned_names` violation from the plugin README.
const String _bannedNameViolation = '''
int countTotals(List<int> data) {
  return data.length;
}
''';

/// Findings for [ruleCode] reported in [fileName].
List<LintFinding> _ruleFindingsIn(
  List<LintFinding> findings,
  String fileName,
  String ruleCode,
) => findings
    .where(
      (LintFinding finding) =>
          finding.fileName == fileName && finding.code == ruleCode,
    )
    .toList();

void main() {
  test(
    'readme pairs hold: violations flag, clean examples stay silent',
    () async {
      final String singleLetterClean = File(
        'tools/praxis_lints/example/no_single_letter.dart',
      ).readAsStringSync();
      final String bannedNamesClean = File(
        'tools/praxis_lints/example/no_banned_names.dart',
      ).readAsStringSync();
      final List<LintFinding> findings = await runPluginAnalysis(
        sources: <String, String>{
          'single_violation.dart': _singleLetterViolation,
          'single_clean.dart': singleLetterClean,
          'banned_violation.dart': _bannedNameViolation,
          'banned_clean.dart': bannedNamesClean,
        },
        rules: const <String, bool>{
          'no_single_letter': true,
          'no_banned_names': true,
        },
      );

      final List<LintFinding> singleLetterFlags = _ruleFindingsIn(
        findings,
        'single_violation.dart',
        'no_single_letter',
      );
      expect(
        singleLetterFlags,
        hasLength(1),
        reason: 'expected the README x violation to flag, got:\n$findings',
      );
      expect(singleLetterFlags.single.line, equals(2));
      expect(
        _ruleFindingsIn(findings, 'single_clean.dart', 'no_single_letter'),
        isEmpty,
        reason: 'expected the packaged clean example silent, got:\n$findings',
      );

      final List<LintFinding> bannedNameFlags = _ruleFindingsIn(
        findings,
        'banned_violation.dart',
        'no_banned_names',
      );
      expect(
        bannedNameFlags,
        hasLength(1),
        reason: 'expected the README data violation to flag, got:\n$findings',
      );
      expect(bannedNameFlags.single.line, equals(1));
      expect(
        bannedNameFlags.single.message,
        contains('data'),
        reason: 'expected the flag to name the banned name, got:\n$findings',
      );
      expect(
        _ruleFindingsIn(findings, 'banned_clean.dart', 'no_banned_names'),
        isEmpty,
        reason: 'expected the packaged clean example silent, got:\n$findings',
      );
    },
  );
}
