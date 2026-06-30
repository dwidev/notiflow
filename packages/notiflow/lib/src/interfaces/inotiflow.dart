import '../internal/core/notiflow_impl.dart';
import '../models/notification_event.dart';
import '../models/notiflow_notification.dart';
import 'notiflow_handler.dart';
import 'notiflow_middleware.dart';
import 'notiflow_navigator.dart';
import 'notiflow_parser.dart';

/// Public interface NotiFlow — satu-satunya yang developer lihat dan gunakan.
///
/// Implementasi internal sepenuhnya tersembunyi.
/// Akses via factory: `NotiFlow.instance` atau `NotiFlow.create()`.
///
/// ```dart
/// final Notiflow notiflow = NotiFlow.instance
///   ..setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
///   ..addMiddleware(LoggingMiddleware())
///   ..register<ChatNotification>(
///       matcher: (e) => e.payload['type'] == 'chat',
///       parser: ChatNotificationParser(),
///       handler: ChatNotificationHandler(),
///     );
/// ```
abstract interface class Notiflow {
  Notiflow._();

  static final Notiflow _instance = NotiflowInstance();

  /// Singleton instance — satu router untuk seluruh app.
  static Notiflow get instance => _instance;

  /// Buat instance baru — berguna untuk testing atau isolated router.
  static Notiflow create() => NotiflowInstance();

  /// Set navigator adapter.
  Notiflow setNavigator(NotiflowNavigator navigator);

  /// Tambah middleware ke pipeline.
  Notiflow addMiddleware(NotiflowMiddleware middleware);

  /// Hapus middleware dari pipeline.
  Notiflow removeMiddleware(NotiflowMiddleware middleware);

  /// Daftarkan tipe notifikasi beserta parser dan handler-nya.
  Notiflow register<T extends NotiflowNotification>({
    required bool Function(NotificationEvent event) matcher,
    required NotiflowParser<T> parser,
    required NotiflowHandler<T> handler,
  });

  /// Set handler fallback untuk tipe yang tidak dikenali.
  Notiflow setFallbackHandler(NotiflowHandler<NotiflowNotification> handler);

  /// Dispatch event ke pipeline — entry point utama.
  Future<void> dispatch(NotificationEvent event);

  /// Resolve event ke typed notification tanpa dispatch (untuk testing).
  NotiflowNotification? resolve(NotificationEvent event);

  /// Jumlah handler yang terdaftar.
  int get registeredCount;

  /// Reset semua state (untuk testing).
  void reset();
}
