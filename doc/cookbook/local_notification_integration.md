# Local Notification Integration

Copy-paste ready recipe for integrating flutter_local_notifications with NotiFlow.

## Setup

```dart
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notiflow/notiflow.dart';

Future<void> setupLocalNotificationsWithNotiflow() async {
  final plugin = FlutterLocalNotificationsPlugin();

  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await plugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      final payload = response.payload;
      final data = payload != null
          ? Map<String, dynamic>.from(jsonDecode(payload))
          : <String, dynamic>{};

      Notiflow.instance.dispatch(NotificationEvent(
        source: NotificationSource.local,
        state: NotificationState.background,
        payload: data,
      ));
    },
  );

  // Check if app launched via local notification
  final launchDetails = await plugin.getNotificationAppLaunchDetails();
  if (launchDetails != null &&
      launchDetails.didNotificationLaunchApp &&
      launchDetails.notificationResponse != null) {
    final payload = launchDetails.notificationResponse!.payload;
    final data = payload != null
        ? Map<String, dynamic>.from(jsonDecode(payload))
        : <String, dynamic>{};

    Notiflow.instance.dispatch(NotificationEvent(
      source: NotificationSource.local,
      state: NotificationState.launch,
      payload: data,
    ));
  }
}
```
