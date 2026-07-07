import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../exceptions/runtime_exeption.dart';
import 'notiflow_runtime.dart';

import '../../../notiflow.dart';

typedef NotiflowInstance = _NotiflowImpl;

/// Implementasi internal [Notiflow].
///
/// Tidak di-export ke public API sama sekali.
/// Hanya bisa diakses via factory `Notiflow.instance` atau `Notiflow.create()`.
final class _NotiflowImpl implements Notiflow {
  final NotiflowRuntime runtime;

  _NotiflowImpl(this.runtime);

  bool _isInitialize = false;

  void initialize(NotiflowConfig config) {
    if (_isInitialize) {
      throw AlreadyInitializedException();
    }

    _isInitialize = true;
    runtime.initialize(config);
  }

  Future<void> dispatch({required NotificationEvent event}) async {
    await runtime.dispatch(event: event);
  }

  void showInspector(BuildContext context) {
    if (!kDebugMode) return;
    runtime.showInspector(context);
  }

  @override
  void dispose() {
    runtime.dispose();
  }
}
