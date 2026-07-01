import '../../../notiflow.dart';
import '../../interfaces/notiflow_handler.dart';
import '../../interfaces/notiflow_parser.dart';

// Alias internal — tidak di-export ke public API
typedef NotiflowEntry<T extends NotiflowNotification> = _NotiflowEntry<T>;

/// Internal binding: matcher + parser + handler untuk satu tipe notifikasi.
///
/// Sealed agar tidak bisa di-extend dari luar package.
/// `base` memastikan tidak ada implementasi publik.
base class _NotiflowEntry<T extends NotiflowNotification> {
  final bool Function(NotificationEvent event) matcher;
  final NotiflowParser<T> parser;
  final NotiflowHandler<T> handler;

  // Cache terakhir matched event ID untuk skip re-matching cepat
  String? _lastMatchedId;

  _NotiflowEntry({
    required this.matcher,
    required this.parser,
    required this.handler,
  });

  bool matches(NotificationEvent event) {
    // Fast path: kalau ID sama dengan last match, langsung true
    if (_lastMatchedId == event.id) return true;
    try {
      final result = matcher(event);
      if (result) _lastMatchedId = event.id;
      return result;
    } catch (_) {
      return false;
    }
  }

  T parse(NotificationEvent event) => parser.parse(event);

  Future<void> dispatch(
    NotificationEvent event,
    NotiflowNavigator navigator,
  ) async {
    final notification = parse(event);
    switch (event.state) {
      case NotificationState.foreground:
        await handler.onForeground(notification, navigator);
      case NotificationState.background:
        await handler.onOpened(notification, navigator);
      case NotificationState.launch:
        await handler.onLaunch(notification, navigator);
    }
  }
}
