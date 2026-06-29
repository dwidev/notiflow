part of 'builtin_middleware.dart';

/// Middleware untuk mencegah notifikasi duplikat diproses lebih dari sekali.
///
/// Berguna saat provider mengirim notifikasi yang sama lebih dari sekali
/// (misalnya saat app resume dari background).
///
/// ```dart
/// notiflow.addMiddleware(
///   DeduplicationMiddleware(
///     rangeDuration: Duration(seconds: 5),
///     keyExtractor: (event) => event.payload['notification_id'] as String?,
///   ),
/// );
/// ```
class DeduplicationMiddleware extends NotiflowMiddleware {
  final Duration rangeDuration;
  final String? Function(NotificationEvent event)? keyExtractor;
  final Map<String, DateTime> _seen = {};

  DeduplicationMiddleware({
    this.rangeDuration = const Duration(seconds: 3),
    this.keyExtractor,
  });

  @override
  Future<NotiflowMiddlewareResult> handle(
    NotificationEvent event,
    NotiflowNext next,
  ) async {
    _cleanup();

    final key = keyExtractor?.call(event) ?? event.id;
    final lastSeen = _seen[key];

    if (lastSeen != null &&
        DateTime.now().difference(lastSeen) < rangeDuration) {
      return const MiddlewareStop(reason: 'duplicate_notification');
    }

    _seen[key] = DateTime.now();
    return next(event);
  }

  void _cleanup() {
    final now = DateTime.now();
    _seen.removeWhere((_, time) => now.difference(time) > rangeDuration);
  }
}
