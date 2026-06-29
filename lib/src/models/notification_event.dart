import 'notification_source.dart';
import 'notification_state.dart';

/// Unified data model untuk semua notifikasi masuk.
///
/// Semua provider (Firebase, OneSignal, Local) dikonversi ke [NotificationEvent]
/// sebelum masuk ke NotiFlow pipeline. Router tidak perlu tahu apapun
/// tentang provider yang digunakan.
///
/// **Headless Mode — dari Firebase:**
/// ```dart
/// FirebaseMessaging.onMessage.listen((message) {
///   router.dispatch(NotificationEvent(
///     source: NotificationSource.firebase,
///     state: NotificationState.foreground,
///     payload: message.data,
///   ));
/// });
/// ```
///
/// **Headless Mode — dari OneSignal:**
/// ```dart
/// OneSignal.shared.setNotificationOpenedHandler((result) {
///   router.dispatch(NotificationEvent(
///     source: NotificationSource.oneSignal,
///     state: NotificationState.background,
///     payload: Map<String, dynamic>.from(
///       result.notification.additionalData ?? {},
///     ),
///   ));
/// });
/// ```
class NotificationEvent {
  /// ID unik event — di-generate otomatis jika tidak disediakan.
  final String id;

  /// Sumber provider notifikasi.
  final NotificationSource source;

  /// State app saat notifikasi diterima.
  final NotificationState state;

  /// Raw payload dari provider — key/value sesuai backend.
  final Map<String, dynamic> payload;

  /// Waktu event diterima oleh device.
  final DateTime receivedAt;

  /// Metadata tambahan spesifik per provider.
  ///
  /// Contoh: title, body, imageUrl dari FCM notification object.
  /// Tidak dipakai untuk routing — hanya untuk display/logging.
  final Map<String, dynamic> metadata;

  NotificationEvent({
    String? id,
    required this.source,
    required this.state,
    required this.payload,
    DateTime? receivedAt,
    this.metadata = const {},
  })  : id = id ?? _generateId(),
        receivedAt = receivedAt ?? DateTime.now();

  static int _counter = 0;

  static String _generateId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_counter++}';

  /// Buat salinan event dengan field yang diubah.
  NotificationEvent copyWith({
    String? id,
    NotificationSource? source,
    NotificationState? state,
    Map<String, dynamic>? payload,
    DateTime? receivedAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationEvent(
      id: id ?? this.id,
      source: source ?? this.source,
      state: state ?? this.state,
      payload: payload ?? this.payload,
      receivedAt: receivedAt ?? this.receivedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() =>
      'NotificationEvent(id: $id, source: ${source.name}, '
      'state: ${state.name}, payload: $payload)';
}
