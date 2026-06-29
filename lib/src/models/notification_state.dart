/// State aplikasi saat notifikasi diterima atau dibuka.
enum NotificationState {
  /// App sedang aktif di foreground.
  foreground,

  /// User tap notifikasi saat app di background.
  background,

  /// User tap notifikasi saat app dalam kondisi terminated.
  launch,
}
