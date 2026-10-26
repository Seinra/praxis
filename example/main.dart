// Praxis example: typed helpers for results, options, and bounded flow.
//
// Run with `dart run example/main.dart`. Every line below mirrors a
// CI-executed documented example in `lib/src/`, so the output here stays
// pinned by `dart test`.
import 'package:praxis/praxis.dart';

Future<void> main() async {
  // Result: success-or-failure without exceptions for expected cases.
  final Result<int> doubled = Result<int>.ok(21).mapValue((value) => value * 2);
  assert(doubled.getOrElse(0) == 42);

  // Opt: a maybe-present value without null checks.
  const Opt<String> name = Opt.present('praxis');
  assert(name.valueOr('') == 'praxis');

  // Flow: bounded concurrency with a caller-owned stop signal.
  final FlowScope scope = FlowScope();
  final List<int> outputs = await flowMap(
    <int>[1, 2, 3],
    maxInflight: 2,
    transform: (int input, FlowScope _) async => input * 2,
    scope: scope,
  );
  assert(outputs.join(',') == '2,4,6');
}
