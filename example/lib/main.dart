import 'package:flutter/material.dart';
import 'package:notiflow/notiflow.dart';

import 'notifications/chat_notification.dart';
import 'notifications/order_notification.dart';
import 'notifications/promo_notification.dart';
import 'pages/home_page.dart';
import 'pages/chat_page.dart';
import 'pages/order_page.dart';
import 'pages/promo_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure NotiFlow with Headless Mode
  Notiflow.instance
      .setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
      .addMiddleware(LoggingMiddleware(tag: 'NotiFlow'))
      .addMiddleware(DeduplicationMiddleware())
      .register<ChatNotification>(
        matcher: (event) => event.payload['type'] == 'chat',
        parser: ChatNotificationParser(),
        handler: ChatNotificationHandler(),
      )
      .register<OrderNotification>(
        matcher: (event) => event.payload['type'] == 'order',
        parser: OrderNotificationParser(),
        handler: OrderNotificationHandler(),
      )
      .register<PromoNotification>(
        matcher: (event) => event.payload['type'] == 'promo',
        parser: PromoNotificationParser(),
        handler: PromoNotificationHandler(),
      );

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
