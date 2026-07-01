part of 'builtin_middleware.dart';

/// Middleware untuk logging semua event yang masuk ke pipeline.
///
/// Aktif hanya di debug mode secara default.
///
/// ```dart
/// notiflow.addMiddleware(LoggingMiddleware());
/// // atau dengan tag custom:
/// notiflow.addMiddleware(LoggingMiddleware(tag: 'MyApp'));
/// ```
class LoggingMiddleware extends NotiflowMiddleware {
  final String tag;
  final bool enableInRelease;
  final EventCallback? logBuilder;

  LoggingMiddleware({
    this.tag = 'NOTIFLOW',
    this.enableInRelease = false,
    this.logBuilder,
  });

  @override
  Future<NotiflowMiddlewareResult> handle(
    NotificationEvent event,
    NotiflowNext next,
  ) async {
    if (!kDebugMode && !enableInRelease) return next(event);

    final sw = Stopwatch();
    sw.start();

    if (logBuilder == null) {
      log(
        '-------------RECEIVED NOTIFICATION---------------- \n'
        '[$tag]         ▶ ${event.source.name.toUpperCase()} \n'
        'Notication ID  : ${event.id} \n'
        'Source         : ${event.source} \n'
        'State          : ${event.state.name} \n'
        'Recive At      : ${event.receivedAt} \n'
        'Payload        : ${event.payload} \n'
        'Metadata       : ${event.metadata.isNotEmpty ? event.metadata : '-'} \n'
        '--------------------------------------------------',
      );
    } else {
      await logBuilder?.call(event);
    }

    final result = await next(event);
    sw.stop();

    final ms = sw.elapsed.inMilliseconds;
    if (result is MiddlewareStop) {
      log('[$tag] ⛔ Stopped — reason: ${result.reason} (${ms}ms)');
    } else {
      log('[$tag] ✅ Done with (${ms}ms)');
    }

    return result;
  }
}
