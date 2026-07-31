abstract final class Exceptions {
  Exceptions._();
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (statusCode: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class DatabaseException implements Exception {
  final String message;
  final int? errorCode;
  DatabaseException({required this.message, this.errorCode});

  @override
  String toString() => 'DatabaseException: $message (errorCode: $errorCode)';
}

class NetworkException implements Exception {
  final String message;
  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException({required this.message});

  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException({required this.message});

  @override
  String toString() => 'NotFoundException: $message';
}
