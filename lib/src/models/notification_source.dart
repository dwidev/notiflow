/// Sumber asal notifikasi masuk.
enum NotificationSource {
  /// Firebase Cloud Messaging.
  firebase,

  /// OneSignal.
  oneSignal,

  /// Flutter Local Notifications.
  local,

  /// Provider custom buatan developer.
  custom,
}
