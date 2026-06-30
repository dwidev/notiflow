import 'package:go_router/go_router.dart';
import 'package:notiflow/notiflow.dart';

/// GoRouter navigation adapter for NotiFlow.
///
/// Allows notification handlers to navigate using GoRouter
/// without direct dependency on [BuildContext].
///
/// ```dart
/// NotiFlow.instance.setNavigator(
///   GoRouterNavigatorAdapter(router: appRouter),
/// );
/// ```
class GoRouterNavigatorAdapter extends CustomNavigatorAdapter {
  const GoRouterNavigatorAdapter({required this.router});

  final GoRouter router;

  @override
  Future<void> navigateTo(String route, {Object? arguments}) async {
    router.go(route, extra: arguments);
  }

  @override
  Future<void> navigateAndReplace(String route, {Object? arguments}) async {
    router.pushReplacement(route, extra: arguments);
  }

  @override
  Future<void> popUntil(String route) async {
    // GoRouter doesn't have a direct popUntil — navigate to the route instead
    router.go(route);
  }

  @override
  Future<void> pop<T>([T? result]) async {
    if (router.canPop()) {
      router.pop(result);
    }
  }

  @override
  Future<void> navigateAndClearStack(String route, {Object? arguments}) async {
    router.go(route, extra: arguments);
  }
}
