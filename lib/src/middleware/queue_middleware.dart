part of 'builtin_middleware.dart';

/// Middleware untuk mengantrekan notifikasi saat app belum siap.
///
/// Event diqueue sampai [ready] dipanggil. Berguna untuk notifikasi
/// yang datang sebelum app selesai inisialisasi (auth, database, dll).
///
/// ```dart
/// final queueMiddleware = QueueMiddleware();
///
/// notiflow.addMiddleware(queueMiddleware);
///
/// // Saat app sudah siap (setelah auth check, db init, dll):
/// await queueMiddleware.ready();
/// ```
class QueueMiddleware extends NotiflowMiddleware {
  final List<_QueuedEvent> _queue = [];
  bool _isReady = false;

  @override
  Future<NotiflowMiddlewareResult> handle(
    NotificationEvent event,
    NotiflowNext next,
  ) async {
    if (_isReady) return next(event);

    // Queue event dan tunggu sampai ready() dipanggil
    final completer = _QueuedEvent(event: event, next: next);
    _queue.add(completer);
    return completer.future;
  }

  /// Tandai app sebagai sudah siap dan proses semua event yang terqueue.
  Future<void> ready() async {
    _isReady = true;

    final queued = List<_QueuedEvent>.from(_queue);
    _queue.clear();

    for (final item in queued) {
      final result = await item.next(item.event);
      item.complete(result);
    }
  }

  /// Jumlah event yang sedang diqueue.
  int get queueLength => _queue.length;
}

class _QueuedEvent {
  final NotificationEvent event;
  final NotiflowNext next;
  final _completer = Completer<NotiflowMiddlewareResult>();

  _QueuedEvent({required this.event, required this.next});

  Future<NotiflowMiddlewareResult> get future => _completer.future;

  void complete(NotiflowMiddlewareResult result) {
    _completer.complete(result);
  }
}
