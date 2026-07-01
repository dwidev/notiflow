import '../models/notification_event.dart';
import '../models/notiflow_notification.dart';

/// Interface untuk mengubah [NotificationEvent] menjadi typed notification.
///
/// Implement interface ini untuk setiap tipe notifikasi di aplikasi.
///
/// ```dart
/// class ChatNotificationParser extends NotiflowParser<ChatNotification> {
///   @override
///   ChatNotification parse(NotificationEvent event) {
///     final data = event.payload;
///     return ChatNotification(
///       id: event.id,
///       receivedAt: event.receivedAt,
///       source: event.source,
///       rawData: data,
///       chatId: data['chat_id'] as String,
///       senderName: data['sender_name'] as String? ?? 'Unknown',
///       preview: data['preview'] as String? ?? '',
///     );
///   }
/// }
/// ```
abstract class NotiflowParser<T extends NotiflowNotification> {
  /// Parse [event] menjadi typed notification object [T].
  ///
  /// Throw [NotiflowParseException] jika data tidak valid atau field wajib tidak ada.
  T parse(NotificationEvent event);
}
