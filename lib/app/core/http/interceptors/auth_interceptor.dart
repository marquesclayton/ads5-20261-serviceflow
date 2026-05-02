import 'package:dio/dio.dart';
import 'package:serviceflow/app/core/helpers/app.config.dart';

/// Interceptor para tratamento de autenticação e headers
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Adicionar headers padrão
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    // Adicionar token de autenticação do Supabase
    final token = AppConfig.supabaseKey;
    if (token.isNotEmpty) {
      options.headers['apikey'] = token;
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Adicionar User-Agent customizado
    options.headers['User-Agent'] = 'ServiceFlow/1.0';

    print('🌐 ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ ${response.statusCode} ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
        '❌ ${err.response?.statusCode} ${err.requestOptions.path}: ${err.message}');
    super.onError(err, handler);
  }
}
