import '../internal/core/notiflow_config.dart';
import '../internal/core/notiflow_impl.dart';
import '../internal/core/notiflow_runtime.dart';
import '../models/notification_event.dart';

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
  static final _instance = NotiflowInstance(NotiflowRuntime());

  /// Singleton instance — satu router untuk seluruh app.
  static Notiflow get instance => _instance;

  /// Buat instance baru — berguna untuk testing atau isolated router.
  static Notiflow create() => NotiflowInstance(NotiflowRuntime());

  /// initialize package
  static void initialize(NotiflowConfig config) {
    _instance.initialize(config);
  }

  /// Dispatch event ke pipeline — entry point utama.
  ///
  /// Semua provider (Firebase, OneSignal, Local, Custom) dikonversi ke
  /// [NotificationEvent] lalu dipanggil lewat method ini.
  static Future<void> dispatch(NotificationEvent event) async {
    await _instance.dispatch(event: event);
  }

  void dispose();
}
