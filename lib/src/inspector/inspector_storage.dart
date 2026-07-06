import 'inspector_record.dart';

class InspectorStorage {
  final List<InspectorRecord> _traces = [];

  void add(InspectorRecord trace) {
    _traces.insert(0, trace);

    if (_traces.length > 100) {
      _traces.removeLast();
    }
  }

  List<InspectorRecord> get traces => List.unmodifiable(_traces);

  void clear() {
    _traces.clear();
  }
}
