import 'package:flutter/material.dart';
import 'package:notiflow/notiflow.dart';

import 'models/chat_notification.dart';
import 'pages/home_page.dart';
import 'pages/chat_page.dart';
import 'pages/order_page.dart';
import 'pages/promo_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final chatRoute = NotiflowRoute<ChatNotification>(
  matcher: (event) => event.payload['type'] == 'chat',
  parse: (event) {
    return ChatNotification(
      id: event.id,
      receivedAt: event.receivedAt,
      rawData: event.payload,
      type: event.payload['type'] as String,
    );
  },
  lifecycle: NotiflowLifecycle(
    onForeground: (event, navigator) async {
      await navigator.push('/chat');
    },
    onLaunch: (event, navigator) async {
      await navigator.push('/chat');
    },
    onOpened: (event, navigator) async {
      await navigator.push('/chat');
    },
  ),
);
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure NotiFlow with Headless Mode
  Notiflow.instance
      .setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
      .addMiddleware(LoggingMiddleware(tag: 'NotiFlow'))
      .addMiddleware(DeduplicationMiddleware())
      .register(route: chatRoute);

  runApp(const NotiflowExampleApp());
}

class NotiflowExampleApp extends StatelessWidget {
  const NotiflowExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotiFlow Example',
      navigatorKey: navigatorKey,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/chat': (_) => const ChatPage(),
        '/order': (_) => const OrderPage(),
        '/promo': (_) => const PromoPage(),
      },
    );
  }
}
