import 'package:meta/meta.dart';

import '../../notiflow.dart';
import 'inspector_runtime.dart';

/// Internal bridge used by official NotiFlow adapter packages.
///
/// This API is **NOT** intended to be used directly by applications.
///
/// Used by:
/// - notiflow_firebase
/// - notiflow_onesignal
/// - notiflow_local_notifications
@internal
abstract final class NotiflowInspectorBridge {
  const NotiflowInspectorBridge._();

  static void record({
    required NotificationEvent event,
    required String operation,
    DateTime? timestamp,
  }) {
    final session = InspectorRuntime.instance.start(event);
    session
      ..capture(operation)
      ..finish();
  }
}
