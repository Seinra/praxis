# stack — values last-in, first-out

You undo the most recent first: you add with `push`, you take with `pop`,
you peek with `peek`, and an empty stack answers absence instead of
throwing.

**Version:** Praxis `0.1.0`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';` exposes `Stack`.

## Concept

`List.add`, `List.removeLast`, and `List.last` already move indexed
elements, but `removeLast` throws `StateError` on empty input and `last`
throws too — absence travels as a throw, never as a value. `Stack` fills
that gap with absent-safe `pop` and `peek` answering the `(value, present)`
record, plus grep-able `push`/`pop`/`peek` names that say LIFO where
`add`/`removeLast`/`last` say indexed list. The holder owns only
top-of-pile discipline: indexed access, sorting, and searching stay with
the `List`.

## Quick path

1. Build an empty stack: `Stack<int>()`.
2. Add on top: `heldScores.push(72)`.
3. Read without removing: `heldScores.peek()`.
4. Remove and read: `heldScores.pop()`.
5. Branch on `present`, then trust `value`; ask `length`, `isEmpty`, or
   `isNotEmpty` for the depth.

## Which function?

The package doc (`lib/src/stack.dart`) is the source; this table mirrors
its "Which function?" table:

| When you want to ...                  | Reach for ... |
| ------------------------------------- | ------------- |
| Hold values last-in first-out         | [Stack]       |
| Build an empty stack                  | [Stack.new]   |
| Add a value on top                    | [Stack.push]  |
| Remove and return the top value       | [Stack.pop]   |
| Read the top value without removing   | [Stack.peek]  |
| Count held values                     | [Stack.length] |
| Ask whether the stack holds nothing   | [Stack.isEmpty] |
| Ask whether the stack holds something | [Stack.isNotEmpty] |

## Example

Example contents are asserted by `test/docs_guides_c_test.dart` (group `stack guide`):

```dart
import 'package:praxis/praxis.dart';

void main() {
  final Stack<int> heldScores = Stack<int>();
  heldScores.push(72);
  heldScores.push(91);
  print(heldScores.pop().value); // Output: 91
  print(heldScores.peek().value); // Output: 72
  print(heldScores.length); // Output: 1
}
```

Expected output:

```text
91
72
1
```

Run it: `dart test test/docs_guides_c_test.dart -n 'stack guide'`.

> [!WARNING]
> Never trust `value` without checking `present` first. A stack may itself
> hold `null` elements, so only the flag tells a held `null` from an
> absent one. An empty `pop` or `peek` yields `(value: null, present:
> false)`: a normal outcome here, never an error — do not wrap it in
> `try`/`catch` or pre-check `isEmpty` as if absence were exceptional.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| Empty is absence, never a throw | `pop` and `peek` on an empty stack answer `(value: null, present: false)`; nothing here throws for empty input. |
| LIFO order always holds | Pushes land on top and pops leave from the top, so the most recently pushed value serves first. |
| Tail ops stay amortized O(1) | `push` and `pop` work on the tail of the private backing list. |
| Draining reuses the backing | Popping everything keeps the holder ready for reuse; start a fresh `Stack` to release memory. |
| Inputs are never aliased | Constructors take no caller collections, so there is no aliasing surface; answers are fresh records or values leaving on `pop`. |

## When to use the stdlib directly

Reach for the `List` directly when indexed access, sorting, or searching
is the job: you read by position, you reorder, or you scan with `where`
and `map`. Reach for `Stack` when the call order is "undo the most
recent first" and every empty read should answer absence instead of
throwing.

## Checklist

- [ ] You can state the empty rule in one sentence (`pop` and `peek` on an empty stack answer `(value: null, present: false)` — never a throw).
- [ ] You can state the order rule in one sentence (pushes land on top and pops leave from the top, so the most recent push serves first).
- [ ] You branch on `present` before trusting `value`, even when the held element could itself be `null`.

## Next step

When the call order flips to longest-waiting-first, see
[queue](queue.md) for the FIFO holder with the same absence contract.
