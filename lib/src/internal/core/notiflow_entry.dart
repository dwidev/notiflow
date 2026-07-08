

import '../../../notiflow.dart';
import '../../inspector/inspector.dart';
import '../../interfaces/notiflow_handler.dart';
import '../../interfaces/notiflow_parser.dart';

typedef NotiflowEntry<T extends NotiflowNotification> = _NotiflowEntry<T>;

/// Internal binding: matcher + parser + handler untuk satu tipe notifikasi.
///
/// Sealed agar tidak bisa di-extend dari luar package.
/// `base` memastikan tidak ada implementasi publik.
base class _NotiflowEntry<T extends NotiflowNotification> {
  final bool Function(NotificationEvent event) matcher;
  final NotiflowParser<T> parser;
  final NotiflowHandler<T> handler;

  String? _lastMatchedId;

  _NotiflowEntry({
    required this.matcher,
    required this.parser,
    required this.handler,
  });

  bool matches(NotificationEvent event) {
    if (_lastMatchedId == event.id) return true;
    try {
      final result = matcher(event);
      if (result) _lastMatchedId = event.id;
      return result;
    } catch (e, st) {
      NotiflowInspector.capture('Matcher: ${T.toString()}');
      NotiflowInspector.error(e, st);
      return false;
    }
  }

  T parse(NotificationEvent event) => parser.parse(event);

  Future<void> dispatch(
    NotificationEvent event,
    NotiflowNavigator navigator,
  ) async {
    // Parser
    NotiflowInspector.capture('Parser: ${T.toString()}');
    final T notification;
    try {
      notification = parse(event);
      NotiflowInspector.success('Parsed → ${T.toString()}');
    } catch (e, st) {
      NotiflowInspector.error(e, st);
      return;
    }

    // Handler
    final stateName = event.state.name;
    NotiflowInspector.capture('Handler: ${T.toString()} → $stateName');
    try {
      final handlerFuture = switch (event.state) {
        NotificationState.foreground => handler.onForeground(
            notification,
            navigator,
          ),
        NotificationState.background => handler.onOpened(
            notification,
            navigator,
          ),
        NotificationState.launch => handler.onLaunch(
            notification,
            navigator,
          ),
      };
      await handlerFuture;
      NotiflowInspector.success('Handler complete');
    } catch (e, st) {
      NotiflowInspector.error(e, st);
    }
  }
}
