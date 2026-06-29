/// NotiFlow — Notification Runtime Framework for Flutter.
///
/// **Handle. Observe. Debug. Dispatch.**
///
/// ## Quick Start (Headless Mode)
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   final navigatorKey = GlobalKey<NavigatorState>();
///
///   NotiFlow.instance
///     .setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
///     .addMiddleware(LoggingMiddleware())
///     .addMiddleware(DeduplicationMiddleware())
///     .register<ChatNotification>(
///       matcher: (event) => event.payload['type'] == 'chat',
///       parser: ChatNotificationParser(),
///       handler: ChatNotificationHandler(),
///     )
///     .setFallbackHandler(DefaultFallbackHandler());
///
///   // Headless — terima event dari Firebase manual
///   FirebaseMessaging.onMessage.listen((msg) {
///     NotiFlow.instance.dispatch(NotificationEvent(
///       source: NotificationSource.firebase,
///       state: NotificationState.foreground,
///       payload: msg.data,
///     ));
///   });
///
///   runApp(MyApp(navigatorKey: navigatorKey));
/// }
/// ```
library;

// Models
export 'src/models/notification_event.dart';
export 'src/models/notification_source.dart';
export 'src/models/notification_state.dart';
export 'src/models/notiflow_notification.dart';

// Interfaces
export 'src/interfaces/notiflow_handler.dart';
export 'src/interfaces/notiflow_middleware.dart';
export 'src/interfaces/notiflow_navigator.dart';
export 'src/interfaces/notiflow_parser.dart';

// Navigator Adapters
export 'src/adapters/navigator_key_adapter.dart';
export 'src/adapters/custom_navigator_adapter.dart';

// Built-in Middleware
export 'src/middleware/builtin_middleware.dart';
