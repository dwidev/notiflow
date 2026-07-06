/// NotiFlow — Notification Runtime Framework for Flutter.
///
/// **Handle. Observe. Debug. Dispatch.**
///
/// Single package. Full transparency. Zero magic.
///
/// ## Quick Start
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   final navigatorKey = GlobalKey<NavigatorState>();
///
///   Notiflow.instance
///     .setNavigator(NavigatorKeyAdapter(navigatorKey: navigatorKey))
///     .addMiddleware(LoggingMiddleware())
///     .register<ChatNotification>(
///       matcher: (event) => event.payload['type'] == 'chat',
///       parser: ChatNotificationParser(),
///       handler: ChatNotificationHandler(),
///     );
///
///   // Manual dispatch — kamu kontrol penuh
///   FirebaseMessaging.onMessage.listen((msg) {
///     Notiflow.instance.dispatch(NotificationEvent(
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
export 'src/interfaces/inotiflow.dart';
export 'src/interfaces/notiflow_navigator.dart';

// Navigator Adapters
export 'src/navigators/navigator_key_adapter.dart';
export 'src/navigators/custom_navigator_adapter.dart';

// Built-in Middleware
export 'src/middleware/builtin_middleware.dart';

// Extensions
export 'src/extensions/event_builder_extension.dart';

// exceptions
export 'src/internal/exceptions/parser_exception.dart';

// routes
export 'src/internal/routes/notiflow_route.dart';
export 'src/internal/routes/notiflow_lifecycle.dart';

// core
export 'src/internal/core/notiflow_config.dart';
