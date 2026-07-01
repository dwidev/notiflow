import '../models/notification_event.dart';
import '../models/notification_source.dart';
import '../models/notification_state.dart';

/// Extension untuk mempersingkat pembuatan [NotificationEvent] dari Map.
///
/// Ini murni syntactic sugar — tidak ada logic tersembunyi,
/// tidak ada dependency ke provider tertentu.
///
/// ## Tanpa extension
///
/// ```dart
/// NotiFlow.instance.dispatch(NotificationEvent(
///   source: NotificationSource.firebase,
///   state: NotificationState.foreground,
///   payload: message.data,
/// ));
/// ```
///
/// ## Dengan extension — tetap transparan, cuma lebih ringkas
///
/// ```dart
/// NotiFlow.instance.dispatch(
///   message.data.toNotificationEvent(
///     source: NotificationSource.firebase,
///     state: NotificationState.foreground,
///   ),
/// );
/// ```
extension NotiflowEventBuilder on Map<String, dynamic> {
  /// Konversi Map menjadi [NotificationEvent].
  ///
  /// Map ini menjadi `payload` dari event yang dihasilkan.
  NotificationEvent toNotificationEvent({
    required NotificationSource source,
    required NotificationState state,
    Map<String, dynamic> metadata = const {},
    String? id,
  }) {
    return NotificationEvent(
      id: id,
      source: source,
      state: state,
      payload: this,
      metadata: metadata,
    );
  }
}
