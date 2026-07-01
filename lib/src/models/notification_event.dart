import 'package:flutter/foundation.dart';

import 'notification_source.dart';
import 'notification_state.dart';

/// Represents a notification entering the Notiflow runtime.
///
/// Every notification provider (such as Firebase Cloud Messaging,
/// OneSignal, or Local Notifications) should convert its incoming payload
/// into a [NotificationEvent] before calling `dispatch()`.
///
/// Notiflow is provider-agnostic. It does not depend on any specific
/// notification SDK and processes every event through the same pipeline.
///
/// ## Example
///
/// Using Firebase Cloud Messaging:
///
/// ```dart
/// FirebaseMessaging.onMessage.listen((message) {
///   router.dispatch(
///     NotificationEvent(
///       source: NotificationSource.firebase,
///       state: NotificationState.foreground,
///       payload: message.data,
///     ),
///   );
/// });
/// ```
///
/// Using OneSignal:
///
/// ```dart
/// OneSignal.Notifications.addClickListener((event) {
///   router.dispatch(
///     NotificationEvent(
///       source: NotificationSource.oneSignal,
///       state: NotificationState.background,
///       payload: Map<String, Object?>.from(
///         event.notification.additionalData ?? {},
///       ),
///     ),
///   );
/// });
/// ```
@immutable
class NotificationEvent {
  /// Creates a notification event.
  ///
  /// If [id] is not provided, a unique identifier will be generated.
  ///
  /// The provided [payload] and [metadata] are wrapped with
  /// `Map.unmodifiable()` to ensure the event remains immutable.
  NotificationEvent({
    String? id,
    required this.source,
    required this.state,
    required Map<String, Object?> payload,
    DateTime? receivedAt,
    Map<String, Object?> metadata = const {},
  }) : id = id ?? _generateId(),
       payload = Map.unmodifiable(payload),
       metadata = Map.unmodifiable(metadata),
       receivedAt = receivedAt ?? DateTime.now();

  /// Unique identifier of this notification event.
  final String id;

  /// Identifies where this notification originated from.
  ///
  /// This value is intended for logging, debugging, analytics,
  /// and inspection only. It should not affect routing behavior.
  final NotificationSource source;

  /// The application state when the notification was received.
  final NotificationState state;

  /// The timestamp when this event entered the Notiflow runtime.
  final DateTime receivedAt;

  /// The raw payload received from the notification provider.
  ///
  /// This map is immutable and contains the original key-value pairs
  /// sent by the backend.
  final Map<String, Object?> payload;

  /// Additional provider-specific information.
  ///
  /// Unlike [payload], metadata is not used for routing decisions.
  /// It is intended for logging, debugging, or displaying notification
  /// details such as title, body, image URL, or platform-specific values.
  final Map<String, Object?> metadata;

  static int _counter = 0;
  static String _generateId() =>
      'notiflow_${DateTime.now().microsecondsSinceEpoch}_${_counter++}';

  /// Returns a copy of this event with the specified fields replaced.
  NotificationEvent copyWith({
    String? id,
    NotificationSource? source,
    NotificationState? state,
    Map<String, Object?>? payload,
    DateTime? receivedAt,
    Map<String, Object?>? metadata,
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
  String toString() {
    return 'NotificationEvent('
        'id: $id, '
        'source: ${source.name}, '
        'state: ${state.name}, '
        'receivedAt: $receivedAt, '
        'payload: $payload, '
        'metadata: $metadata'
        ')';
  }
}
