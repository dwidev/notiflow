import 'package:flutter/material.dart';
import 'package:notiflow/notiflow.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NotiFlow Example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Simulate Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap a button to dispatch a notification event through NotiFlow. '
            'Each event goes through the middleware pipeline, gets parsed '
            'into a typed notification, and triggers the appropriate handler.',
          ),
          const SizedBox(height: 24),
          _SimulateButton(
            icon: Icons.chat_bubble,
            label: 'Chat Notification (foreground)',
            color: Colors.blue,
            onPressed: () => _dispatchChat(NotificationState.foreground),
          ),
          _SimulateButton(
            icon: Icons.chat_bubble_outline,
            label: 'Chat Notification (background)',
            color: Colors.blue.shade700,
            onPressed: () => _dispatchChat(NotificationState.background),
          ),
          _SimulateButton(
            icon: Icons.shopping_bag,
            label: 'Order Notification (background)',
            color: Colors.orange,
            onPressed: () => _dispatchOrder(NotificationState.background),
          ),
          _SimulateButton(
            icon: Icons.local_offer,
            label: 'Promo Notification (background)',
            color: Colors.green,
            onPressed: () => _dispatchPromo(NotificationState.background),
          ),
          _SimulateButton(
            icon: Icons.rocket_launch,
            label: 'Order Notification (launch)',
            color: Colors.deepPurple,
            onPressed: () => _dispatchOrder(NotificationState.launch),
          ),
          _SimulateButton(
            icon: Icons.help_outline,
            label: 'Unknown Type (no handler)',
            color: Colors.grey,
            onPressed: () => _dispatchUnknown(),
          ),
        ],
      ),
    );
  }

  void _dispatchChat(NotificationState state) {
    Notiflow.instance.dispatch(
      NotificationEvent(
        source: NotificationSource.firebase,
        state: state,
        payload: {
          'type': 'chat',
          'chat_id': 'room-123',
          'sender_name': 'Aisha',
          'preview': 'Hey! Check this out 🎉',
        },
        metadata: {'title': 'Aisha', 'body': 'Hey! Check this out 🎉'},
      ),
    );
  }

  void _dispatchOrder(NotificationState state) {
    Notiflow.instance.dispatch(
      NotificationEvent(
        source: NotificationSource.firebase,
        state: state,
        payload: {'type': 'order', 'order_id': 'ORD-9876', 'status': 'shipped'},
      ),
    );
  }

  void _dispatchPromo(NotificationState state) {
    Notiflow.instance.dispatch(
      NotificationEvent(
        source: NotificationSource.oneSignal,
        state: state,
        payload: {'type': 'promo', 'promo_code': 'SAVE20', 'discount': '20%'},
      ),
    );
  }

  void _dispatchUnknown() {
    Notiflow.instance.dispatch(
      NotificationEvent(
        source: NotificationSource.custom,
        state: NotificationState.foreground,
        payload: {'type': 'unknown_type', 'data': 'something'},
      ),
    );
  }
}

class _SimulateButton extends StatelessWidget {
  const _SimulateButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size.fromHeight(52),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
