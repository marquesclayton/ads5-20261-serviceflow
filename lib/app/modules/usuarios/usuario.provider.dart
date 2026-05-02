import 'package:serviceflow/app/core/base/base.provider.dart';
import 'package:serviceflow/app/core/http/app_client.dart';
import 'package:serviceflow/app/core/http/interceptors/error_interceptor.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.model.dart';

/// Provider para comunicação com Supabase via REST API
/// Responsável pela serialização e comunicação com a API externa
class UsuarioProvider extends BaseProvider<Usuario> {
  
  late AppClient _client;

  UsuarioProvider() {
    _client = AppClient();
  }

  @override
  String get endpoint => '/rest/v1/usuarios_profiles'; // Endpoint REST Supabase

  @override
  Map<String, dynamic> toExternalFormat(Usuario usuario) {
    return {
      'id': usuario.supabaseId, // Usar supabaseId como ID externo
      'email': usuario.email,
      'nome_completo': usuario.nomeCompleto,
      'grupo_id': usuario.grupoId,
      'perfil': usuario.perfil,
      'ultimo_login': usuario.ultimoLogin?.toIso8601String(),
      'avatar_local_path': usuario.avatarLocalPath,
      'configuracoes': usuario.configuracoes,
      'ativo': usuario.ativo,
      'updated_at': DateTime.now().toIso8601String(), // Timestamp para controle
    };
  }

  @override
  Usuario fromExternalFormat(Map<String, dynamic> data) {
    return Usuario(
      id: data['id'], // ID local será setado pelo repository
      supabaseId: data['id'], // ID do Supabase
      email: data['email'],
      nomeCompleto: data['nome_completo'],
      grupoId: data['grupo_id'],
      perfil: data['perfil'] ?? 'tecnico',
      ultimoLogin: data['ultimo_login'] != null 
          ? DateTime.parse(data['ultimo_login']) 
          : null,
      avatarLocalPath: data['avatar_local_path'],
      configuracoes: data['configuracoes'],
      ativo: data['ativo'] ?? true,
      isSync: 1, // Dados vindos da API estão sincronizados
      createdAt: data['created_at'] != null 
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
    );
  }

  /// Método específico para login
  Future<Usuario?> login(String email, String password) async {
    try {
      // Login via Supabase Auth
      final response = await _client.post('/auth/v1/token', data: {
        'email': email,
        'password': password,
      });

      if (response.data['access_token'] != null) {
        // Buscar dados completos do usuário
        final userResponse = await _client.get(
          '$endpoint?email=eq.$email&select=*',
        );

        if (userResponse.data is List && 
            (userResponse.data as List).isNotEmpty) {
          final userData = (userResponse.data as List).first;
          return fromExternalFormat(userData);
        }
      }

      return null;
    } catch (e) {
      _handleError('login', e);
      return null;
    }
  }

  /// Método específico para logout
  Future<bool> logout() async {
    try {
      await _client.post('/auth/v1/logout');
      return true;
    } catch (e) {
      _handleError('logout', e);
      return false;
    }
  }

  /// Validações específicas antes da sincronização
  @override
  Future<bool> validateBeforeSync(Usuario usuario) async {
    // Validações específicas para usuário
    if (usuario.email.isEmpty || usuario.nomeCompleto.isEmpty) {
      _handleError('validateBeforeSync', 'Dados obrigatórios faltando');
      return false;
    }

    // Verificar se o supabaseId existe (necessário para UPDATE)
    if (usuario.id != null && usuario.supabaseId.isEmpty) {
      _handleError('validateBeforeSync', 'supabaseId obrigatório para atualização');
      return false;
    }

    return true;
  }

  // === MÉTODOS ESPECÍFICOS PARA USUÁRIOS ===

  /// Buscar usuário por Supabase ID
  Future<Usuario?> fetchUserFromCloud(String supabaseId) async {
    try {
      final response = await _client.get(
        '$endpoint?supabase_id=eq.$supabaseId&select=*&limit=1',
      );

      final data = response.data as List;
      if (data.isNotEmpty) {
        return fromExternalFormat(data.first);
      }
      return null;
    } on AppException catch (e) {
      print("❌ Erro ao buscar usuário da nuvem: ${e.message}");
      return null;
    }
  }

  /// Verificar se há conflitos de sincronização
  Future<Map<String, dynamic>> checkConflicts(Usuario localUser) async {
    try {
      final cloudUser = await fetchUserFromCloud(localUser.supabaseId);

      if (cloudUser == null) {
        return {'hasConflict': false, 'type': 'not_exists'};
      }

      // Verificar se versão da nuvem é mais recente
      final localUpdate = localUser.createdAt ?? DateTime(2000);
      final cloudUpdate = cloudUser.createdAt ?? DateTime(2000);

      if (cloudUpdate.isAfter(localUpdate)) {
        return {
          'hasConflict': true,
          'type': 'cloud_newer',
          'cloudUser': cloudUser.toMap(),
        };
      }

      return {'hasConflict': false, 'type': 'local_newer'};
    } on AppException catch (e) {
      return {'hasConflict': false, 'type': 'error', 'error': e.message};
    }
  }

  /// Verificar se há conexão com a nuvem
  Future<bool> testConnection() async {
    try {
      await _client.testConnection();
      return true;
    } on AppException {
      return false;
    }
  }

  void _handleError(String operation, dynamic error) {
    print('[UsuarioProvider] Error in $operation: $error');
  }
}
