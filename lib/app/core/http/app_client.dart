import 'package:dio/dio.dart';
import 'package:serviceflow/app/core/helpers/app.config.dart';
import 'package:serviceflow/app/core/http/interceptors/auth_interceptor.dart';
import 'package:serviceflow/app/core/http/interceptors/error_interceptor.dart';

/// Cliente HTTP principal da aplicação usando DIO
/// Responsável por todas as requisições REST para APIs externas
class AppClient {
  late final Dio _dio;

  // Singleton
  static final AppClient _instance = AppClient._internal();
  factory AppClient() => _instance;

  AppClient._internal() {
    _dio = Dio(_createBaseOptions());
    _setupInterceptors();
  }

  /// Configurações base do DIO
  BaseOptions _createBaseOptions() {
    return BaseOptions(
      baseUrl: AppConfig.supabaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
    );
  }

  /// Configurar interceptors
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      // Adicionar LogInterceptor apenas em desenvolvimento
      if (AppConfig.isDevelopment)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
    ]);
  }

  // === MÉTODOS HTTP PÚBLICOS ===

  /// GET Request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    }
  }

  /// POST Request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    }
  }

  /// PUT Request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    }
  }

  /// PATCH Request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    }
  }

  /// DELETE Request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _extractAppException(e);
    }
  }

  // === MÉTODOS UTILITÁRIOS ===

  /// Testar conectividade com a API
  Future<bool> testConnection() async {
    try {
      await get('/rest/v1/',
          options: Options(
            receiveTimeout: const Duration(seconds: 5),
          ));
      return true;
    } catch (e) {
      print('🔌 Teste de conexão falhou: $e');
      return false;
    }
  }

  /// Extrair exceção customizada do DioException
  AppException _extractAppException(DioException e) {
    if (e.error is AppException) {
      return e.error as AppException;
    }
    return NetworkException('Erro de rede: ${e.message}');
  }

  /// Configurar token customizado (se necessário)
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Limpar token de autenticação
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
