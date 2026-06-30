/// Inspector plugin for NotiFlow.
///
/// Provides a debug overlay UI that shows real-time notification lifecycle
/// traces and maintains a queryable notification history.
///
/// Automatically disabled in release builds (zero overhead in production).
///
/// ```dart
/// NotiFlow.instance.addPlugin(
///   NotiflowInspectorPlugin(
///     enableInRelease: false,  // default
///     maxHistorySize: 100,     // default
///   ),
/// );
/// ```
class NotiflowInspectorPlugin {
  NotiflowInspectorPlugin({
    this.enableInRelease = false,
    this.maxHistorySize = 100,
  });

  /// Whether to enable the inspector in release builds.
  final bool enableInRelease;

  /// Maximum number of notification entries to keep in history.
  final int maxHistorySize;

  String get id => 'notiflow_inspector';

  // TODO: Implement install() — integrate with NotiFlow middleware pipeline
  // to capture trace data for each notification lifecycle.

  // TODO: Implement overlay UI widget.

  // TODO: Implement notification history with getHistory(), exportJson(), clearHistory().

  // TODO: Implement DevTools extension.
}
