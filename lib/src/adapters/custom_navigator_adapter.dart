import '../interfaces/notiflow_navigator.dart';

/// Base adapter untuk implementasi [NotiflowNavigator] custom.
///
/// Gunakan ini jika tidak pakai Navigator 1.0, GoRouter, atau AutoRoute,
/// atau jika ingin intercept navigasi sebelum diteruskan ke navigator asli.
///
/// ```dart
/// class MyNavigatorAdapter extends NotiflowNavigatorAdapter {
///   final MyRouter router;
///
///   MyNavigatorAdapter({required this.router});
///
///   @override
///   Future<void> navigateTo(String route, {Object? arguments}) async {
///     // log sebelum navigate
///     analytics.trackNavigation(route);
///     await router.go(route, extra: arguments);
///   }
///
///   @override
///   Future<void> navigateAndReplace(String route, {Object? arguments}) async {
///     await router.replace(route, extra: arguments);
///   }
///
///   @override
///   Future<void> popUntil(String route) async {
///     await router.popUntil(route);
///   }
///
///   @override
///   Future<void> pop<T>([T? result]) async {
///     router.pop(result);
///   }
///
///   @override
///   Future<void> navigateAndClearStack(String route, {Object? arguments}) async {
///     await router.goAndClearStack(route, extra: arguments);
///   }
/// }
/// ```
abstract class NotiflowNavigatorAdapter implements NotiflowNavigator {
  const NotiflowNavigatorAdapter();
}
