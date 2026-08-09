class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Session expired. Please sign in again.', statusCode: 401);
}

class NetworkException extends AppException {
  const NetworkException() : super('No internet connection.');
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Turns any caught error into text safe to show a user. AppExceptions
/// already carry a clean message (set by ApiClient); anything else — a
/// null-check crash, a JSON cast failure, some other unexpected bug — gets
/// a generic fallback instead of leaking Dart/Flutter internals.
String humanizeError(Object error) {
  if (error is AppException) return error.message;
  return 'Something went wrong. Please try again.';
}
