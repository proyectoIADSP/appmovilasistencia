class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'Sin conexión a internet']);

  final String message;

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Sesión expirada']);

  final String message;

  @override
  String toString() => message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Error de almacenamiento local']);

  final String message;

  @override
  String toString() => message;
}
