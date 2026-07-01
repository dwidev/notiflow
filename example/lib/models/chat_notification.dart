import 'package:notiflow/notiflow.dart';

base class ChatNotification extends NotiflowNotification {
  ChatNotification({
    required super.id,
    required super.receivedAt,
    required super.rawData,
    required this.type,
  });

  final String type;
}
