import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notiflow/notiflow.dart';

/// Firebase Cloud Messaging plugin for NotiFlow.
///
/// Automatically listens to all three FCM lifecycle events:
/// - `onMessage` → foreground
/// - `onMessageOpenedApp` → background
/// - `getInitialMessage()` → launch (terminated)
///
/// ```dart
/// NotiFlow.instance.addPlugin(
///   NotiflowFirebasePlugin(messaging: FirebaseMessaging.instance),
/// );
/// ```
class NotiflowFirebasePlugin {
  /// Creates a Firebase plugin for NotiFlow.
  ///
  /// [messaging] — the [FirebaseMessaging] instance to listen to.
  NotiflowFirebasePlugin({required this.messaging});

  /// The Firebase Messaging instance.
  final FirebaseMessaging messaging;

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;

  /// Unique plugin identifier.
  String get id => 'notiflow_firebase';

  /// Installs the plugin — starts listening to FCM events.
  ///
  /// Called automatically by `NotiFlow.instance.start()`.
  Future<void> install(Notiflow router) async {
    // Foreground
    _onMessageSub = FirebaseMessaging.onMessage.listen((message) {
      router.dispatch(
        NotificationEvent(
          source: NotificationSource.firebase,
          state: NotificationState.foreground,
          payload: message.data,
          metadata: {
            if (message.notification?.title != null)
              'title': message.notification!.title,
            if (message.notification?.body != null)
              'body': message.notification!.body,
          },
        ),
      );
    });

    // Background (user tapped)
    _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      router.dispatch(
        NotificationEvent(
          source: NotificationSource.firebase,
          state: NotificationState.background,
          payload: message.data,
        ),
      );
    });

    // Terminated (app launched via notification)
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      await router.dispatch(
        NotificationEvent(
          source: NotificationSource.firebase,
          state: NotificationState.launch,
          payload: initial.data,
        ),
      );
    }
  }

  /// Disposes the plugin — cancels all FCM listeners.
  ///
  /// Called automatically by `NotiFlow.instance.stop()`.
  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onMessageOpenedAppSub?.cancel();
    _onMessageSub = null;
    _onMessageOpenedAppSub = null;
  }
}
