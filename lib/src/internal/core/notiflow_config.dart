// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

import '../../../notiflow.dart';

@immutable
class NotiflowConfig {
  final NotiflowNavigator navigator;
  final List<NotiflowMiddleware> middlewares;
  final List<NotiflowRoute> routres;

  final bool showInspector;

  const NotiflowConfig({
    required this.navigator,
    this.middlewares = const [],
    required this.routres,
    this.showInspector = true,
  });
}
