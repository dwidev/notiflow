import 'package:flutter/material.dart';

import '../interfaces/notiflow_navigator.dart';

/// [NotiflowNavigator] adapter untuk Flutter Navigator 1.0.
///
/// Menggunakan [GlobalKey<NavigatorState>] untuk navigasi tanpa [BuildContext].
///
/// ## Setup
///
/// ```dart
/// // 1. Buat GlobalKey di main.dart
/// final navigatorKey = GlobalKey<NavigatorState>();
///
/// // 2. Pass ke MaterialApp
/// MaterialApp(
///   navigatorKey: navigatorKey,
///   // ...
/// )
///
/// // 3. Set di NotiFlow
/// NotiFlow.instance.setNavigator(
///   NavigatorKeyAdapter(navigatorKey: navigatorKey),
/// );
/// ```
class NavigatorKeyAdapter implements NotiflowNavigator {
  final GlobalKey<NavigatorState> navigatorKey;

  const NavigatorKeyAdapter({required this.navigatorKey});

  NavigatorState get _navigator {
    final state = navigatorKey.currentState;
    assert(
      state != null,
      'NavigatorState is null. Pastikan MaterialApp sudah mounted '
      'dan navigatorKey sudah terpasang sebelum dispatch dipanggil.',
    );
    return state!;
  }

  @override
  Future<void> navigateTo(String route, {Object? arguments}) async {
    await _navigator.pushNamed(route, arguments: arguments);
  }

  @override
  Future<void> navigateAndReplace(String route, {Object? arguments}) async {
    await _navigator.pushReplacementNamed(route, arguments: arguments);
  }

  @override
  Future<void> popUntil(String route) async {
    _navigator.popUntil(ModalRoute.withName(route));
  }

  @override
  Future<void> pop<T>([T? result]) async {
    if (_navigator.canPop()) {
      _navigator.pop(result);
    }
  }

  @override
  Future<void> navigateAndClearStack(String route, {Object? arguments}) async {
    await _navigator.pushNamedAndRemoveUntil(
      route,
      (_) => false,
      arguments: arguments,
    );
  }
}
