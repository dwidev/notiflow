/// Exception yang dilempar saat parsing notification gagal.
class NotiflowParseException implements Exception {
  final String message;
  final Map<String, dynamic> payload;
  final Object? cause;

  const NotiflowParseException({
    required this.message,
    required this.payload,
    this.cause,
  });

  @override
  String toString() =>
      'NotiflowParseException: $message\n'
      'Payload: $payload'
      '${cause != null ? '\nCause: $cause' : ''}';
}
