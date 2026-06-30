/// NotiFlow Firebase Plugin — auto-listen to Firebase Cloud Messaging.
///
/// ```dart
/// NotiFlow.instance
///   .addPlugin(NotiflowFirebasePlugin(
///     messaging: FirebaseMessaging.instance,
///   ));
///
/// await NotiFlow.instance.start();
/// ```
library;

export 'src/notiflow_firebase_plugin.dart';
