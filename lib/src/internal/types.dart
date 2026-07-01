import 'dart:async';

import '../interfaces/notiflow_middleware.dart';
import '../interfaces/notiflow_navigator.dart';
import '../models/notification_event.dart';
import '../models/notiflow_notification.dart';

typedef NotiflowNext =
    Future<NotiflowMiddlewareResult> Function(NotificationEvent event);

typedef EventCallback = Function(NotificationEvent event);

typedef NotifMatcher = bool Function(NotificationEvent event);
typedef NotifParse<T extends NotiflowNotification> =
    T Function(NotificationEvent event);

typedef NotiflowLifecycleCallback<T extends NotiflowNotification> =
    Future<void> Function(T event, NotiflowNavigator navigator);
