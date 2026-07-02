abstract interface class RuntimeException implements Exception {
  RuntimeException();
}

class AlreadyInitializedException implements RuntimeException {
  const AlreadyInitializedException();

  @override
  String toString() =>
      'Notiflow has already been initialize'
      'call Notiflow.initialize() only once';
}
