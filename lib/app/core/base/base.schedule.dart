import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:serviceflow/app/core/base/base.model.dart';
import 'package:serviceflow/app/core/base/base.provider.dart';
import 'package:serviceflow/app/core/base/base.repository.dart';

/// BaseSchedule - Abstração para sincronização automática por feature
///
/// Cada módulo herda desta classe e implementa sua própria lógica de sincronização
/// Responsabilidades:
/// - Controle de timer de sincronização
/// - Detecção de conectividade
/// - Coordenação Repository ↔ Provider
/// - Resolução de conflitos
/// - Persistência de estado de sync
abstract class BaseSchedule<E extends BaseModel, R extends BaseRepository<E>,
    P extends BaseProvider<E>> {
  final R repository;
  final P provider;

  Timer? _syncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = false;
  bool _isSyncing = false;

  static const _storage = FlutterSecureStorage();

  BaseSchedule(this.repository, this.provider) {
    _initConnectivityListener();
  }

  /// Configurações de sincronização (sobrescrever se necessário)
  Duration get syncInterval => const Duration(minutes: 5);
  String get featureName; // Nome único da feature (ex: 'usuarios', 'clientes')

  /// Inicia o agendador de sincronização
  Future<void> start() async {
    await _loadSyncState();

    // Timer periódico
    _syncTimer = Timer.periodic(syncInterval, (_) => syncNow());

    // Sync inicial se online
    if (_isOnline) {
      await syncNow();
    }

    _logInfo('Schedule iniciado para $featureName');
  }

  /// Para o agendador
  void stop() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _logInfo('Schedule parado para $featureName');
  }

  /// Força sincronização imediata
  Future<bool> syncNow() async {
    if (_isSyncing || !_isOnline) {
      return false;
    }

    _isSyncing = true;
    _logInfo('Iniciando sincronização de $featureName');

    try {
      // 1. Sincronizar pendências locais para cloud
      final uploadSuccess = await _uploadPendingChanges();

      // 2. Baixar atualizações da cloud
      final downloadSuccess = await _downloadUpdates();

      // 3. Atualizar timestamp de last sync
      if (uploadSuccess && downloadSuccess) {
        await _updateLastSyncTimestamp();
      }

      final success = uploadSuccess && downloadSuccess;
      _logInfo(
          'Sincronização de $featureName ${success ? 'concluída' : 'falhou'}');

      return success;
    } catch (e) {
      _logError('Erro na sincronização de $featureName', e);
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Upload das alterações locais pendentes
  Future<bool> _uploadPendingChanges() async {
    try {
      final pendingEntities = await repository.findAllPendingSync();

      if (pendingEntities.isEmpty) {
        return true;
      }

      int successCount = 0;

      for (final entity in pendingEntities) {
        if (await provider.validateBeforeSync(entity)) {
          final success = await provider.syncToCloud(entity);

          if (success) {
            // Marcar como sincronizado
            entity.isSync = 1;
            await repository.update(entity);
            successCount++;
          }

          // Callback pós-sincronização (pode ser implementado por subclasses)
          // await provider.afterSync(entity, success);
        }
      }

      _logInfo(
          'Upload: $successCount/${pendingEntities.length} registros sincronizados');
      return successCount == pendingEntities.length;
    } catch (e) {
      _logError('Erro no upload', e);
      return false;
    }
  }

  /// Download das atualizações da cloud
  Future<bool> _downloadUpdates() async {
    try {
      // Implementação futura: usar lastSync para filtros temporais
      final remoteEntities = await provider.fetchFromCloud();

      if (remoteEntities.isEmpty) {
        return true;
      }

      int successCount = 0;

      for (final remoteEntity in remoteEntities) {
        final localEntity = await repository.findById(remoteEntity.id!);

        if (localEntity == null) {
          // Nova entidade - inserir
          remoteEntity.isSync = 1;
          await repository.insert(remoteEntity);
          successCount++;
        } else {
          // Entidade existente - verificar conflito
          if (localEntity.isSync == 0) {
            // Conflito: local modificado + remoto modificado
            // Para agora, priorizamos os dados remotos
            // Implementação futura: resolver conflitos de forma mais sofisticada
            remoteEntity.isSync = 1;
            await repository.update(remoteEntity);
            successCount++;
          } else {
            // Sem conflito - atualizar com dados remotos
            remoteEntity.isSync = 1;
            await repository.update(remoteEntity);
            successCount++;
          }
        }
      }

      _logInfo('Download: $successCount registros processados');
      return true;
    } catch (e) {
      _logError('Erro no download', e);
      return false;
    }
  }

  /// Configurar listener de conectividade
  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final result =
            results.isNotEmpty ? results.first : ConnectivityResult.none;
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;

        if (!wasOnline && _isOnline) {
          // Voltou online - sincronizar
          syncNow();
        }
      },
    );

    // Estado inicial
    Connectivity().checkConnectivity().then((result) {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  /// Persistência do estado de sync
  Future<void> _updateLastSyncTimestamp() async {
    final timestamp = DateTime.now().toIso8601String();
    await _storage.write(key: '${featureName}_last_sync', value: timestamp);
  }

  Future<DateTime?> _getLastSyncTimestamp() async {
    final timestampStr = await _storage.read(key: '${featureName}_last_sync');
    return timestampStr != null ? DateTime.parse(timestampStr) : null;
  }

  Future<void> _loadSyncState() async {
    // Carregar estado persistido se necessário
  }

  /// Logging helpers
  void _logInfo(String message) {
    print(
        '[${DateTime.now()}] [${featureName.toUpperCase()}_SCHEDULE] INFO: $message');
  }

  void _logError(String message, dynamic error) {
    print(
        '[${DateTime.now()}] [${featureName.toUpperCase()}_SCHEDULE] ERROR: $message - $error');
  }

  /// Cleanup quando não usado
  void dispose() {
    stop();
  }
}
