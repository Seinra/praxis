/// Named lazy-singleton services over explicit factories.
///
/// Reach for this when a [Map] names the storage but not the lifecycle:
/// [ServiceContainer] holds one factory per service name,
/// [ServiceContainer.register] names the factory plus an optional dispose
/// hook, [ServiceContainer.resolve] builds the singleton once on first use
/// and caches it, [ServiceContainer.unregister] drops one registration for
/// tests, and [ServiceContainer.reset] tears every registration down in
/// reverse order. Factories are sync only: waiting, async builds, scopes,
/// and hierarchies stay out of scope.
///
/// Which function?
///
/// | When you want to ...                                  | Reach for ...                 |
/// | ----------------------------------------------------- | ----------------------------- |
/// | Hold one key space of named singletons                | [ServiceContainer]            |
/// | Name a lazy factory plus an optional dispose hook     | [ServiceContainer.register]   |
/// | Read the shared singleton, building once on first use | [ServiceContainer.resolve]    |
/// | Drop one registration, disposing when built           | [ServiceContainer.unregister] |
/// | Tear every registration down in reverse order         | [ServiceContainer.reset]      |
///
/// Out of scope by design: async factories (that design belongs to a future
/// `flow`-crossing slice, never here), scopes and hierarchies (a future
/// design, never this slice), auto-wiring and reflection (thesis invariant
/// 10 — factories stay explicit closures), and cycle detection (a factory
/// that transitively resolves its own service recurses, which is a
/// programmer error, never a checked failure).
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
library;

/// Holds one lazy singleton per service name behind explicit factories.
///
/// The container is caller-owned mutable state: [register] names a factory
/// per service name, [resolve] builds each singleton once on first use and
/// caches it, [unregister] drops one registration for tests, and [reset]
/// tears every registration down in reverse registration order. The table
/// type-erases internally as [Object] but [Object] never leaks through the
/// public API — every crossing is gated by a generic [resolve] that returns
/// the requested type or throws. There is no global registry: tests create
/// a fresh container per test instead of sharing one.
///
/// Which-table row:
///
/// | If you hold ... | Reach for |
/// | --- | --- |
/// | named singleton services | [ServiceContainer] |
///
/// Stdlib gap (DART-SDK): [Map] names keyed storage but no lifecycle — no
/// lazy-once build, no failing-build retry, no reverse-order dispose — so
/// [ServiceContainer] owns that lifecycle as a hand-rolled slot table over
/// an SDK map, never a reimplementation. Fidelity note (AXIOM-SISTER):
/// mirrors Axiom's `di` discipline (named registration, lazy singletons,
/// first registration wins, failing builds retry) without Go signatures:
/// sync factories instead of error-returning constructors, [StateError]
/// instead of sentinel errors, and no `Replace` — [unregister] plus
/// [register] covers the test-seed swap in this slice.
///
/// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
///
/// ```dart
/// final ServiceContainer services = ServiceContainer();
/// services.register<String>('greeting', () => 'hello');
/// // services.resolve<String>('greeting') == 'hello'
/// ```
final class ServiceContainer {
  /// Creates an empty container holding no registrations.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | an empty key space to fill with named singletons | [ServiceContainer.new] |
  ///
  /// Stdlib gap (DART-SDK): no SDK constructor names a keyed singleton
  /// lifecycle, so [ServiceContainer.new] names the empty slot table that
  /// [ServiceContainer.register] fills entry by entry.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final ServiceContainer services = ServiceContainer();
  /// services.register<String>('greeting', () => 'hello');
  /// // services.resolve<String>('greeting') == 'hello'
  /// ```
  ServiceContainer();

  final Map<String, _ServiceSlot> _slotsByName = <String, _ServiceSlot>{};

  /// Registers [create] as the lazy factory for [serviceName].
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a name plus a factory to build once on first use | [ServiceContainer.register] |
  ///
  /// Stdlib gap (DART-SDK): [Map.operator []=] stores a value but never a
  /// build rule — no laziness, no once-only cache, no dispose hook — so
  /// [register] owns the named lazy-singleton rule. Fidelity note
  /// (AXIOM-SISTER): mirrors Axiom's `Provide` first-wins rule without Go
  /// signatures: the factory runs never at registration time, and a second
  /// registration under the same name throws instead of replacing.
  /// A `null`-factory guard is YAGNI-killed here with a reason: sound null
  /// safety makes it unrepresentable, since [create] is a non-nullable
  /// function the compiler already rejects as `null`.
  ///
  /// The factory builds the singleton once per registration: the first
  /// [resolve] runs it and later resolves share the cached value, while a
  /// throwing factory leaves nothing cached so the next [resolve] retries.
  /// The optional
  /// [dispose] hook runs with the built value when [unregister] or [reset]
  /// drops a built registration; never-built registrations dispose
  /// nothing. Dispose errors propagate to the caller.
  ///
  /// Throws an [ArgumentError] when [serviceName] is empty, and a
  /// [StateError] when [serviceName] is already registered: the first
  /// registration wins and stays untouched.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final ServiceContainer services = ServiceContainer();
  /// services.register<String>('greeting', () => 'hello');
  /// // services.resolve<String>('greeting') == 'hello'
  /// ```
  void register<Service extends Object>(
    String serviceName,
    Service Function() create, {
    void Function(Service createdService)? dispose,
  }) {
    if (serviceName.isEmpty) {
      throw ArgumentError.value(
        serviceName,
        'serviceName',
        'Must not be empty.',
      );
    }
    if (_slotsByName.containsKey(serviceName)) {
      throw StateError(
        'praxis di: duplicate service "$serviceName". '
        'First registration wins.',
      );
    }
    final void Function(Object createdService)? wrappedDispose = dispose == null
        ? null
        : (Object createdService) => dispose(createdService as Service);
    _slotsByName[serviceName] = _ServiceSlot(create, wrappedDispose);
  }

  /// Returns the shared singleton for [serviceName], building it once.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | a service name to read, building once on first use | [ServiceContainer.resolve] |
  ///
  /// Stdlib gap (DART-SDK): [Map.operator []] reads stored values but never
  /// builds missing ones — no lazy-once rule, no failing-build retry — so
  /// [resolve] owns the missing-name-builds-once shape. Fidelity note
  /// (AXIOM-SISTER): mirrors Axiom's `Resolve` retry discipline without Go
  /// signatures: a throwing factory propagates with nothing cached, so the
  /// next [resolve] retries instead of serving the failure.
  ///
  /// Resolving under a supertype of the registered type shares the same
  /// singleton; resolving under an unrelated type throws a [StateError]
  /// without evicting the cached value, so resolving under the registered
  /// type afterwards still hits the cache.
  ///
  /// Throws a [StateError] when no service is registered under
  /// [serviceName], and a [StateError] when the cached value is not the
  /// requested type: both are programmer errors, never domain failures.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final ServiceContainer services = ServiceContainer();
  /// services.register<String>('greeting', () => 'hello');
  /// final String greeting = services.resolve<String>('greeting');
  /// // greeting == 'hello'
  /// ```
  Service resolve<Service extends Object>(String serviceName) {
    final _ServiceSlot? foundSlot = _slotsByName[serviceName];
    if (foundSlot == null) {
      throw StateError(
        'praxis di: no service registered under "$serviceName".',
      );
    }
    final Object builtService = foundSlot.buildOnce();
    if (builtService is! Service) {
      throw StateError(
        'praxis di: service "$serviceName" holds '
        '${builtService.runtimeType}, not $Service.',
      );
    }
    return builtService;
  }

  /// Drops the registration under [serviceName] for tests.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | one registration to drop, disposing when built | [ServiceContainer.unregister] |
  ///
  /// Stdlib gap (DART-SDK): [Map.remove] drops storage but never runs a
  /// lifecycle hook, so [unregister] owns the remove-plus-dispose rule for
  /// the built singleton. A `Replace`-style swap is YAGNI-killed here with
  /// a reason: [unregister] plus [register] already covers the test-seed
  /// swap with no halfway state to specify.
  ///
  /// Removes the registration first, then runs its dispose hook with the
  /// built value when the service was built; never-built registrations
  /// dispose nothing. Dispose errors propagate with the registration
  /// already gone. Re-registering [serviceName] afterwards builds fresh.
  ///
  /// Throws a [StateError] when no service is registered under
  /// [serviceName].
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final ServiceContainer services = ServiceContainer();
  /// services.register<String>('greeting', () => 'hello');
  /// // services.resolve<String>('greeting') == 'hello'
  /// services.unregister('greeting');
  /// // services.resolve<String>('greeting') throws
  /// ```
  void unregister(String serviceName) {
    final _ServiceSlot? removedSlot = _slotsByName.remove(serviceName);
    if (removedSlot == null) {
      throw StateError(
        'praxis di: no service registered under "$serviceName".',
      );
    }
    removedSlot.disposeIfBuilt();
  }

  /// Tears every registration down in reverse registration order.
  ///
  /// Which-table row:
  ///
  /// | If you hold ... | Reach for |
  /// | --- | --- |
  /// | every registration to drop for test isolation | [ServiceContainer.reset] |
  ///
  /// Stdlib gap (DART-SDK): [Map.clear] drops storage with no teardown
  /// order, so [reset] owns the reverse-order dispose sweep over built
  /// singletons. Newest disposes first so later registrations — which may
  /// depend on earlier ones — release before their dependencies.
  /// Never-built registrations dispose nothing. Registration order rides
  /// the table's insertion-ordered keys, so no parallel order list exists.
  ///
  /// Every built singleton is disposed even when a hook throws: the sweep
  /// continues through the remaining registrations while the first dispose
  /// error still propagates, and removals land in a `finally` sweep so the
  /// next test always starts clean.
  ///
  /// Available since Praxis `0.1.0`. Requires Dart `^3.13.0`.
  ///
  /// ```dart
  /// final ServiceContainer services = ServiceContainer();
  /// services.register<String>('greeting', () => 'hello');
  /// services.register<int>('answer', () => 42);
  /// // services.resolve<String>('greeting') == 'hello'
  /// services.reset();
  /// // services.resolve<String>('greeting') throws
  /// // services.resolve<int>('answer') throws
  /// ```
  void reset() {
    Object? pendingFailure;
    StackTrace? pendingStackTrace;
    try {
      final List<String> teardownOrder = _slotsByName.keys.toList();
      for (final String serviceName in teardownOrder.reversed) {
        try {
          _slotsByName[serviceName]?.disposeIfBuilt();
        } catch (disposalFailure, disposalStackTrace) {
          pendingFailure ??= disposalFailure;
          pendingStackTrace ??= disposalStackTrace;
        }
      }
    } finally {
      _slotsByName.clear();
    }
    if (pendingFailure != null) {
      Error.throwWithStackTrace(
        pendingFailure,
        pendingStackTrace ?? StackTrace.empty,
      );
    }
  }
}

/// One lazy singleton slot: the type-erased factory plus its cached build.
///
/// The slot erases the service type internally as [Object] so one table can
/// hold many service types; the erasure never leaks because
/// [ServiceContainer.resolve] checks the built value against the requested
/// type before returning it.
final class _ServiceSlot {
  /// Creates a slot that builds through [create] with [dispose] on teardown.
  _ServiceSlot(this._create, this._dispose);

  final Object Function() _create;
  final void Function(Object createdService)? _dispose;
  Object? _cachedService;
  bool _hasCachedService = false;

  /// Builds the value once, returning the cached value afterwards.
  ///
  /// A throwing factory propagates with nothing cached, so the next call
  /// retries instead of serving the failure.
  Object buildOnce() {
    if (_hasCachedService) {
      return _cachedService as Object;
    }
    final Object builtService = _create();
    _cachedService = builtService;
    _hasCachedService = true;
    return builtService;
  }

  /// Runs the dispose hook with the built value when one exists.
  ///
  /// Clears the cached flag before disposing so a throwing hook never
  /// leaves a half-torn slot behind. The cached value is never null here:
  /// [buildOnce] stores only the non-nullable [_create] result.
  void disposeIfBuilt() {
    if (!_hasCachedService) {
      return;
    }
    final Object builtService = _cachedService as Object;
    _hasCachedService = false;
    _cachedService = null;
    _dispose?.call(builtService);
  }
}
