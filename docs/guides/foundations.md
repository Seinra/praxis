# Foundations — the generics mechanism, from concrete to generic

**Version:** praxis `0.1.0-dev` on Dart `^3.13.0`.
**Prereqs:** Dart SDK. No generics knowledge — this guide teaches it.

After this guide you read any generic signature in Praxis: what `<OutcomeValue>`
declares, what a constraint promises, when the compiler fills in the types,
why some APIs spell their types out, and where Dart draws its lines
(no zero value to lean on, cooperative cancellation instead of contexts).

> API source: the doc comments in `lib/src/` are the reference; this guide is
> the bridge. Every runnable line here is asserted by
> `test/docs_guides_a_test.dart` — same outputs.

## Concept

Generics remove repetition, not types. You write the concrete version first;
when the same shape repeats for another type, you name the varying part:

```dart
List<int> doubleInts(List<int> scores) => scores.map((int score) => score * 2).toList();
// becomes
List<Transformed> mapScores<Element, Transformed>(List<Element> scores, Transformed Function(Element) transform) =>
    scores.map(transform).toList();
```

`<Element>` declares a *type parameter*: a placeholder the caller fills with a
real type, once per call. The house rule (SDK-first) stays: you reach for a
type parameter only when the SDK cannot say it — `List`, `Map`, `Set`, and
`Iterable` own the concrete shapes, Praxis adds the missing generic ones
(`lib/src/result.dart`, `lib/src/lists.dart`).

## Steps

1. Declare the parameter where the type varies: `Result<OutcomeValue>`,
   `findElement<Element>(List<Element> elements, ...)`.
2. Constrain only what the body needs — nothing more: unbounded parameters
   accept everything, `extends Comparable<Object>` allows ordering.
3. Let the compiler infer from value arguments and context; spell types out
   only where inference has nothing to read (zero-argument constructors like
   `const Opt<int>.absent()`).
4. Put behavior on values, never on missing ones: you read absence with the
   records-as-OrNull shape (`(value, present)`), `Opt`, or `Result` — you never
   branch on a nullable you could have typed.

## Type parameters: declare once, fill per call

A type parameter list lives in angle brackets after the function or class name.
Each use fills every parameter with a real type:

```dart
Future<List<Output>> flowMap<Input, Output>(Iterable<Input> inputs, ...);
```

(`lib/src/flow.dart`). `Input` says "whatever the caller iterates";
`Output` says "whatever the transform produces". Constructors declare the most
parameters because they create from nothing; methods reuse their owner's.

## Constraints: promise only what the body uses

| Constraint | Promises | Praxis use |
| --- | --- | --- |
| unbounded (`<Key>`, `<Value>`) | nothing; accepts every type | payloads carried untouched (`mapx`, `either`, `opt`) |
| `Element extends Comparable<Object>` | ordering (`compareTo`) | `minElement`/`maxElement` over ordered elements (`lib/src/lists.dart`) |

The bound is `Comparable<Object>`, not `Comparable<Element>`: `int` implements
`Comparable<num>`, so an `Element`-bound would reject the most common element
type. You constrain the operation the body performs, never the caller's type.

## Inference: read from the values, all or nothing

When the arguments pin every parameter, the call site stays clean:

```dart
findElement(<int>[72, 91, 85], (int score) => score > 80)
```

No type list written — `Element` comes from the list. Two rules, no exceptions:

- Either the arguments plus the context type pin **all** parameters, or you
  write them explicitly. No partial lists.
- Zero-argument constructors give inference nothing to read, so they spell it
  out: `const Opt<int>.absent()`, `Result<int>.failure(...)`. A constructor
  that names only one side needs help too: `Either<String, int>.left(...)`
  pins the left from the value and the right from the list.

## Sealed types and patterns: every side checked

`Result`, `Opt`, and `Either` are `sealed`: the compiler knows every side, so
a `switch` that forgets one side fails to compile instead of failing at
runtime. You split with `when`, you transform with `mapValue`/`andThen`, and
absence travels through untouched — it never slips past silently.

```dart
final String label = Result<int>.ok(21).when(
  ok: (int successValue) => 'ok:$successValue',
  failure: (Exception failureCause) => 'failure',
);
```

You match on the side, never on the value. Casts and `!` assertions have no
place here: the pair already proved which side you hold.

## Records-as-OrNull: never trust the value without the flag

Dart records carry the Axiom `(T, bool)` discipline as `(value, present)`:

```dart
final ({int? value, bool present}) found = findElement(
  <int>[72, 91, 85],
  (int score) => score > 80,
);
```

`present` reports presence and `value` is `null` when absent. Empty input or
no match is a normal outcome here, never an error. A list may itself hold
`null` elements, so only the flag tells a found `null` from an absent one —
you check `present` first, every time.

## No zero value: assign it or it does not compile

Dart gives you no usable zero value to lean on. An unassigned non-nullable
local is a compile error, never a silent default; a nullable defaults to
`null`. Each shape states its own rule — you read it, you never guess:

| Shape | Rule |
| --- | --- |
| `Result` / `Opt` / `Either` | No "zero" instance exists: you build with `ok`/`failure`, `present`/`absent`, `left`/`right`. |
| `lists` / `mapx` / `set` / `iterx` | Empty input is a normal outcome (flag `false`, empty collection), never an error. |
| `FlowScope` | A fresh scope is open (`isStopped` is `false`); once stopped it stays stopped. |
| `Failure` cause | Never `null` — the constructor requires an `Exception`. |

## Cancellation without contexts: one flag, one rule

Dart ships no `context.Context` equivalent, so cancellation stays cooperative
by language design. `FlowScope` (`lib/src/flow.dart`) names that discipline:
one caller-owned stop signal shared by one `flow` call, and one rule — the
combinator stops *starting* new work while in-flight futures run to completion,
because Dart futures are not preemptible.

You keep the outside handle: you call `stop` — on dispose, for example — and
the run settles instead of starting more. Each combinator also stops its scope
on its own terminal event (`flowMap` on the first task failure, `flowFirst` on
the first success; `flowCollect` never stops it because failures ride as
`Result` values beside successes). When you pass no scope, the call builds one
internal scope that stays private to that call. There is exactly one stop path
— a single `isStopped` flag — whether the stop comes from inside the combinator
or from you outside it.

## Which mechanism?

| When you hold ... | Reach for ... |
| --- | --- |
| a value of unknown type to carry through | an unbounded type parameter |
| values to order, min, or max | an `extends Comparable<Object>` parameter |
| absence without a cause | `Opt`, or the `(value, present)` record |
| absence with a cause | `Result` |
| two plain alternatives, neither favoured | `Either` |
| a bounded run you can stop from the outside | `FlowScope` plus the `flow` combinators (`lib/src/flow.dart`) |

## Example

Runnable — asserted by `test/docs_guides_a_test.dart` (same outputs):

```dart
import 'package:praxis/src/lists.dart';
import 'package:praxis/src/opt.dart';
import 'package:praxis/src/result.dart';

void main() {
  // Inference from value arguments: no type list written.
  final List<int> doubled = <int>[1, 2, 3]
      .map((int score) => score * 2)
      .toList();
  print(doubled); // [2, 4, 6]

  // Explicit where inference has nothing to read: zero-argument constructor.
  print(const Opt<int>.absent().valueOr(0)); // 0

  // Records-as-OrNull: presence rides beside the value.
  final ({int? value, bool present}) found = findElement(
    <int>[72, 91, 85],
    (int score) => score > 80,
  );
  print(found.present ? found.value : -1); // 91

  // Sealed patterns stay exhaustive: the compiler checks every side.
  final String label = Result<int>.ok(21).when(
    ok: (int successValue) => 'ok:${successValue * 2}',
    failure: (Exception failureCause) => 'failure',
  );
  print(label); // ok:42
}
```

Expected output:

```text
[2, 4, 6]
0
91
ok:42
```

## Checklist

- [ ] You can name which parameter each value argument fills in a generic call.
- [ ] You can say when explicit type arguments are required (zero-argument constructors, half-pinned sides).
- [ ] You can state the records-as-OrNull rule in one sentence (presence rides beside the value; you never trust the value without the flag).
- [ ] You can state the FlowScope rule in one sentence (one caller-owned flag; stops stop *starting* work, in-flight work runs to completion).

## Next step

- Apply it per package: [result](result.md), [opt](opt.md), [lists](lists.md) — every guide assumes this chapter.
- Reshape keyed and distinct holdings: [mapx](mapx.md), [set](set.md), [iterx](iterx.md).
- Hold two plain alternatives: [either](either.md).
