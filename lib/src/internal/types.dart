import '../interfaces/notiflow_middleware.dart';
import '../models/notification_event.dart';

typedef NotiflowNext =
    Future<NotiflowMiddlewareResult> Function(NotificationEvent event);
typedef EventCallback = Function(NotificationEvent event);
