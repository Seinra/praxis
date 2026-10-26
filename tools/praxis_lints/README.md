# praxis_lints — house-rule analyzer plugin

You enable two opt-in lints that keep names grep-able, run `dart analyze`, and rename whatever gets flagged.

**Version:** 0.1.0-dev on Dart ^3.13.0
**Prereqs:** Dart `^3.13.0` in your `PATH`, plus this tool folder inside your Praxis checkout (the plugin ships as a path dependency while Praxis stays private).

## Quick path

1. Enable the rules you want in your `analysis_options.yaml`.
2. Run `dart analyze` and read the `no_single_letter` / `no_banned_names` findings.
3. Rename each flagged local or parameter after what the value holds.

## Which rule?

| Symptom | Rule |
| --- | --- |
| `var x = 1`, `int add(int a, int b)` — a name no one can grep | `no_single_letter` |
| `var data = rows`, `void save(String res)` — a name that says nothing | `no_banned_names` |

Both rules check locals and parameters only. Fields, top-level variables, field-formal and super parameters, catch-clause parameters, the wildcard `_`, and short indices in for-loop headers stay out of scope.

## Enable the plugin

Add a top-level `plugins:` section naming each rule under `diagnostics:`:

```yaml
plugins:
  praxis_lints:
    path: tools/praxis_lints
    diagnostics:
      no_single_letter: true
      no_banned_names: true
```

Restart the analysis server after changing this section.

## `no_single_letter` — violation becomes clean

Violation:

```dart
void main() {
  var x = 1;
  print(x);
}
```

Clean (runnable — packaged as `example/no_single_letter.dart`):

```dart
int totalScores(List<int> scores) {
  int runningTotal = 0;
  for (int scoreIndex = 0; scoreIndex < scores.length; scoreIndex++) {
    runningTotal += scores[scoreIndex];
  }
  return runningTotal;
}
```

Parameters flag the same way: `int add(int a, int b)` reports `a` and `b`; rename them after what they carry.

## `no_banned_names` — violation becomes clean

Violation:

```dart
int countTotals(List<int> data) {
  return data.length;
}
```

Clean (runnable — packaged as `example/no_banned_names.dart`):

```dart
int countScores(List<int> scores) {
  return scores.length;
}
```

The denylist seeds `data`, `item`, `res`, `err`, `ctx`, `req`, `cfg`, `usr`, `mgr`, `svc`, `tmp`, `temp`, `val`, and `obj`. Matching is exact and case-sensitive, so `database` or `items` never trip the rule.

## Checklist

- [ ] `dart analyze` reports each violation above under its rule code
- [ ] `dart analyze` stays silent over `example/no_single_letter.dart` and `example/no_banned_names.dart`
- [ ] Every snippet on this page maps to a CI-executed test (`test/tool/` pins the shapes, `test/docs_plugin_test.dart` pins this page)

## Next step

Read the rule sources beside the plugin entrypoint (`lib/main.dart`, `lib/src/`) for scope edges and suppression.
