import '../../../notiflow.dart';
import '../../interfaces/notiflow_handler.dart';
import '../../interfaces/notiflow_parser.dart';
import '../core/notiflow_entry.dart';
import '../routes/router_handler.dart';
import '../routes/router_parser.dart';

/// Internal registry — menyimpan semua entry dan mencari handler yang cocok.
///
/// Strategi performa:
/// - **Type-key cache**: payload `type` field di-cache ke entry index
///   → O(1) lookup untuk kasus umum (payload selalu punya 'type')
/// - **Linear scan fallback**: jika tidak ada di cache, scan berurutan
/// - **Unmodifiable view**: entries tidak bisa dimodifikasi dari luar
final class _NotiflowRegistry {
  _NotiflowRegistry(List<NotiflowRoute> routes) {
    for (final route in routes) {
      final parser = RouterParser(parser: route.parse);
      final handler = RouterHandler(lifecycle: route.lifecycle);
      _register(matcher: route.matcher, parser: parser, handler: handler);
    }
  }

  // Ordered list — urutan registrasi menentukan prioritas matching
  final List<NotiflowEntry> _entries = [];

  // Cache: payload['type'] string → index di _entries
  // Menghindari full scan untuk tipe yang sudah pernah di-match
  final Map<String, int> _typeIndexCache = {};

  NotiflowHandler<NotiflowNotification>? _fallbackHandler;

  void _register<T extends NotiflowNotification>({
    required bool Function(NotificationEvent event) matcher,
    required NotiflowParser<T> parser,
    required NotiflowHandler<T> handler,
  }) {
    _entries.add(
      NotiflowEntry<T>(matcher: matcher, parser: parser, handler: handler),
    );
  }

  void setFallbackHandler(NotiflowHandler<NotiflowNotification> handler) {
    _fallbackHandler = handler;
  }

  /// Cari dan dispatch event ke handler yang tepat.
  ///
  /// Returns `true` jika handler ditemukan.
  Future<bool> dispatch(
    NotificationEvent event,
    NotiflowNavigator navigator,
  ) async {
    final entry = _findEntry(event);

    if (entry != null) {
      await entry.dispatch(event, navigator);
      return true;
    }

    if (_fallbackHandler != null) {
      await _dispatchFallback(event, navigator);
      return true;
    }

    return false;
  }

  /// Resolve event ke typed notification tanpa dispatch.
  NotiflowNotification? resolve(NotificationEvent event) {
    final entry = _findEntry(event);
    if (entry == null) return null;
    try {
      return entry.parse(event);
    } catch (_) {
      return null;
    }
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  NotiflowEntry? _findEntry(NotificationEvent event) {
    if (_entries.isEmpty) return null;

    // Fast path: cek type cache dulu — O(1)
    final typeKey = event.payload['type'] as String?;
    if (typeKey != null) {
      final cachedIdx = _typeIndexCache[typeKey];
      if (cachedIdx != null && cachedIdx < _entries.length) {
        final cached = _entries[cachedIdx];
        if (cached.matches(event)) return cached;
        // Cache invalid (mis. entry diubah), hapus cache
        _typeIndexCache.remove(typeKey);
      }
    }

    // Slow path: linear scan — O(n)
    for (var i = 0; i < _entries.length; i++) {
      if (_entries[i].matches(event)) {
        // Simpan ke cache untuk lookup berikutnya
        if (typeKey != null) _typeIndexCache[typeKey] = i;
        return _entries[i];
      }
    }

    return null;
  }

  Future<void> _dispatchFallback(
    NotificationEvent event,
    NotiflowNavigator navigator,
  ) async {
    final notification = _FallbackNotification(event);
    final handler = _fallbackHandler!;
    switch (event.state) {
      case NotificationState.foreground:
        await handler.onForeground(notification, navigator);
      case NotificationState.background:
        await handler.onOpened(notification, navigator);
      case NotificationState.launch:
        await handler.onLaunch(notification, navigator);
    }
  }

  int get entryCount => _entries.length;

  void clear() {
    _entries.clear();
    _typeIndexCache.clear();
    _fallbackHandler = null;
  }
}

// Internal fallback notification wrapper
final class _FallbackNotification extends NotiflowNotification {
  _FallbackNotification(NotificationEvent event)
    : super(id: event.id, receivedAt: event.receivedAt, rawData: event.payload);
}

typedef NotiflowRegistry = _NotiflowRegistry;
