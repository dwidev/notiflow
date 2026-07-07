import 'package:flutter/material.dart';

import '../../../notiflow.dart';
import '../../inspector/inspector.dart';
import '../registry/notiflow_registry.dart';
import 'notiflow_middleware_pipeline.dart';

class NotiflowRuntime {
  late final NotiflowRegistry _registry;
  late final NotiflowMiddlewarePipeline _pipeline;
  late NotiflowNavigator _navigator;

  void initialize(NotiflowConfig config) {
    _navigator = config.navigator;
    _registry = NotiflowRegistry(config.routes);
    _pipeline = NotiflowMiddlewarePipeline(middlewares: config.middlewares);
  }

  Future<void> dispatch({required NotificationEvent event}) async {
    NotiflowInspector.run(event, () async {
      final result = await _pipeline.execute(
        event: event,
        terminal: (processed) async {
          final handled = await _registry.dispatch(processed, _navigator);
          if (!handled) {
            final msg =
                '⚠️ [NotiFlow] No handler route for event: $event \n'
                '(source: ${event.source.name})';
            NotiflowInspector.captureWithWarning('Dispatcher', message: msg);
          }

          return MiddlewareFinish();
        },
      );

      if (result is MiddlewareStop) {
        NotiflowInspector.captureWithWarning(
          'Dispatcher',
          message: '[NotiFlow] ⛔ Stopped — reason: ${result.reason}',
        );
      }
    });
  }

  void showInspector(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NotiflowInspectorPage()));
  }

  void dispose() {
    _pipeline.clear();
    _registry.clear();
  }
}
