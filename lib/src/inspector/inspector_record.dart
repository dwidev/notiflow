// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../notiflow.dart';

class InspectorRecord {
  InspectorRecord({
    required this.id,
    required this.event,
    required this.startedAt,
  });

  final String id;
  final NotificationEvent event;
  final DateTime startedAt;
  DateTime? finishedAt;
  final List<InspectorStep> steps = [];

  Duration get duration => (finishedAt ?? DateTime.now()).difference(startedAt);

  @override
  String toString() =>
      'InspectorRecord(id: $id, event: $event, startedAt: $startedAt)';
}

class InspectorStep {
  InspectorStep({
    required this.name,
    required this.startedAt,
    this.finishedAt,
    this.status,
  });

  final String name;
  final DateTime startedAt;
  DateTime? finishedAt;
  InspectorStepStatus? status;

  Duration get duration => (finishedAt ?? DateTime.now()).difference(startedAt);
}

sealed class InspectorStepStatus {
  final String message;

  InspectorStepStatus({required this.message});
}

final class InspectorSuccess extends InspectorStepStatus {
  InspectorSuccess({required super.message});
}

final class InspectorWarning extends InspectorStepStatus {
  InspectorWarning({required super.message});
}

final class InspectorError extends InspectorStepStatus {
  final Object? exception;
  final StackTrace? stackTrace;

  InspectorError({
    required this.exception,
    required this.stackTrace,
    required super.message,
  });
}
