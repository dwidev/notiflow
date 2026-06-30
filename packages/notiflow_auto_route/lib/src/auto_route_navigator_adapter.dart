import 'package:auto_route/auto_route.dart';
import 'package:notiflow/notiflow.dart';

/// AutoRoute navigation adapter for NotiFlow.
///
/// ```dart
/// NotiFlow.instance.setNavigator(
///   AutoRouteNavigatorAdapter(router: appRouter),
/// );
/// ```
class AutoRouteNavigatorAdapter extends CustomNavigatorAdapter {
  const AutoRouteNavigatorAdapter({required this.router});

  final StackRouter router;

  @override
  Future<void> navigateTo(String route, {Object? arguments}) async {
    await router.pushNamed(route);
  }

  @override
  Future<void> navigateAndReplace(String route, {Object? arguments}) async {
    await router.replaceNamed(route);
  }

  @override
  Future<void> popUntil(String route) async {
    router.popUntilRouteWithName(route);
  }

  @override
  Future<void> pop<T>([T? result]) async {
    await router.maybePop();
  }

  @override
  Future<void> navigateAndClearStack(String route, {Object? arguments}) async {
    await router.pushNamed(route);
  }
}
