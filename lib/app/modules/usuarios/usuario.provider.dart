import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:serviceflow/app/core/http/app_client.dart';
import 'package:serviceflow/app/core/http/interceptors/error_interceptor.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.model.dart';

/// Provider para comunicação com Supabase via REST API
/// Responsável pela serialização e comunicação com a API externa
class UsuarioProvider {
  final AppClient _client = AppClient();

  static const String _endpoint = '/rest/v1/usuarios_profiles'; // Endpoint REST

  // === OPERAÇÕES CRUD NO SUPABASE VIA REST ===

  /// Sincronizar usuário para a nuvem
  Future<bool> syncToCloud(Usuario usuario) async {
    try {
      final data = _toSupabaseFormat(usuario);

      // Fazer UPSERT via REST API
      await _client.post(
        _endpoint,
        data: data,
        options: Options(headers: {
          'Prefer': 'resolution=merge-duplicates',
        }),
      );

      print("✅ Usuário ${usuario.email} sincronizado para nuvem");
      return true;
    } on AppException catch (e) {
      print("❌ Erro ao sincronizar usuário ${usuario.email}: ${e.message}");
      return false;
    } catch (e) {
      print("❌ Erro inesperado ao sincronizar usuário ${usuario.email}: $e");
      return false;
    }
  }

  /// Buscar usuário da nuvem por Supabase ID
  Future<Usuario?> fetchFromCloud(String supabaseId) async {
    try {
      final response = await _client.get(
        _endpoint,
        queryParameters: {
          'supabase_id': 'eq.$supabaseId',
          'select': '*',
          'limit': '1'
        },
      );

      final data = response.data as List;
      if (data.isNotEmpty) {
        return _fromSupabaseFormat(data.first);
      }
      return null;
    } on AppException catch (e) {
      print("❌ Erro ao buscar usuário da nuvem: ${e.message}");
      return null;
    }
  }

  /// Buscar todos usuários do grupo na nuvem
  Future<List<Usuario>> fetchGroupFromCloud(String grupoId) async {
    try {
      final response = await _client.get(
        _endpoint,
        queryParameters: {
          'grupo_id': 'eq.$grupoId',
          'select': '*',
          'order': 'nome_completo.asc'
        },
      );

      final data = response.data as List;
      return data.map<Usuario>((item) => _fromSupabaseFormat(item)).toList();
    } on AppException catch (e) {
      print("❌ Erro ao buscar grupo da nuvem: ${e.message}");
      return [];
    }
  }

  /// Atualizar configurações na nuvem
  Future<bool> updateSettingsInCloud(
      String supabaseId, Map<String, dynamic> configuracoes) async {
    try {
      await _client.patch(
        _endpoint,
        queryParameters: {'supabase_id': 'eq.$supabaseId'},
        data: {
          'configuracoes': json.encode(configuracoes),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      return true;
    } on AppException catch (e) {
      print("❌ Erro ao atualizar configurações na nuvem: ${e.message}");
      return false;
    }
  }

  /// Atualizar último login na nuvem
  Future<bool> updateLastLoginInCloud(
      String supabaseId, DateTime ultimoLogin) async {
    try {
      await _client.patch(
        _endpoint,
        queryParameters: {'supabase_id': 'eq.$supabaseId'},
        data: {
          'ultimo_login': ultimoLogin.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      return true;
    } on AppException catch (e) {
      print("❌ Erro ao atualizar último login na nuvem: ${e.message}");
      return false;
    }
  }
  /// Deletar usuário da nuvem
  Future<bool> deleteFromCloud(String supabaseId) async {
    try {
      await _client.delete(
        _endpoint,
        queryParameters: {'supabase_id': 'eq.$supabaseId'},
      );

      return true;
    } on AppException catch (e) {
      print("❌ Erro ao deletar usuário da nuvem: ${e.message}");
      return false;
    }
  }

  // === VERIFICAÇÕES DE CONECTIVIDADE ===

  /// Verificar se há conexão com a nuvem
  Future<bool> testConnection() async {
    try {
      await _client.testConnection();
      return true;
    } on AppException {
      return false;
    }
  }

  /// Verificar se há conflitos de sincronização
  Future<Map<String, dynamic>> checkConflicts(Usuario localUser) async {
    try {
      final cloudUser = await fetchFromCloud(localUser.supabaseId);

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

  // === OPERAÇÕES EM LOTE ===

  /// Sincronizar múltiplos usuários
  Future<Map<String, bool>> syncMultipleToCloud(List<Usuario> usuarios) async {
    final results = <String, bool>{};

    for (final usuario in usuarios) {
      results[usuario.supabaseId] = await syncToCloud(usuario);
    }

    return results;
  }

  // === MÉTODOS DE CONVERSÃO (Serialização) ===

  /// Converter Usuario para formato do Supabase
  Map<String, dynamic> _toSupabaseFormat(Usuario usuario) {
    return {
      'supabase_id': usuario.supabaseId,
      'email': usuario.email,
      'nome_completo': usuario.nomeCompleto,
      'perfil': usuario.perfil,
      'grupo_id': usuario.grupoId,
      'ultimo_login': usuario.ultimoLogin?.toIso8601String(),
      'configuracoes': usuario.configuracoes != null
          ? json.encode(usuario.configuracoes!)
          : null,
      'ativo': usuario.ativo,
      'created_at': usuario.createdAt?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Converter dados do Supabase para Usuario
  Usuario _fromSupabaseFormat(Map<String, dynamic> data) {
    return Usuario(
      supabaseId: data['supabase_id'] as String,
      email: data['email'] as String,
      nomeCompleto: data['nome_completo'] as String? ?? '',
      perfil: data['perfil'] as String? ?? 'USER',
      grupoId: data['grupo_id'] as String? ?? '',
      ultimoLogin: data['ultimo_login'] != null
          ? DateTime.parse(data['ultimo_login'] as String)
          : null,
      configuracoes: data['configuracoes'] as String?,
      ativo: data['ativo'] as bool? ?? true,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : null,
      isSync: 1, // Dados vindo da nuvem já são considerados sincronizados
    );
  }
}
