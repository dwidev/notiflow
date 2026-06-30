import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notiflow/notiflow.dart';

/// Local Notifications plugin for NotiFlow.
///
/// Bridges `flutter_local_notifications` responses into the NotiFlow pipeline.
///
/// ```dart
/// NotiFlow.instance.addPlugin(
///   NotiflowLocalPlugin(
///     plugin: FlutterLocalNotificationsPlugin(),
///     initSettings: initializationSettings,
///   ),
/// );
/// ```
class NotiflowLocalPlugin {
  NotiflowLocalPlugin({required this.plugin, required this.initSettings});

  final FlutterLocalNotificationsPlugin plugin;
  final InitializationSettings initSettings;

  String get id => 'notiflow_local';

  Future<void> install(Notiflow router) async {
    await plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        final data = payload != null
            ? Map<String, dynamic>.from(
                jsonDecode(payload) as Map<String, dynamic>,
              )
            : <String, dynamic>{};

        router.dispatch(
          NotificationEvent(
            source: NotificationSource.local,
            state: NotificationState.background,
            payload: data,
          ),
        );
      },
    );

    // Check if app was launched via local notification
    final launchDetails = await plugin.getNotificationAppLaunchDetails();
    if (launchDetails != null &&
        launchDetails.didNotificationLaunchApp &&
        launchDetails.notificationResponse != null) {
      final payload = launchDetails.notificationResponse!.payload;
      final data = payload != null
          ? Map<String, dynamic>.from(
              jsonDecode(payload) as Map<String, dynamic>,
            )
          : <String, dynamic>{};

      await router.dispatch(
        NotificationEvent(
          source: NotificationSource.local,
          state: NotificationState.launch,
          payload: data,
        ),
      );
    }
  }

  Future<void> dispose() async {
    // flutter_local_notifications does not provide listener cleanup.
  }
}
