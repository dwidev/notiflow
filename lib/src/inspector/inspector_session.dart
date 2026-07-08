import 'inspector_record.dart';

class InspectorSession {
  final InspectorRecord record;

  InspectorSession(this.record);

  final List<InspectorStep> _stack = [];

  void capture(String name) {
    final step = InspectorStep(name: name, startedAt: DateTime.now());
    record.steps.add(step);
    _stack.add(step);
  }

  void success(String message) {
    if (_stack.isEmpty) return;
    final step = _stack.removeLast();
    step.status = InspectorSuccess(message: message);
    step.finishedAt = DateTime.now();
  }

  void warning(String message) {
    if (_stack.isEmpty) return;
    final step = _stack.removeLast();
    step.status = InspectorWarning(message: message);
    step.finishedAt = DateTime.now();
  }

  void error(Object? e, StackTrace? st) {
    if (_stack.isEmpty) return;
    final step = _stack.removeLast();
    step.status = InspectorError(
      exception: e,
      stackTrace: st,
      message: e.toString(),
    );
    step.finishedAt = DateTime.now();
  }

  void finish() {
    // Close any remaining open steps
    final now = DateTime.now();
    for (final step in _stack) {
      step.finishedAt ??= now;
    }
    _stack.clear();
    record.finishedAt = now;
  }
}
