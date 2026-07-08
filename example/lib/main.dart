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
    throw FormatException('chat_id must be string');
    return ChatNotification(
      id: event.id,
      receivedAt: event.receivedAt,
      rawData: event.payload,
      type: event.payload['type'] as String,
    );
  },
  lifecycle: NotiflowLifecycle.push('/chat'),
);

class TestMiddlerware extends NotiflowMiddleware {
  @override
  Future<NotiflowMiddlewareResult> handle(
    NotificationEvent event,
    NotiflowNext next,
  ) async {
    final result = await next(event);
    return result;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure NotiFlow with Headless Mode
  final config = NotiflowConfig(
    navigator: NavigatorKeyAdapter(navigatorKey: navigatorKey),
    routes: [chatRoute],
    middlewares: [
      TestMiddlerware(),
      LoggingMiddleware(tag: "EXAMPLE NOTIFLOW APP"),
    ],
  );
  Notiflow.initialize(config);

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
