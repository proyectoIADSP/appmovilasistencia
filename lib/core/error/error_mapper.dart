import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

class ErrorMapper {
  ErrorMapper._();

  static String messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    if (data is Map && data['title'] is String) {
      return data['title'] as String;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de espera agotado';
      case DioExceptionType.connectionError:
        return 'Sin conexión a internet';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401) return 'Credenciales inválidas o sesión expirada';
        if (code == 403) return 'No tienes permiso para esta acción';
        if (code == 404) return 'Recurso no encontrado';
        return 'Error del servidor (${code ?? 'desconocido'})';
      default:
        return e.message ?? 'Error de red';
    }
  }

  static Exception exceptionFromDio(DioException e) {
    final message = messageFromDio(e);
    final code = e.response?.statusCode;
    if (code == 401) {
      return UnauthorizedException(message);
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException(message);
    }
    return ServerException(message, statusCode: code);
  }

  static Failure failureFromException(Object e) {
    if (e is UnauthorizedException) return AuthFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ServerException) return ServerFailure(e.message);
    if (e is CacheException) return UnexpectedFailure(e.message);
    return UnexpectedFailure(e.toString());
  }
}
