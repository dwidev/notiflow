import 'package:notiflow/src/internal/types.dart';

import '../models/notification_event.dart';

/// Hasil eksekusi sebuah middleware.
sealed class NotiflowMiddlewareResult {
  const NotiflowMiddlewareResult();
}

/// Pipeline dilanjutkan ke middleware / handler berikutnya.
final class MiddlewareContinue extends NotiflowMiddlewareResult {
  final NotificationEvent event;
  const MiddlewareContinue(this.event);
}

/// Pipeline dihentikan — handler tidak akan dipanggil.
final class MiddlewareStop extends NotiflowMiddlewareResult {
  /// for middleware name
  final String tag;
  final String reason;

  const MiddlewareStop({required this.tag, required this.reason});
}

final class MiddlewareFinish extends NotiflowMiddlewareResult {
  const MiddlewareFinish([String reason = 'Finish the pipeline']);
}

/// Interface untuk middleware dalam NotiFlow pipeline.
///
/// Middleware dieksekusi secara berurutan sesuai urutan [addMiddleware].
/// Setiap middleware bisa:
/// - Memodifikasi event sebelum diteruskan
/// - Menghentikan pipeline (return [MiddlewareStop])
/// - Melakukan side effect (logging, analytics, dll)
///
/// **Pola dasar:**
/// ```dart
/// class LoggingMiddleware extends NotiflowMiddleware {
///   @override
///   Future<NotiflowMiddlewareResult> handle(
///     NotificationEvent event,
///     NotiflowNext next,
///   ) async {
///     debugPrint('[NotiFlow] ${event.source.name} → ${event.payload}');
///     return next(event); // lanjutkan pipeline
///   }
/// }
/// ```
///
/// **Pola stop pipeline:**
/// ```dart
/// class AuthMiddleware extends NotiflowMiddleware {
///   @override
///   Future<NotiflowMiddlewareResult> handle(
///     NotificationEvent event,
///     NotiflowNext next,
///   ) async {
///     final isLoggedIn = await AuthService.instance.isLoggedIn();
///     if (!isLoggedIn) {
///       return const MiddlewareStop(reason: 'user_not_authenticated');
///     }
///     return next(event);
///   }
/// }
/// ```
///
/// **Pola modifikasi event:**
/// ```dart
/// class EnrichmentMiddleware extends NotiflowMiddleware {
///   @override
///   Future<NotiflowMiddlewareResult> handle(
///     NotificationEvent event,
///     NotiflowNext next,
///   ) async {
///     // Tambahkan data ke payload sebelum diteruskan
///     final enriched = event.copyWith(
///       metadata: {
///         ...event.metadata,
///         'enriched_at': DateTime.now().toIso8601String(),
///       },
///     );
///     return next(enriched);
///   }
/// }
/// ```
abstract class NotiflowMiddleware {
  /// Handle event dan putuskan apakah pipeline dilanjutkan atau dihentikan.
  ///
  /// Selalu kembalikan `next(event)` jika ingin pipeline dilanjutkan.
  Future<NotiflowMiddlewareResult> handle(
    NotificationEvent event,
    NotiflowNext next,
  );
}
