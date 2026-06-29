/// Exception saat [dispatch] dipanggil sebelum navigator diset.
class NotiflowNavigatorNotSetException implements Exception {
  const NotiflowNavigatorNotSetException();

  @override
  String toString() =>
      'NotiflowNavigatorNotSetException: call setNavigator() '
      'before dispatch(). Make sure the navigation adapter'
      'is set up in main() after runApp()';
}
