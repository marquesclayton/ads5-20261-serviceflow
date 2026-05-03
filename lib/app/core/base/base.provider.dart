import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.model.dart';
import 'package:serviceflow/app/core/http/app_client.dart';
import 'package:serviceflow/app/core/logging/log.service.dart';

/// BaseProvider - Abstração para comunicação com APIs externas
///
/// Responsabilidades:
/// - Comunicação HTTP via AppClient
/// - Serialização/Deserialização para formato da API externa
/// - Tratamento de erros padronizado
/// - Métodos CRUD para sincronização com API externa
abstract class BaseProvider<E extends BaseModel> {
  final AppClient _client = AppClient();
  final LogService _logger = LogService();

  /// Nome da classe para logging (usado automaticamente)
  String get _className => runtimeType.toString();

  /// Endpoint base para a entidade (ex: '/usuarios', '/clientes')
  String get endpoint;

  /// Converte entidade para formato da API externa (ex: Supabase)
  Map<String, dynamic> toExternalFormat(E entity);

  /// Converte dados da API externa para entidade local
  E fromExternalFormat(Map<String, dynamic> data);

  /// Sincroniza uma entidade local para a API externa
  Future<bool> syncToCloud(E entity) async {
    try {
      final data = toExternalFormat(entity);

      if (entity.id == null) {
        // CREATE na API externa
        await _client.post(endpoint, data: data);
      } else {
        // UPDATE na API externa
        await _client.put('$endpoint/${entity.id}', data: data);
      }

      return true;
    } catch (e) {
      handleError('syncToCloud', e);
      return false;
    }
  }

  /// Busca entidades da API externa
  Future<List<E>> fetchFromCloud({DateTime? lastSync}) async {
    try {
      final queryParams = lastSync != null
          ? '?updated_at=gte.${lastSync.toIso8601String()}'
          : '';

      final response = await _client.get('$endpoint$queryParams');

      if (response.data is List) {
        return (response.data as List)
            .map((item) => fromExternalFormat(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      handleError('fetchFromCloud', e);
      return [];
    }
  }

  /// Deleta entidade na API externa
  Future<bool> deleteFromCloud(int id) async {
    try {
      await _client.delete('$endpoint/$id');
      return true;
    } catch (e) {
      handleError('deleteFromCloud', e);
      return false;
    }
  }

  /// Tratamento centralizado de erros com logging estruturado
  @protected
  void handleError(String operation, dynamic error) {
    _logger.handleProviderError(_className, operation, error);
  }

  /// Hook para validações específicas antes de sincronizar
  Future<bool> validateBeforeSync(E entity) async => true;

  /// Hook para processamento pós-sincronização
  Future<void> afterSync(E entity, bool success) async {}

  /// Hook para tratamento de conflitos
  Future<E?> resolveConflict(E local, E remote) async {
    // Strategy padrão: timestamp mais recente
    final localUpdated =
        local.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final remoteUpdated =
        remote.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    return localUpdated.isAfter(remoteUpdated) ? local : remote;
  }
}
