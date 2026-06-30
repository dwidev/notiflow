import 'package:notiflow/notiflow.dart';

base class ChatNotification extends NotiflowNotification {
  const ChatNotification({
    required super.id,
    required super.receivedAt,
    required super.source,
    required super.rawData,
    required this.chatId,
    required this.senderName,
    this.preview,
  });

  final String chatId;
  final String senderName;
  final String? preview;
}

class ChatNotificationParser extends NotiflowParser<ChatNotification> {
  @override
  ChatNotification parse(NotificationEvent event) {
    final payload = event.payload;
    final chatId = payload['chat_id'];

    if (chatId is! String || chatId.isEmpty) {
      throw NotiflowParseException(
        message: 'chat_id is required',
        payload: payload,
      );
    }

    return ChatNotification(
      id: event.id,
      receivedAt: event.receivedAt,
      source: event.source,
      rawData: payload,
      chatId: chatId,
      senderName: payload['sender_name'] as String? ?? 'Unknown',
      preview: payload['preview'] as String?,
    );
  }
}

class ChatNotificationHandler extends NotiflowHandler<ChatNotification> {
  @override
  Future<void> onForeground(
    ChatNotification notification,
    NotiflowNavigator navigator,
  ) async {
    // App is active — in a real app, show in-app banner or update badge
    debugPrintNotiflow(
      '💬 Chat from ${notification.senderName}: ${notification.preview ?? "New message"}',
    );
  }

  @override
  Future<void> onOpened(
    ChatNotification notification,
    NotiflowNavigator navigator,
  ) async {
    await navigator.navigateTo(
      '/chat',
      arguments: {'chatId': notification.chatId},
    );
  }

  @override
  Future<void> onLaunch(
    ChatNotification notification,
    NotiflowNavigator navigator,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await navigator.navigateTo(
      '/chat',
      arguments: {'chatId': notification.chatId},
    );
  }
}

void debugPrintNotiflow(String message) {
  // ignore: avoid_print
  print('[NotiFlow Example] $message');
}
