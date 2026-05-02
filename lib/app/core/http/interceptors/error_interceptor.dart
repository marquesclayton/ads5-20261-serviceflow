import 'package:dio/dio.dart';

/// Exceções customizadas para a aplicação
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, this.statusCode);
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message, null);
}

class ServerException extends AppException {
  const ServerException(String message, int statusCode)
      : super(message, statusCode);
}

class AuthenticationException extends AppException {
  const AuthenticationException(String message) : super(message, 401);
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException(String message, this.errors) : super(message, 422);
}

/// Interceptor para tratamento de erros HTTP
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appException = const NetworkException(
            'Timeout na conexão. Verifique sua internet.');
        break;

      case DioExceptionType.connectionError:
        appException =
            const NetworkException('Erro de conexão. Verifique sua internet.');
        break;

      case DioExceptionType.badResponse:
        appException = _handleBadResponse(err);
        break;

      case DioExceptionType.cancel:
        appException = const NetworkException('Requisição cancelada.');
        break;

      case DioExceptionType.unknown:
      default:
        appException = NetworkException('Erro desconhecido: ${err.message}');
        break;
    }

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: appException,
      type: err.type,
    ));
  }

  AppException _handleBadResponse(DioException err) {
    final response = err.response;
    final statusCode = response?.statusCode ?? 0;

    switch (statusCode) {
      case 400:
        return ServerException('Requisição inválida', statusCode);

      case 401:
        return const AuthenticationException(
            'Token de autenticação inválido ou expirado');

      case 403:
        return ServerException('Acesso negado', statusCode);

      case 404:
        return ServerException('Recurso não encontrado', statusCode);

      case 422:
        final data = response?.data;
        Map<String, List<String>>? errors;

        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          errors = Map<String, List<String>>.from(
            data['errors']
                .map((key, value) => MapEntry(key, List<String>.from(value))),
          );
        }

        return ValidationException('Dados inválidos', errors);

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException('Erro interno do servidor', statusCode);

      default:
        final message = response?.data?['message'] ?? 'Erro HTTP $statusCode';
        return ServerException(message, statusCode);
    }
  }
}
