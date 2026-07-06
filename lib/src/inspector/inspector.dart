import 'dart:async';

import '../../notiflow.dart';
import 'inspector_runtime.dart';
import 'inspector_session.dart';

abstract final class NotiflowInspector {
  static const _key = #notiflow_inspector_session;

  static InspectorSession? get _recordSession {
    return Zone.current[_key] as InspectorSession?;
  }

  static Future<T> run<T>(
    NotificationEvent event,
    Future<T> Function() action,
  ) async {
    final session = InspectorRuntime.instance.start(event);

    return runZoned(() async {
      try {
        return await action();
      } catch (e, st) {
        session.error(e, st);
        rethrow;
      } finally {
        session.finish();
      }
    }, zoneValues: {_key: session});
  }

  static void capture(String name) => _recordSession?.capture(name);

  static void success(String message) {
    _recordSession?.success(message);
  }

  static void warning(String message) {
    _recordSession?.warning(message);
  }

  static void error(Object? e, StackTrace? st) {
    _recordSession?.error(e, st);
  }

  static void finish() {
    _recordSession?.finish();
  }
}
