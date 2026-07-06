import '../../notiflow.dart';
import 'inspector_session.dart';
import 'inspector_storage.dart';
import 'inspector_record.dart';

class InspectorRuntime {
  InspectorRuntime._();
  static final InspectorRuntime instance = InspectorRuntime._();

  final InspectorStorage storage = InspectorStorage();

  InspectorSession start(NotificationEvent event) {
    final trace = InspectorRecord(
      id: "NF_${DateTime.now().microsecondsSinceEpoch.toString()}",
      event: event,
      startedAt: DateTime.now(),
    );

    storage.add(trace);
    return InspectorSession(trace);
  }

  void clear() {
    storage.clear();
  }
}
