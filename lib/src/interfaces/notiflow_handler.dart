import 'notiflow_navigator.dart';
import '../models/notiflow_notification.dart';

/// Interface untuk menangani notifikasi yang sudah di-parse.
///
/// Implement interface ini untuk setiap tipe notifikasi di aplikasi.
/// Setiap method merepresentasikan satu state aplikasi yang berbeda.
///
/// ```dart
/// class ChatNotificationHandler extends NotiflowHandler<ChatNotification> {
///   @override
///   Future<void> onForeground(
///     ChatNotification notification,
///     NotiflowNavigator navigator,
///   ) async {
///     // App aktif — tampilkan in-app banner/snackbar
///     // Jangan navigate, user sedang aktif menggunakan app
///   }
///
///   @override
///   Future<void> onOpened(
///     ChatNotification notification,
///     NotiflowNavigator navigator,
///   ) async {
///     // User tap notifikasi dari background — navigate ke chat
///     await navigator.navigateTo('/chat', arguments: notification.chatId);
///   }
///
///   @override
///   Future<void> onLaunch(
///     ChatNotification notification,
///     NotiflowNavigator navigator,
///   ) async {
///     // App di-launch via notifikasi — navigate setelah app siap
///     await Future.delayed(const Duration(milliseconds: 300));
///     await navigator.navigateTo('/chat', arguments: notification.chatId);
///   }
/// }
/// ```
abstract class NotiflowHandler<T extends NotiflowNotification> {
  /// Dipanggil saat notifikasi masuk dan app sedang di **foreground**.
  ///
  /// Rekomendasi: tampilkan in-app banner, snackbar, atau dialog.
  /// Hindari navigasi langsung — user sedang aktif di halaman lain.
  Future<void> onForeground(T notification, NotiflowNavigator navigator);

  /// Dipanggil saat user **tap notifikasi** dari background.
  ///
  /// Rekomendasi: navigate langsung ke halaman yang relevan.
  Future<void> onOpened(T notification, NotiflowNavigator navigator);

  /// Dipanggil saat user tap notifikasi yang me-**launch** app dari terminated.
  ///
  /// Rekomendasi: navigate ke halaman yang relevan, tapi berikan
  /// sedikit delay agar app selesai inisialisasi terlebih dahulu.
  Future<void> onLaunch(T notification, NotiflowNavigator navigator);
}
