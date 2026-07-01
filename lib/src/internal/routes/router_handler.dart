import '../../interfaces/notiflow_handler.dart';
import '../../interfaces/notiflow_navigator.dart';
import '../../models/notiflow_notification.dart';
import 'notiflow_lifecycle.dart';

class RouterHandler<T extends NotiflowNotification> extends NotiflowHandler<T> {
  final NotiflowLifecycle lifecycle;

  RouterHandler({required this.lifecycle});

  @override
  Future<void> onForeground(T notification, NotiflowNavigator navigator) async {
    await lifecycle.onForeground(notification, navigator);
  }

  @override
  Future<void> onLaunch(T notification, NotiflowNavigator navigator) async {
    await lifecycle.onLaunch(notification, navigator);
  }

  @override
  Future<void> onOpened(T notification, NotiflowNavigator navigator) async {
    await lifecycle.onLaunch(notification, navigator);
  }
}
