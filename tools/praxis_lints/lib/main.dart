// Praxis house-rule analyzer plugin (dev-only tooling, never public API).
//
// ## Which rule?
//
// | Symptom | Rule |
// | --- | --- |
// | `var x = 1`, `int add(int a, int b)` — a name no one can grep | `no_single_letter` |
// | `var data = rows`, `void save(String res)` — a name that says nothing | `no_banned_names` |
//
// Both rules encode thesis invariant 3 ("names a stranger can grep") and
// stay out of the SDK's way: `dart analyze` checks identifier *style*, it
// never judges length or meaning. Enable them per rule from the consuming
// package:
//
// ```yaml
// plugins:
//   praxis_lints:
//     path: tools/praxis_lints
//     diagnostics:
//       no_single_letter: true
//       no_banned_names: true
// ```
library;

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/no_banned_names.dart';
import 'src/no_single_letter.dart';

/// The Praxis house-rule plugin, registering every rule below as an
/// opt-in lint (enabled per rule through `diagnostics:`, never by
/// default).
final class PraxisLintsPlugin extends Plugin {
  /// Creates the plugin with the default-seeded rules.
  PraxisLintsPlugin();

  @override
  String get name => 'praxis_lints';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerLintRule(NoSingleLetterRule())
      ..registerLintRule(NoBannedNamesRule());
  }
}

/// Plugin entrypoint required by the analysis server.
///
/// The name `plugin` is a framework contract — the generated loader
/// imports this file and reads this exact top-level variable — not a
/// house-style choice (thesis invariant 3 would otherwise forbid so
/// generic a name).
final Plugin plugin = PraxisLintsPlugin();
