import '../types.dart';

class NotiflowLifecycle {
  final NotiflowLifecycleCallback onForeground;
  final NotiflowLifecycleCallback onLaunch;
  final NotiflowLifecycleCallback onOpened;

  NotiflowLifecycle({
    required this.onForeground,
    required this.onLaunch,
    required this.onOpened,
  });

  factory NotiflowLifecycle.push(String path) {
    return NotiflowLifecycle(
      onForeground: (event, navigator) async {
        await navigator.push(path, arguments: event);
      },
      onLaunch: (event, navigator) async {
        await navigator.push(path, arguments: event);
      },
      onOpened: (event, navigator) async {
        await navigator.push(path, arguments: event);
      },
    );
  }
}
