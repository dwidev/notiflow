// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'notification_source.dart';

/// Base class untuk semua typed notification model.
///
/// Extend class ini untuk membuat model spesifik per tipe notifikasi.
///
/// ```dart
/// class ChatNotification extends NotiflowNotification {
///   final String chatId;
///   final String senderName;
///
///   const ChatNotification({
///     required super.id,
///     required super.receivedAt,
///     required super.source,
///     required super.rawData,
///     required this.chatId,
///     required this.senderName,
///   });
/// }
/// ```
abstract base class NotiflowNotification {
  /// ID unik notifikasi — diambil dari [NotificationEvent.id].
  final String id;

  /// Waktu notifikasi diterima.
  final DateTime receivedAt;

  /// Sumber provider — Firebase, OneSignal, Local, Custom.
  final NotificationSource source;

  /// Raw payload original dari provider — untuk keperluan debugging.
  final Map<String, dynamic> rawData;

  const NotiflowNotification({
    required this.id,
    required this.receivedAt,
    required this.source,
    required this.rawData,
  });

  @override
  String toString() {
    return 'NotiflowNotification(id: $id, receivedAt: $receivedAt, source: $source, rawData: $rawData)';
  }
}
