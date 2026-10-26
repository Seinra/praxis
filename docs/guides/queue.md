# queue — values first-in, first-out

You serve the longest waiting first: you add at the back with `enqueue`,
you serve with `dequeue`, you peek with `peek`, and an empty queue
answers absence instead of throwing.

**Version:** Praxis `0.1.0`, Dart `^3.13.0`.
**Prereqs:** `import 'package:praxis/praxis.dart';` exposes `FifoQueue`.

## Concept

`dart:collection` `Queue` (`ListQueue`) owns double-ended ops, but
`removeFirst` and `first` throw on empty input — absence travels as a
throw, never as a value. `FifoQueue` fills that gap with absent-safe
`dequeue` and `peek` answering the `(value, present)` record, plus
grep-able `enqueue`/`dequeue` names that say FIFO where `add`/`removeFirst`
say double-ended storage. The SDK name `Queue` stays untouched: this
holder is `FifoQueue` so imports never clash with `dart:collection`.

## Quick path

1. Build an empty queue: `FifoQueue<String>()`.
2. Add at the back: `waitingWords.enqueue('fig')`.
3. Read without serving: `waitingWords.peek()`.
4. Serve the front: `waitingWords.dequeue()`.
5. Branch on `present`, then trust `value`; ask `length`, `isEmpty`, or
   `isNotEmpty` for the depth.

## Which function?

The package doc (`lib/src/queue.dart`) is the source; this table mirrors
its "Which function?" table:

| When you want to ...                    | Reach for ...       |
| --------------------------------------- | ------------------- |
| Hold values first-in first-out          | [FifoQueue]         |
| Build an empty queue                    | [FifoQueue.new]     |
| Add a value at the back                 | [FifoQueue.enqueue] |
| Remove and return the front value       | [FifoQueue.dequeue] |
| Read the front value without removing   | [FifoQueue.peek]    |
| Count waiting values                    | [FifoQueue.length]  |
| Ask whether the queue holds nothing     | [FifoQueue.isEmpty] |
| Ask whether the queue holds something   | [FifoQueue.isNotEmpty] |

## Example

Example contents are asserted by `test/docs_guides_c_test.dart` (group `queue guide`):

```dart
import 'package:praxis/praxis.dart';

void main() {
  final FifoQueue<String> waitingWords = FifoQueue<String>();
  waitingWords.enqueue('fig');
  waitingWords.enqueue('pear');
  print(waitingWords.dequeue().value); // Output: fig
  print(waitingWords.peek().value); // Output: pear
  print(waitingWords.length); // Output: 1
}
```

Expected output:

```text
fig
pear
1
```

Run it: `dart test test/docs_guides_c_test.dart -n 'queue guide'`.

> [!WARNING]
> Never trust `value` without checking `present` first: the queue may
> itself hold `null` elements, so only the flag tells a held `null` from
> an absent one. Never reach for this holder for double-ended work
> either — `addFirst`/`removeLast` discipline belongs to the
> `dart:collection` `Queue` directly, never to a FIFO holder.

## Contracts and errors

| Contract | What it means for you |
| --- | --- |
| Empty is absence, never a throw | `dequeue` and `peek` on an empty queue answer `(value: null, present: false)`; nothing here throws for empty input. |
| FIFO order always holds | Enqueues land at the back and dequeues leave from the front, so the longest-waiting value serves first. |
| Serving stays amortized O(1) | `dequeue` advances a head offset instead of shifting; the consumed prefix compacts once it grows long, and served slots clear so values stay collectable. |
| Inputs are never aliased | Constructors take no caller collections, so there is no aliasing surface; answers are fresh records or values leaving on `dequeue`. |

## When to use the stdlib directly

Reach for the `dart:collection` `Queue` directly when double-ended ops
are the job: you add or remove at either end and empty-input throws fit
your error policy. Reach for a plain `List` when indexed access or
searching leads. Reach for `FifoQueue` when the call order is "serve the
longest waiting first" and every empty read should answer absence
instead of throwing.

## Checklist

- [ ] You can state the empty rule in one sentence (`dequeue` and `peek` on an empty queue answer `(value: null, present: false)` — never a throw).
- [ ] You can state the order rule in one sentence (enqueues land at the back and dequeues leave from the front, so the longest-waiting value serves first).
- [ ] You reach for `dart:collection` `Queue` when double-ended ops are the job, and for `FifoQueue` when every empty read must answer absence.

## Next step

When the line also needs lookup by key in insertion order, see
[orderedmap](orderedmap.md) for ordered entries plus a bounded recency
cache.
