/// Abstraksi navigation untuk NotiFlow handler.
///
/// Handler menggunakan [NotiflowNavigator] alih-alih [BuildContext] langsung.
/// Ini memungkinkan:
/// - Handler tidak bergantung pada navigator tertentu (Navigator 1.0, GoRouter, AutoRoute)
/// - Handler lebih mudah di-unit test tanpa mock BuildContext
/// - Navigation provider bisa diganti tanpa ubah handler
///
/// Implementasi disediakan oleh navigation adapter plugin:
/// - `notiflow_go_router` → [GoRouterNotiflowNavigator]
/// - `notiflow_auto_route` → [AutoRouteNotiflowNavigator]
/// - Atau buat sendiri dengan extend class ini
///
/// **Contoh penggunaan di handler:**
/// ```dart
/// class ChatNotificationHandler extends NotiflowHandler<ChatNotification> {
///   @override
///   Future<void> onOpened(ChatNotification n, NotiflowNavigator nav) async {
///     await nav.navigateTo('/chat', arguments: {'chatId': n.chatId});
///   }
/// }
/// ```
abstract class NotiflowNavigator {
  /// Navigate ke [route] dengan optional [arguments].
  ///
  /// Ekuivalen dengan `Navigator.pushNamed()` atau `GoRouter.go()`.
  Future<void> navigateTo(String route, {Object? arguments});

  /// Navigate ke [route] dan replace halaman saat ini.
  ///
  /// Ekuivalen dengan `Navigator.pushReplacementNamed()` atau `GoRouter.replace()`.
  Future<void> navigateAndReplace(String route, {Object? arguments});

  /// Pop semua halaman hingga [route].
  ///
  /// Ekuivalen dengan `Navigator.popUntil()`.
  Future<void> popUntil(String route);

  /// Pop halaman saat ini dengan optional [result].
  Future<void> pop<T>([T? result]);

  /// Navigate ke [route] dan clear seluruh stack.
  ///
  /// Berguna saat notifikasi harus membawa user ke halaman utama dari manapun.
  Future<void> navigateAndClearStack(String route, {Object? arguments});
}
