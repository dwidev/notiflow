# GoRouter Adapter

Copy-paste ready `NotiflowNavigator` implementation for GoRouter.

## Implementation

```dart
import 'package:go_router/go_router.dart';
import 'package:notiflow/notiflow.dart';

class GoRouterAdapter extends NotiflowNavigatorAdapter {
  const GoRouterAdapter({required this.router});
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
    while (router.canPop()) {
      router.pop();
    }
  }

  @override
  Future<void> pop<T>([T? result]) async {
    if (router.canPop()) {
      router.pop(result);
    }
  }

  @override
  Future<void> navigateAndClearStack(String route, {Object? arguments}) async {
    while (router.canPop()) {
      router.pop();
    }
    router.go(route, extra: arguments);
  }
}
```

## Usage

```dart
final appRouter = GoRouter(routes: [...]);

Notiflow.instance.setNavigator(GoRouterAdapter(router: appRouter));
```
