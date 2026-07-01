import '../internal/core/notiflow_impl.dart';
import '../internal/routes/notiflow_route.dart';
import '../models/notification_event.dart';
import '../models/notiflow_notification.dart';
import 'notiflow_handler.dart';
import 'notiflow_middleware.dart';
import 'notiflow_navigator.dart';

/// Public interface NotiFlow — satu-satunya yang developer lihat dan gunakan.
///
/// Implementasi internal sepenuhnya tersembunyi.
/// Akses via factory: `Notiflow.instance` atau `Notiflow.create()`.
///
/// ## Headless Mode — Manual, Transparan
///
/// ```dart
/// Notiflow.instance
///   .setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
///   .addMiddleware(LoggingMiddleware())
///   .register<ChatNotification>(
///     matcher: (e) => e.payload['type'] == 'chat',
///     parser: ChatNotificationParser(),
///     handler: ChatNotificationHandler(),
///   );
///
/// // Manual dispatch — kamu kontrol penuh
/// FirebaseMessaging.onMessage.listen((msg) {
///   Notiflow.instance.dispatch(NotificationEvent(
///     source: NotificationSource.firebase,
///     state: NotificationState.foreground,
///     payload: msg.data,
///   ));
/// });
/// ```
abstract interface class Notiflow {
  Notiflow._();

  static final Notiflow _instance = NotiflowInstance();

  /// Singleton instance — satu router untuk seluruh app.
  static Notiflow get instance => _instance;

  /// Buat instance baru — berguna untuk testing atau isolated router.
  static Notiflow create() => NotiflowInstance();

  // ─── Builder API (fluent, chainable) ──────────────────────────────────

  /// Set navigator adapter.
  Notiflow setNavigator(NotiflowNavigator navigator);

  /// Tambah middleware ke pipeline.
  Notiflow addMiddleware(NotiflowMiddleware middleware);

  /// Hapus middleware dari pipeline.
  Notiflow removeMiddleware(NotiflowMiddleware middleware);

  /// Daftarkan tipe notifikasi beserta parser dan handler-nya.
  Notiflow register<T extends NotiflowNotification>({
    required NotiflowRoute<T> route,
  });

  /// Set handler fallback untuk tipe yang tidak dikenali.
  Notiflow setFallbackHandler(NotiflowHandler<NotiflowNotification> handler);

  // ─── Dispatch ─────────────────────────────────────────────────────────

  /// Dispatch event ke pipeline — entry point utama.
  ///
  /// Semua provider (Firebase, OneSignal, Local, Custom) dikonversi ke
  /// [NotificationEvent] lalu dipanggil lewat method ini.
  Future<void> dispatch(NotificationEvent event);

  // ─── Inspector ────────────────────────────────────────────────────────

  /// Tampilkan Inspector overlay — debug UI real-time.
  ///
  /// Menampilkan lifecycle setiap notifikasi: received → parsed →
  /// middleware → handler → navigation. Hanya aktif di debug mode.
  ///
  /// ```dart
  /// // Panggil dari mana saja
  /// Notiflow.instance.showInspector();
  ///
  /// // Atau pasang ke gesture
  /// GestureDetector(
  ///   onLongPress: () => Notiflow.instance.showInspector(),
  ///   child: ...,
  /// )
  /// ```
  void showInspector();

  // ─── Query & Testing ──────────────────────────────────────────────────

  /// Resolve event ke typed notification tanpa dispatch (untuk testing).
  NotiflowNotification? resolve(NotificationEvent event);

  /// Jumlah handler yang terdaftar.
  int get registeredCount;

  /// Reset semua state — registry, middleware, navigator.
  void reset();
}
