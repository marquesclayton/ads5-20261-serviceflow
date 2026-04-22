import 'package:dio/dio.dart';
import 'package:serviceflow/app/core/helpers/app.config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'base.model.dart';

abstract class BaseRepository<E extends BaseModel> {
  late final Dio dio;
  final String path; // Ex: '/clientes' ou '/ordens_servico'

  BaseRepository({required this.path}) {
    dio = Dio(BaseOptions(
      baseUrl: "${AppConfig.supabaseUrl}/rest/v1",
      headers: {
        'apikey': AppConfig.supabaseKey,
        'Prefer':
            'return=representation', // Faz o Supabase retornar o objeto após salvar
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // AULA PARA OS ALUNOS:
        // Aqui interceptamos a requisição para injetar o Token JWT do usuário logado
        final session = Supabase.instance.client.auth.currentSession;
        final token = session?.accessToken;

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        print(
            "--- [DIO INTERCEPTOR] Enviando ${options.method} para ${options.path} ---");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            "--- [DIO INTERCEPTOR] Resposta recebida: ${response.statusCode} ---");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("--- [DIO INTERCEPTOR] Erro: ${e.message} ---");
        return handler.next(e);
      },
    ));
  }

  // Exemplo de método comum: Buscar todos
  Future<List<dynamic>> getAll() async {
    final response = await dio.get(path);
    return response.data;
  }
}
