import 'package:notiflow/src/internal/types.dart';
import 'package:notiflow/notiflow.dart';

typedef NotiflowDispatchEngine = _NotiflowDispatchEngine;

/// Internal dispatch engine — menjalankan middleware pipeline.
///
/// Strategi performa:
/// - **Pre-built chain**: chain di-build sekali saat middleware berubah,
///   bukan setiap kali dispatch dipanggil
/// - **Dirty flag**: rebuild chain hanya saat ada perubahan middleware
/// - **No closure allocation per dispatch**: chain sudah di-compile ke
///   linked list of _ChainNode, bukan closure baru setiap call
final class _NotiflowDispatchEngine {
  final List<NotiflowMiddleware> _middlewares = [];

  // Chain sudah di-build — siap dipakai
  _ChainNode? _headChain;
  bool _isDirty = true;

  void addMiddleware(NotiflowMiddleware middleware) {
    _middlewares.add(middleware);
    _invalidateChain();
  }

  void removeMiddleware(NotiflowMiddleware middleware) {
    if (_middlewares.remove(middleware)) {
      _isDirty = true;
      _invalidateChain();
    }
  }

  /// Running middleware pipeline for [event].
  ///
  /// [terminal] is called after all middleware have been executed.
  /// if [_headChain] is null run terminal only
  Future<NotiflowMiddlewareResult> run({
    required NotificationEvent event,
    required NotiflowNext terminal,
  }) async {
    if (_isDirty) _rebuildChain(terminal);

    final chain = _headChain;
    if (chain == null) return terminal(event);

    return chain.invoke(event);
  }

  void _rebuildChain(NotiflowNext terminal) {
    _invalidateChain();

    if (_middlewares.isEmpty) {
      _headChain = null;
      _isDirty = false;
      return;
    }

    _ChainNode? chainNode;
    NotiflowNext currentNext = terminal;

    for (var i = _middlewares.length - 1; i >= 0; i--) {
      final middleware = _middlewares[i];
      final nextInChain = currentNext;

      final node = _ChainNode()
        .._middleware = middleware
        .._next = nextInChain;

      currentNext = node.invoke;
      chainNode = node;
    }

    _headChain = chainNode;
    _isDirty = false;
  }

  void _invalidateChain() {
    _isDirty = true;
    _headChain = null;
  }

  void clear() {
    _invalidateChain();
    _middlewares.clear();
  }
}

final class _ChainNode {
  NotiflowMiddleware? _middleware;
  NotiflowNext? _next;

  Future<NotiflowMiddlewareResult> invoke(NotificationEvent event) {
    return _middleware!.handle(event, _next!);
  }
}
