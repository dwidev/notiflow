import 'dart:async';

import 'package:notiflow/notiflow.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal plugin for NotiFlow.
///
/// Automatically listens to OneSignal notification events and dispatches
/// them through the NotiFlow pipeline.
///
/// ```dart
/// NotiFlow.instance.addPlugin(
///   NotiflowOneSignalPlugin(appId: 'YOUR_ONESIGNAL_APP_ID'),
/// );
/// ```
class NotiflowOneSignalPlugin {
  NotiflowOneSignalPlugin({required this.appId});

  final String appId;

  String get id => 'notiflow_onesignal';

  Future<void> install(Notiflow router) async {
    OneSignal.initialize(appId);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final data = event.notification.additionalData;
      if (data != null) {
        router.dispatch(
          NotificationEvent(
            source: NotificationSource.oneSignal,
            state: NotificationState.foreground,
            payload: Map<String, dynamic>.from(data),
            metadata: {
              if (event.notification.title != null)
                'title': event.notification.title,
              if (event.notification.body != null)
                'body': event.notification.body,
            },
          ),
        );
      }
    });

    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data != null) {
        router.dispatch(
          NotificationEvent(
            source: NotificationSource.oneSignal,
            state: NotificationState.background,
            payload: Map<String, dynamic>.from(data),
          ),
        );
      }
    });
  }

  Future<void> dispose() async {
    // OneSignal SDK does not provide a way to remove listeners.
  }
}
