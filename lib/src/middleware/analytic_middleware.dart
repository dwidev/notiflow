part of 'builtin_middleware.dart';

/// Middleware untuk tracking semua notifikasi ke analytics provider.
///
/// ```dart
/// notiflow.addMiddleware(
///   AnalyticsMiddleware(
///     onTrack: (event) async {
///       await FirebaseAnalytics.instance.logEvent(
///         name: 'notification_received',
///         parameters: {
///           'type': event.payload['type'] ?? 'unknown',
///           'source': event.source.name,
///           'state': event.state.name,
///         },
///       );
///     },
///   ),
/// );
/// ```
class AnalyticsMiddleware extends NotiflowMiddleware {
  final EventCallback onTrack;

  AnalyticsMiddleware({required this.onTrack});

  @override
  Future<NotiflowMiddlewareResult> handle(
    NotificationEvent event,
    NotiflowNext next,
  ) async {
    try {
      await onTrack(event);
    } catch (e, s) {
      log('[NotiFlow:Analytics] ⛔ Error tracking: $e , Stacktrace :$s');
    }
    return next(event);
  }
}
