import 'package:flutter/foundation.dart';

import '../../../notiflow.dart';
import '../../interfaces/notiflow_handler.dart';
import '../exceptions/navigator_exception.dart';
import '../registry/notiflow_registry.dart';
import '../routes/router_handler.dart';
import '../routes/router_parser.dart';
import 'notiflow_dispatch_engine.dart';

// Internal typedef — tidak di-export
typedef NotiflowInstance = _NotiflowImpl;

/// Implementasi internal [Notiflow].
///
/// Tidak di-export ke public API sama sekali.
/// Hanya bisa diakses via factory `Notiflow.instance` atau `Notiflow.create()`.
final class _NotiflowImpl implements Notiflow {
  _NotiflowImpl();

  final NotiflowRegistry _registry = NotiflowRegistry();
  final NotiflowDispatchEngine _engine = NotiflowDispatchEngine();
  NotiflowNavigator? _navigator;

  // ─── Builder API ──────────────────────────────────────────────────────

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
    required NotiflowRoute route,
  }) {
    final parser = RouterParser<T>(parser: route.parse);
    final handler = RouterHandler<T>(lifecycle: route.lifecycle);

    _registry.register<T>(
      matcher: route.matcher,
      parser: parser,
      handler: handler,
    );
    return this;
  }

  @override
  Notiflow setFallbackHandler(NotiflowHandler<NotiflowNotification> handler) {
    _registry.setFallbackHandler(handler);
    return this;
  }

  // ─── Dispatch ─────────────────────────────────────────────────────────

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
            '[NotiFlow] ⚠ No handler for: $event '
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

  // ─── Inspector ────────────────────────────────────────────────────────

  @override
  void showInspector() {
    if (!kDebugMode) return;

    // TODO: Implement full Inspector overlay UI (v0.2.0)
    debugPrint('[NotiFlow] 🔔 Inspector — coming in v0.2.0');
  }

  // ─── Query & Testing ──────────────────────────────────────────────────

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
