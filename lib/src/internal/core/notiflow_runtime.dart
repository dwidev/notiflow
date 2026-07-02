import 'package:flutter/foundation.dart';
import 'package:notiflow/src/internal/core/notiflow_config.dart';
import 'package:notiflow/src/internal/core/notiflow_middleware_pipeline.dart';

import '../../../notiflow.dart';
import '../registry/notiflow_registry.dart';

class NotiflowRuntime {
  late final NotiflowRegistry _registry;
  late final NotiflowMiddlewarePipeline _pipeline;
  late NotiflowNavigator _navigator;

  void initialize(NotiflowConfig config) {
    _navigator = config.navigator;
    _registry = NotiflowRegistry(config.routres);
    _pipeline = NotiflowMiddlewarePipeline(middlewares: config.middlewares);
  }

  Future<void> dispatch({required NotificationEvent event}) async {
    final result = await _pipeline.execute(
      event: event,
      terminal: (processed) async {
        final handled = await _registry.dispatch(processed, _navigator);
        if (!handled) {
          debugPrint(
            '[NotiFlow] ⚠ No handler for: $event '
            '(source: ${event.source.name})',
          );
        }

        return MiddlewareFinish();
      },
    );

    if (result is MiddlewareStop) {
      debugPrint('[NotiFlow] ⛔ Stopped — reason: ${result.reason}');
    }
  }

  void showInspector() {}

  void dispose() {
    _pipeline.clear();
    _registry.clear();
  }
}
