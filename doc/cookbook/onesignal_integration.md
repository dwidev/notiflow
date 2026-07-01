# OneSignal Integration

Copy-paste ready recipe for integrating OneSignal with NotiFlow.

## Setup

```dart
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:notiflow/notiflow.dart';

void setupOneSignalWithNotiflow() {
  OneSignal.initialize('YOUR_ONESIGNAL_APP_ID');

  // Foreground
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    final data = event.notification.additionalData;
    if (data != null) {
      Notiflow.instance.dispatch(NotificationEvent(
        source: NotificationSource.oneSignal,
        state: NotificationState.foreground,
        payload: Map<String, dynamic>.from(data),
        metadata: {
          'title': event.notification.title,
          'body': event.notification.body,
        },
      ));
    }
  });

  // Background — user tap
  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;
    if (data != null) {
      Notiflow.instance.dispatch(NotificationEvent(
        source: NotificationSource.oneSignal,
        state: NotificationState.background,
        payload: Map<String, dynamic>.from(data),
      ));
    }
  });
}
```
