// Shared end-to-end harness for the praxis_lints house-rule plugin tests.
//
// Each test builds a scratch package under the system temp directory,
// activates the plugin there with a top-level `plugins:` section, runs
// `dart analyze`, and parses the human-readable findings. Fixtures never
// touch the repository tree, so intentional violations cannot pollute the
// repo's own analyzer run.
library;

import 'dart:convert';
import 'dart:io';

/// A single `dart analyze` finding parsed from the human-readable output.
final class LintFinding {
  /// Creates a parsed finding at [line]:[column] of [fileName].
  const LintFinding({
    required this.fileName,
    required this.line,
    required this.column,
    required this.severity,
    required this.message,
    required this.code,
  });

  /// Base name of the analyzed file (for example `locals_flagged.dart`).
  final String fileName;

  /// One-based line number of the finding.
  final int line;

  /// One-based column number of the finding.
  final int column;

  /// Analyzer severity (`info`, `warning`, or `error`).
  final String severity;

  /// Human-readable problem message.
  final String message;

  /// Diagnostic code (for plugin lints this names the rule).
  final String code;

  @override
  String toString() => '$severity - $fileName:$line:$column - $message - $code';
}

/// Builds a scratch package holding [sources], enables [rules] of the
/// praxis_lints plugin for it, runs `dart analyze`, and returns every
/// parsed finding.
///
/// [sources] maps a `lib/`-relative file name to its Dart source.
/// [rules] maps a rule name to its enabled flag and is written verbatim
/// into the scratch `diagnostics:` section.
///
/// Throws a [StateError] carrying the raw analyzer output when the run
/// itself fails (missing plugin entrypoint, resolution failure, timeout).
Future<List<LintFinding>> runPluginAnalysis({
  required Map<String, String> sources,
  required Map<String, bool> rules,
}) async {
  final String pluginPath =
      '${Directory.current.path}${Platform.pathSeparator}tools'
      '${Platform.pathSeparator}praxis_lints';
  if (!Directory(pluginPath).existsSync()) {
    throw StateError(
      'praxis_lints package missing at $pluginPath; '
      'run from the repository root.',
    );
  }

  final Directory scratch = Directory.systemTemp.createTempSync(
    'praxis_lints_fixture',
  );
  try {
    File('${scratch.path}${Platform.pathSeparator}pubspec.yaml')
        .writeAsStringSync(
          'name: lint_fixture\n'
          'environment:\n'
          "  sdk: '^3.13.0'\n",
        );

    final StringBuffer diagnostics = StringBuffer();
    rules.forEach((String ruleName, bool enabled) {
      diagnostics.writeln('      $ruleName: $enabled');
    });
    File('${scratch.path}${Platform.pathSeparator}analysis_options.yaml')
        .writeAsStringSync(
          'plugins:\n'
          '  praxis_lints:\n'
          '    path: $pluginPath\n'
          '    diagnostics:\n'
          '$diagnostics',
        );

    sources.forEach((String fileName, String source) {
      File(
          '${scratch.path}${Platform.pathSeparator}lib'
          '${Platform.pathSeparator}$fileName',
        )
        ..createSync(recursive: true)
        ..writeAsStringSync(source);
    });

    final ProcessResult processResult =
        await Process.run(Platform.resolvedExecutable, <String>[
          'analyze',
          scratch.path,
        ], runInShell: false).timeout(
          const Duration(minutes: 4),
          onTimeout: () => throw StateError(
            'dart analyze timed out after 4 minutes for fixture '
            'with sources ${sources.keys.toList()}',
          ),
        );

    final String output =
        '${processResult.stdout as String}\n${processResult.stderr}';
    final List<LintFinding> findings = parseAnalyzeOutput(output);
    if (findings.isEmpty && _looksLikePluginFailure(output)) {
      throw StateError(
        'dart analyze reported no findings and looks like a plugin '
        'load failure. Raw output:\n$output',
      );
    }
    return findings;
  } finally {
    if (scratch.existsSync()) {
      scratch.deleteSync(recursive: true);
    }
  }
}

/// Parses `dart analyze` human-readable output into findings.
///
/// Observed line shape (Dart 3.13.5, verified against a scratch fixture):
/// `   info - path/to/file.dart:line:col - message - code`
/// Plugin lint codes are bare rule names (`no_single_letter`, no
/// `plugin/code` prefix). The message group is greedy up to the last
/// ` - `, so rule messages should still avoid ` - ` where possible.
List<LintFinding> parseAnalyzeOutput(String output) {
  final RegExp pattern = RegExp(
    r'^\s*(info|warning|error)\s+-\s+(\S+?):(\d+):(\d+)\s+-\s+(.+)\s+-\s+(\S+)\s*$',
  );
  final List<LintFinding> findings = <LintFinding>[];
  for (final String line in const LineSplitter().convert(output)) {
    final RegExpMatch? match = pattern.firstMatch(line);
    if (match == null) {
      continue;
    }
    final String rawPath = match.group(2)!;
    final String fileName = rawPath
        .split(RegExp(r'[/\\]'))
        .lastWhere((String part) => part.isNotEmpty);
    findings.add(
      LintFinding(
        fileName: fileName,
        line: int.parse(match.group(3)!),
        column: int.parse(match.group(4)!),
        severity: match.group(1)!,
        message: match.group(5)!,
        code: match.group(6)!,
      ),
    );
  }
  return findings;
}

/// Keeps only the findings reported in [fileName].
List<LintFinding> findingsIn(List<LintFinding> findings, String fileName) =>
    findings
        .where((LintFinding finding) => finding.fileName == fileName)
        .toList();

bool _looksLikePluginFailure(String output) {
  final String lowered = output.toLowerCase();
  return lowered.contains('failed to load') ||
      lowered.contains('plugin') && lowered.contains('error');
}
