import 'package:praxis/src/di.dart';
import 'package:test/test.dart';

/// A small mutable holder so tests can tell singletons apart by identity.
final class _CounterService {
  _CounterService(this.value);

  int value;
}

/// A second service type so coexistence tests stay honest.
final class _AuditService {
  _AuditService(this.trail);

  final String trail;
}

/// A supertype view over [_CarService] for the shared-singleton pin.
abstract interface class _VehicleService {
  String get model;
}

/// One implementation so the supertype pin has something to hold.
final class _CarService implements _VehicleService {
  _CarService(this.model);

  @override
  final String model;
}

void main() {
  group('ServiceContainer.register', () {
    test('registers a factory without building it', () {
      final ServiceContainer services = ServiceContainer();
      int buildCount = 0;
      services.register<_CounterService>('counter', () {
        buildCount += 1;
        return _CounterService(1);
      });
      expect(buildCount, equals(0));
      final _CounterService resolvedService = services.resolve<_CounterService>(
        'counter',
      );
      expect(resolvedService.value, equals(1));
      expect(buildCount, equals(1));
    });

    test('empty service name throws ArgumentError', () {
      final ServiceContainer services = ServiceContainer();
      expect(
        () => services.register<_CounterService>('', () => _CounterService(1)),
        throwsArgumentError,
      );
    });

    test('duplicate registration throws StateError and keeps the first', () {
      final ServiceContainer services = ServiceContainer();
      services.register<_CounterService>('counter', () => _CounterService(1));
      expect(
        () => services.register<_CounterService>(
          'counter',
          () => _CounterService(2),
        ),
        throwsStateError,
      );
      expect(services.resolve<_CounterService>('counter').value, equals(1));
    });
  });

  group('ServiceContainer.resolve', () {
    test('missing service name throws StateError', () {
      final ServiceContainer services = ServiceContainer();
      expect(
        () => services.resolve<_CounterService>('missing'),
        throwsStateError,
      );
    });

    test('second resolve returns the identical singleton', () {
      final ServiceContainer services = ServiceContainer();
      int buildCount = 0;
      services.register<_CounterService>('counter', () {
        buildCount += 1;
        return _CounterService(7);
      });
      final _CounterService firstService = services.resolve<_CounterService>(
        'counter',
      );
      final _CounterService secondService = services.resolve<_CounterService>(
        'counter',
      );
      expect(identical(firstService, secondService), isTrue);
      expect(buildCount, equals(1));
    });

    test('failing factory retries until success', () {
      final ServiceContainer services = ServiceContainer();
      int buildCount = 0;
      services.register<_CounterService>('flaky', () {
        buildCount += 1;
        if (buildCount <= 2) {
          throw StateError('factory offline');
        }
        return _CounterService(99);
      });
      expect(
        () => services.resolve<_CounterService>('flaky'),
        throwsStateError,
      );
      expect(
        () => services.resolve<_CounterService>('flaky'),
        throwsStateError,
      );
      expect(services.resolve<_CounterService>('flaky').value, equals(99));
      expect(services.resolve<_CounterService>('flaky').value, equals(99));
      expect(buildCount, equals(3));
    });

    test(
      'unrelated type view throws StateError without evicting the cache',
      () {
        final ServiceContainer services = ServiceContainer();
        services.register<_CounterService>('counter', () => _CounterService(7));
        expect(
          () => services.resolve<_AuditService>('counter'),
          throwsStateError,
        );
        expect(services.resolve<_CounterService>('counter').value, equals(7));
      },
    );

    test('supertype view shares the same singleton', () {
      final ServiceContainer services = ServiceContainer();
      services.register<_CarService>('car', () => _CarService('pari'));
      final _VehicleService viewedService = services.resolve<_VehicleService>(
        'car',
      );
      expect(viewedService.model, equals('pari'));
      expect(
        identical(viewedService, services.resolve<_CarService>('car')),
        isTrue,
      );
    });

    test('two service names coexist', () {
      final ServiceContainer services = ServiceContainer();
      services.register<_CounterService>('ledger', () => _CounterService(11));
      services.register<_AuditService>('audit', () => _AuditService('kept'));
      expect(services.resolve<_CounterService>('ledger').value, equals(11));
      expect(services.resolve<_AuditService>('audit').trail, equals('kept'));
    });
  });

  group('ServiceContainer.unregister', () {
    test('removes the registration so resolve throws', () {
      final ServiceContainer services = ServiceContainer();
      services.register<_CounterService>('counter', () => _CounterService(1));
      services.unregister('counter');
      expect(
        () => services.resolve<_CounterService>('counter'),
        throwsStateError,
      );
    });

    test('disposes the built singleton once', () {
      final ServiceContainer services = ServiceContainer();
      int disposeCount = 0;
      _CounterService? disposedService;
      services.register<_CounterService>(
        'counter',
        () => _CounterService(3),
        dispose: (_CounterService createdService) {
          disposeCount += 1;
          disposedService = createdService;
        },
      );
      final _CounterService builtService = services.resolve<_CounterService>(
        'counter',
      );
      services.unregister('counter');
      expect(disposeCount, equals(1));
      expect(identical(disposedService, builtService), isTrue);
    });

    test('never-built registration disposes nothing', () {
      final ServiceContainer services = ServiceContainer();
      int disposeCount = 0;
      services.register<_CounterService>(
        'counter',
        () => _CounterService(3),
        dispose: (_CounterService createdService) {
          disposeCount += 1;
        },
      );
      services.unregister('counter');
      expect(disposeCount, equals(0));
    });

    test('missing service name throws StateError', () {
      final ServiceContainer services = ServiceContainer();
      expect(() => services.unregister('missing'), throwsStateError);
    });

    test('re-register after unregister builds fresh', () {
      final ServiceContainer services = ServiceContainer();
      services.register<_CounterService>('counter', () => _CounterService(1));
      expect(services.resolve<_CounterService>('counter').value, equals(1));
      services.unregister('counter');
      services.register<_CounterService>('counter', () => _CounterService(2));
      expect(services.resolve<_CounterService>('counter').value, equals(2));
    });
  });

  group('ServiceContainer.reset', () {
    test('disposes built singletons in reverse registration order', () {
      final ServiceContainer services = ServiceContainer();
      final List<String> disposedNames = <String>[];
      services.register<_CounterService>(
        'first',
        () => _CounterService(1),
        dispose: (_CounterService createdService) {
          disposedNames.add('first');
        },
      );
      services.register<_CounterService>(
        'second',
        () => _CounterService(2),
        dispose: (_CounterService createdService) {
          disposedNames.add('second');
        },
      );
      services.register<_CounterService>(
        'idle',
        () => _CounterService(3),
        dispose: (_CounterService createdService) {
          disposedNames.add('idle');
        },
      );
      services.resolve<_CounterService>('first');
      services.resolve<_CounterService>('second');
      services.reset();
      expect(disposedNames, equals(<String>['second', 'first']));
      expect(
        () => services.resolve<_CounterService>('first'),
        throwsStateError,
      );
    });

    test('leaves the container empty for re-registration', () {
      final ServiceContainer services = ServiceContainer();
      services.register<_CounterService>('counter', () => _CounterService(1));
      expect(services.resolve<_CounterService>('counter').value, equals(1));
      services.reset();
      expect(
        () => services.resolve<_CounterService>('counter'),
        throwsStateError,
      );
      services.register<_CounterService>('counter', () => _CounterService(2));
      expect(services.resolve<_CounterService>('counter').value, equals(2));
    });

    test('throwing dispose still empties the container', () {
      final ServiceContainer services = ServiceContainer();
      services.register<_CounterService>(
        'counter',
        () => _CounterService(1),
        dispose: (_CounterService createdService) {
          throw StateError('dispose offline');
        },
      );
      services.resolve<_CounterService>('counter');
      expect(services.reset, throwsStateError);
      expect(
        () => services.resolve<_CounterService>('counter'),
        throwsStateError,
      );
    });
  });

  group('documented examples stay runnable', () {
    test('ServiceContainer example', () {
      final ServiceContainer services = ServiceContainer();
      services.register<String>('greeting', () => 'hello');
      expect(services.resolve<String>('greeting'), equals('hello'));
    });

    test('ServiceContainer.register example', () {
      final ServiceContainer services = ServiceContainer();
      services.register<String>('greeting', () => 'hello');
      expect(services.resolve<String>('greeting'), equals('hello'));
    });

    test('ServiceContainer.resolve example', () {
      final ServiceContainer services = ServiceContainer();
      services.register<String>('greeting', () => 'hello');
      final String greeting = services.resolve<String>('greeting');
      expect(greeting, equals('hello'));
    });

    test('ServiceContainer.unregister example', () {
      final ServiceContainer services = ServiceContainer();
      services.register<String>('greeting', () => 'hello');
      expect(services.resolve<String>('greeting'), equals('hello'));
      services.unregister('greeting');
      expect(() => services.resolve<String>('greeting'), throwsStateError);
    });

    test('ServiceContainer.reset example', () {
      final ServiceContainer services = ServiceContainer();
      services.register<String>('greeting', () => 'hello');
      services.register<int>('answer', () => 42);
      expect(services.resolve<String>('greeting'), equals('hello'));
      services.reset();
      expect(() => services.resolve<String>('greeting'), throwsStateError);
      expect(() => services.resolve<int>('answer'), throwsStateError);
    });
  });
}
