import '../../interfaces/notiflow_parser.dart';
import '../../models/notification_event.dart';
import '../../models/notiflow_notification.dart';
import '../types.dart';

class RouterParser<T extends NotiflowNotification> extends NotiflowParser<T> {
  final NotifParse parser;

  RouterParser({required this.parser});

  @override
  T parse(NotificationEvent event) {
    final result = parser(event);
    return result as T;
  }
}
