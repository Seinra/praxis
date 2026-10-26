/// Praxis — the Echo of Dart generics.
///
/// One small, dependable library that makes the hard parts of generics easy,
/// so apps like Catalyst teach and ship typed code instead of `dynamic` soup.
///
/// Which package?
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | a success-or-failure outcome | `result` ([Result], [Ok], [Failure]) |
/// | a maybe-present value | `opt` ([Opt], [Some], [None]) |
/// | a list to transform, find, or fold | lists ([findElement], [minElement], [maxElement], [chunkElements], [partitionElements]) |
/// | a lazy `Iterable` pipeline to pull on demand | `iterx` ([zipIterables], [chunkedIterable], [windowedIterable], [cycleIterable], [repeatElement], [deduplicateAdjacent]) — reach for `iterx` when the source is an `Iterable` or the pipeline should stay lazy; reach for the eager `lists` helpers when the input is already a `List` and you want a finished value in one pass |
/// | distinct values to combine or compare | `set` ([symmetricDifference], [isSubsetOf], [isSupersetOf], [isDisjointFrom], [hasSameMembers]) |
/// | a builtin map to reshape | `mapx` ([invertEntries], [pickEntries], [omitEntries], [mapValues], [mapKeys], [groupEntriesBy]) |
/// | predicates to combine (And / Or / Not) | `valid` ([Predicate], [andPredicates], [orPredicates], [notPredicate], [alwaysTrue], [alwaysFalse]) |
/// | text to split or cut by runes | `strings` ([splitWords], [chunkString], [truncateRunes], [takeRunes], [dropRunes], [truncateWithEllipsis], [defaultEllipsisMark]) |
/// | whole numbers to test, divide, or combine | `mathx` ([isPrime], [primesUpTo], [lcm]) |
/// | transforms with a cap, first success, or one outcome per input | `flow` ([FlowScope], [flowMap], [flowFirst], [flowCollect]) |
/// | objects to reuse instead of rebuild | `pool` ([Pool], [Pool.acquire], [Pool.release], [Pool.use], [Pool.idleCount], [Pool.maxSize]) |
/// | one shared execution across same-key callers | `singleflight` ([SingleflightGroup], [SingleflightGroup.call]) |
/// | named singleton services | `di` ([ServiceContainer], [ServiceContainer.register], [ServiceContainer.resolve], [ServiceContainer.unregister], [ServiceContainer.reset]) |
/// | two typed sides (left / right) | `either` ([Either], [Either.left], [Either.right], [Left], [Right]) |
/// | identity-addressed records with typed access | `repo` ([Repository], [Repository.put], [Repository.get], [Repository.remove], [Repository.list]) |
/// | a typed JSON envelope over HTTP | `httpx` ([HttpxTransport], [HttpxRequest], [HttpxResponse], [httpxGet], [httpxPost], [HttpxStatusFailure], [HttpxTransportFailure], [HttpxCodecFailure]) |
/// | values in last-in-first-out order | `stack` ([Stack], [Stack.push], [Stack.pop], [Stack.peek]) |
/// | values in first-in-first-out order | `queue` ([FifoQueue], [FifoQueue.enqueue], [FifoQueue.dequeue], [FifoQueue.peek]) |
/// | keys in insertion order, or bounded recent use | `orderedmap` ([OrderedMap], [OrderedMap.put], [OrderedMap.get], [OrderedMap.remove], [LruCache]) |
/// | a background computation to join later | `task` ([Task], [Task.spawn], [Task.join]) |
/// | left-to-right and right-to-left function composition | `pipe` ([pipe], [compose]) |
///
/// Skeleton ships `result` + `opt` + lists, the set slice ships `set`, the
/// mapx slice ships `mapx`, the iterx slice ships `iterx`, the valid slice
/// ships `valid`, the strings slice ships `strings`, the mathx slice ships
/// `mathx`, the flow slice ships `flow`, the pool slice ships `pool`, and the singleflight slice ships `singleflight`, the di slice ships `di`, and the repo slice ships `repo`, and the httpx slice ships `httpx`, and the collections slice ships `stack` + `queue` + `orderedmap`, and the task slice ships `task`, and the pipecompose slice ships `pipe`, and the either slice ships `either`; everything else is declared future scope, never stubbed (see `README.md`).
///
/// Available since praxis `0.1.0`; requires Dart `^3.13.0`.
library;

export 'src/di.dart';
export 'src/either.dart';
export 'src/flow.dart';
export 'src/httpx.dart';
export 'src/iterx.dart';
export 'src/lists.dart';
export 'src/mapx.dart';
export 'src/mathx.dart';
export 'src/opt.dart';
export 'src/orderedmap.dart';
export 'src/pipe.dart';
export 'src/pool.dart';
export 'src/queue.dart';
export 'src/repo.dart';
export 'src/result.dart';
export 'src/set.dart';
export 'src/singleflight.dart';
export 'src/stack.dart';
export 'src/strings.dart';
export 'src/task.dart';
export 'src/valid.dart';
