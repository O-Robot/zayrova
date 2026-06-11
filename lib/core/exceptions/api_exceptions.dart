class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }

    return '$message (status code: $statusCode)';
  }
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.statusCode});
}

class ParsingException extends AppException {
  const ParsingException(super.message, {super.statusCode});
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.statusCode});
}
