import 'package:flutter_test/flutter_test.dart';
import 'package:notiflow/src/internal/core/notiflow_middleware_pipeline.dart';
import 'package:notiflow/src/internal/types.dart';
import 'package:notiflow/notiflow.dart';

void main() {
  group('NotiflowMiddlewarePipelines', () {
    late NotiflowMiddlewarePipeline pipeline;

    setUp(() {
      pipeline = NotiflowMiddlewarePipeline(middlewares: []);
    });

    test('should call terminal when no middleware', () async {
      var terminalCalled = false;

      final result = await pipeline.execute(
        event: _FakeEvent.create(),
        terminal: (event) async {
          terminalCalled = true;
          return MiddlewareContinue(event);
        },
      );

      expect(terminalCalled, true);
      expect(result, isA<MiddlewareContinue>());
    });

    test('should execute middleware in order', () async {
      final calls = <String>[];

      pipeline.addMiddleware(
        _TestMiddleware((event, next) async {
          calls.add('A-before');
          final result = await next(event);
          calls.add('A-after');
          return result;
        }),
      );

      pipeline.addMiddleware(LoggingMiddleware());

      pipeline.addMiddleware(
        _TestMiddleware((event, next) async {
          calls.add('B-before');
          final result = await next(event);
          calls.add('B-after');
          return result;
        }),
      );

      await pipeline.execute(
        event: _FakeEvent.create(),
        terminal: (event) async {
          calls.add('terminal');
          return MiddlewareContinue(event);
        },
      );

      expect(calls, ['A-before', 'B-before', 'terminal', 'B-after', 'A-after']);
    });

    test('middleware can stop the chain', () async {
      var terminalCalled = false;

      pipeline.addMiddleware(
        _TestMiddleware((event, next) async {
          return MiddlewareStop(reason: 'stoping chain middlewaire');
        }),
      );

      await pipeline.execute(
        event: _FakeEvent.create(),
        terminal: (event) async {
          terminalCalled = true;
          return MiddlewareContinue(event);
        },
      );

      expect(terminalCalled, false);
    });

    test('removeMiddleware should remove middleware', () async {
      final calls = <String>[];

      final middleware = _TestMiddleware((event, next) async {
        calls.add('middleware');
        return next(event);
      });

      pipeline.addMiddleware(middleware);
      pipeline.removeMiddleware(middleware);

      await pipeline.execute(
        event: _FakeEvent.create(),
        terminal: (event) async {
          calls.add('terminal');
          return MiddlewareContinue(event);
        },
      );

      expect(calls, ['terminal']);
    });

    test('clear should remove all middleware', () async {
      final calls = <String>[];

      pipeline.addMiddleware(
        _TestMiddleware((event, next) async {
          calls.add('middleware');
          return next(event);
        }),
      );

      pipeline.clear();

      await pipeline.execute(
        event: _FakeEvent.create(),
        terminal: (event) async {
          calls.add('terminal');
          return MiddlewareContinue(event);
        },
      );

      expect(calls, ['terminal']);
    });

    test('should rebuild after middleware changes', () async {
      final calls = <String>[];

      await pipeline.execute(
        event: _FakeEvent.create(),
        terminal: (event) async {
          calls.add('terminal');
          return MiddlewareContinue(event);
        },
      );

      pipeline.addMiddleware(
        _TestMiddleware((event, next) async {
          calls.add('middleware');
          return next(event);
        }),
      );

      await pipeline.execute(
        event: _FakeEvent.create(),
        terminal: (event) async {
          calls.add('terminal');
          return MiddlewareContinue(event);
        },
      );

      expect(calls, ['terminal', 'middleware', 'terminal']);
    });
  });
}

class _TestMiddleware extends NotiflowMiddleware {
  _TestMiddleware(this.handler);

  final Future<NotiflowMiddlewareResult> Function(
    NotificationEvent event,
    NotiflowNext next,
  )
  handler;

  @override
  Future<NotiflowMiddlewareResult> handle(
    NotificationEvent event,
    NotiflowNext next,
  ) {
    return handler(event, next);
  }
}

class _FakeEvent extends NotificationEvent {
  _FakeEvent({
    required super.source,
    required super.state,
    required super.payload,
  });

  factory _FakeEvent.create() => _FakeEvent(
    source: NotificationSource.firebase,
    state: NotificationState.background,
    payload: {"notif_fake": "fake", "content": "fake"},
  );
}
