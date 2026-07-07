import 'package:flutter/material.dart';
import 'package:notiflow_example/models/chat_notification.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as ChatNotification;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Chat Room: ${args.id}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Navigated here via NotiFlow handler',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
