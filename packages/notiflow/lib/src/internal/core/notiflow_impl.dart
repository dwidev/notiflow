import 'package:flutter/foundation.dart';
import 'package:notiflow/notiflow.dart';
import '../exceptions/navigator_exception.dart';
import '../../interfaces/inotiflow.dart';
import 'notiflow_dispatch_engine.dart';
import '../registry/notiflow_registry.dart';

// Internal typedef — tidak di-export
typedef NotiflowInstance = _NotiflowImpl;

/// Implementasi internal [NotiFlow].
///
/// Tidak di-export ke public API sama sekali.
/// Hanya bisa diakses via factory `NotiFlow.instance` atau `NotiFlow.create()`.
final class _NotiflowImpl implements Notiflow {
  _NotiflowImpl();

  final NotiflowRegistry _registry = NotiflowRegistry();
  final NotiflowDispatchEngine _engine = NotiflowDispatchEngine();
  NotiflowNavigator? _navigator;

  @override
  Notiflow setNavigator(NotiflowNavigator navigator) {
    _navigator = navigator;
    return this;
  }

  @override
  Notiflow addMiddleware(NotiflowMiddleware middleware) {
    _engine.addMiddleware(middleware);
    return this;
  }

  @override
  Notiflow removeMiddleware(NotiflowMiddleware middleware) {
    _engine.removeMiddleware(middleware);
    return this;
  }

  @override
  Notiflow register<T extends NotiflowNotification>({
    required bool Function(NotificationEvent event) matcher,
    required NotiflowParser<T> parser,
    required NotiflowHandler<T> handler,
  }) {
    _registry.register<T>(matcher: matcher, parser: parser, handler: handler);
    return this;
  }

  @override
  Notiflow setFallbackHandler(NotiflowHandler<NotiflowNotification> handler) {
    _registry.setFallbackHandler(handler);
    return this;
  }

  @override
  Future<void> dispatch(NotificationEvent event) async {
    if (_navigator == null) {
      throw const NotiflowNavigatorNotSetException();
    }

    final navigator = _navigator!;

    final result = await _engine.run(
      event: event,
      terminal: (processed) async {
        final handled = await _registry.dispatch(processed, navigator);
        if (!handled) {
          debugPrint(
            '[NotiFlow] ⚠ No handler for: ${event.payload['type']} '
            '(source: ${event.source.name})',
          );
        }
        return MiddlewareContinue(processed);
      },
    );

    if (result is MiddlewareStop) {
      debugPrint('[NotiFlow] ⛔ Stopped — reason: ${result.reason}');
    }
  }

  @override
  NotiflowNotification? resolve(NotificationEvent event) =>
      _registry.resolve(event);

  @override
  int get registeredCount => _registry.entryCount;

  @override
  void reset() {
    _registry.clear();
    _engine.clear();
    _navigator = null;
  }
}
