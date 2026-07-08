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
