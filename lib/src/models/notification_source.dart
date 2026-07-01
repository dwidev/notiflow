import 'package:flutter/foundation.dart';

/// Identifies the origin of a [NotificationEvent].
///
/// `NotificationSource` is used for observability purposes such as logging,
/// debugging, analytics, and the notification inspector.
///
/// Notiflow treats every notification provider the same during dispatch.
/// The source is **informational only** and should not affect routing or
/// business logic.
///
/// Built-in sources:
///
/// - [NotificationSource.firebase]
/// - [NotificationSource.oneSignal]
/// - [NotificationSource.localNotification]
///
/// Custom sources can be created for any notification provider:
///
/// ```dart
/// const socket = NotificationSource('socket');
/// const deepLink = NotificationSource('deeplink');
/// const debug = NotificationSource('debug');
/// ```
///
/// Example:
///
/// ```dart
/// final event = NotificationEvent(
///   source: NotificationSource.firebase,
///   state: NotificationState.foreground,
///   payload: message.data,
/// );
/// ```
@immutable
class NotificationSource {
  final String name;

  const NotificationSource(this.name);

  static const firebase = NotificationSource('firebase');
  static const oneSignal = NotificationSource('onesignal');
  static const localNotification = NotificationSource('local_notification');

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSource && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
