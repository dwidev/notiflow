# Firebase Cloud Messaging Integration

Copy-paste ready recipe for integrating Firebase Messaging with NotiFlow.

## Setup

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notiflow/notiflow.dart';

void setupFirebaseWithNotiflow() {
  // Foreground — app sedang aktif
  FirebaseMessaging.onMessage.listen((message) {
    Notiflow.instance.dispatch(NotificationEvent(
      source: NotificationSource.firebase,
      state: NotificationState.foreground,
      payload: message.data,
      metadata: {
        'title': message.notification?.title,
        'body': message.notification?.body,
      },
    ));
  });

  // Background — user tap notifikasi dari background
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    Notiflow.instance.dispatch(NotificationEvent(
      source: NotificationSource.firebase,
      state: NotificationState.background,
      payload: message.data,
    ));
  });

  // Launch — app di-launch via notifikasi (terminated)
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      Notiflow.instance.dispatch(NotificationEvent(
        source: NotificationSource.firebase,
        state: NotificationState.launch,
        payload: message.data,
      ));
    }
  });
}
```

## Dengan Extension Method (opsional)

```dart
FirebaseMessaging.onMessage.listen((message) {
  Notiflow.instance.dispatch(
    message.data.toNotificationEvent(
      source: NotificationSource.firebase,
      state: NotificationState.foreground,
      metadata: {
        'title': message.notification?.title,
        'body': message.notification?.body,
      },
    ),
  );
});
```

## Full main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final navigatorKey = GlobalKey<NavigatorState>();

  Notiflow.instance
    .setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
    .addMiddleware(LoggingMiddleware(tag: 'NotiFlow'))
    .addMiddleware(DeduplicationMiddleware())
    .register<ChatNotification>(
      matcher: (event) => event.payload['type'] == 'chat',
      parser: ChatNotificationParser(),
      handler: ChatNotificationHandler(),
    );

  setupFirebaseWithNotiflow();

  runApp(MyApp(navigatorKey: navigatorKey));
}
```
