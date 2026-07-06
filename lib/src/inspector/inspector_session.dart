import 'inspector_record.dart';

class InspectorSession {
  final InspectorRecord record;

  InspectorSession(this.record);

  InspectorStep? _current;

  void capture(String name) {
    _current?.finishedAt = DateTime.now();
    final step = InspectorStep(name: name, startedAt: DateTime.now());
    record.steps.add(step);
    _current = step;
  }

  void success(String message) {
    _current?.status = InspectorSuccess(message: message);
    _current?.finishedAt = DateTime.now();
  }

  void warning(String message) {
    _current?.status = InspectorWarning(message: message);
    _current?.finishedAt = DateTime.now();
  }

  void error(Object? e, StackTrace? st) {
    final messageError = e.toString();
    _current?.status = InspectorError(
      exception: e,
      stackTrace: st,
      message: messageError,
    );
    _current?.finishedAt = DateTime.now();
  }

  void finish() {
    _current?.finishedAt = DateTime.now();
    record.finishedAt = DateTime.now();
  }
}
