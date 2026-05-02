import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.model.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.provider.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.repository.dart';

/// Agendador (Schedule) - Background Worker para sincronização offline-first
/// Responsável por sincronizar dados locais (SQLite) com a nuvem (Supabase)
class UsuarioSchedule {
  final UsuarioRepository _repository = UsuarioRepository();
  final UsuarioProvider _provider = UsuarioProvider();
  final Connectivity _connectivity = Connectivity();

  // Controle de execução
  Timer? _syncTimer;
  bool _isRunning = false;
  bool _isSyncing = false;

  // Configurações
  static const Duration _syncInterval =
      Duration(minutes: 5); // Intervalo de sincronização

  // Singleton
  static final UsuarioSchedule _instance = UsuarioSchedule._init();
  factory UsuarioSchedule() => _instance;
  UsuarioSchedule._init();

  // === CONTROLE DO AGENDADOR ===

  /// Iniciar o agendador de sincronização
  void start() {
    if (_isRunning) {
      print("Agendador já está executando");
      return;
    }

    _isRunning = true;
    _syncTimer = Timer.periodic(_syncInterval, (_) => _performSync());

    print("Agendador de usuários iniciado (intervalo: $_syncInterval)");

    // Executar primeira sincronização imediatamente
    _performSync();
  }

  /// Parar o agendador
  void stop() {
    if (!_isRunning) return;

    _syncTimer?.cancel();
    _isRunning = false;
    _isSyncing = false;

    print("Agendador de usuários parado");
  }

  /// Forçar sincronização imediata
  Future<Map<String, dynamic>> syncNow() async {
    return await _performSync();
  }

  // === LÓGICA DE SINCRONIZAÇÃO ===

  /// Executar ciclo de sincronização
  Future<Map<String, dynamic>> _performSync() async {
    if (_isSyncing) {
      print("⏳ Sincronização já em andamento...");
      return {'status': 'already_running'};
    }

    _isSyncing = true;
    final startTime = DateTime.now();

    try {
      print("Iniciando sincronização de usuários...");

      // 1. Verificar conectividade
      final hasConnection = await _checkConnection();
      if (!hasConnection) {
        print("Sem conexão - sincronização adiada");
        return {'status': 'no_connection'};
      }

      // 2. Buscar dados pendentes de sincronização
      final pendingUsers = await _repository.findNotSynced();
      if (pendingUsers.isEmpty) {
        print("Nenhum usuário pendente de sincronização");
        return {'status': 'nothing_to_sync'};
      }

      // 3. Processar cada usuário pendente
      final results = await _syncPendingUsers(pendingUsers);

      // 4. Calcular estatísticas
      final duration = DateTime.now().difference(startTime);
      final stats = _calculateStats(results);

      print(
          "Sincronização concluída em ${duration.inSeconds}s - ${stats['success']}/${stats['total']} usuários");

      return {
        'status': 'completed',
        'duration_seconds': duration.inSeconds,
        'stats': stats,
        'results': results,
      };
    } catch (e) {
      print("Erro na sincronização: $e");
      return {'status': 'error', 'error': e.toString()};
    } finally {
      _isSyncing = false;
    }
  }

  /// Sincronizar lista de usuários pendentes
  Future<List<Map<String, dynamic>>> _syncPendingUsers(
      List<Usuario> pendingUsers) async {
    final results = <Map<String, dynamic>>[];

    for (final usuario in pendingUsers) {
      final result = await _syncSingleUser(usuario);
      results.add(result);

      // Pequeno delay entre sincronizações para não sobrecarregar
      if (results.length < pendingUsers.length) {
        await Future.delayed(Duration(milliseconds: 500));
      }
    }

    return results;
  }

  /// Sincronizar um único usuário
  Future<Map<String, dynamic>> _syncSingleUser(Usuario usuario) async {
    final userInfo = "${usuario.email} (ID: ${usuario.id})";

    try {
      // 1. Verificar conflitos
      final conflictCheck = await _provider.checkConflicts(usuario);

      if (conflictCheck['hasConflict'] == true) {
        return await _resolveConflict(usuario, conflictCheck);
      }

      // 2. Tentar sincronizar para a nuvem
      final success = await _provider.syncToCloud(usuario);

      if (success) {
        // 3. Marcar como sincronizado localmente
        await _repository.markAsSynced(usuario.id!);

        print("$userInfo sincronizado com sucesso");
        return {
          'user_id': usuario.id,
          'email': usuario.email,
          'status': 'success',
          'action': 'synced_to_cloud',
        };
      } else {
        print("$userInfo falhou na sincronização");
        return {
          'user_id': usuario.id,
          'email': usuario.email,
          'status': 'failed',
          'error': 'sync_failed',
        };
      }
    } catch (e) {
      print("$userInfo erro na sincronização: $e");
      return {
        'user_id': usuario.id,
        'email': usuario.email,
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// Resolver conflitos de sincronização
  Future<Map<String, dynamic>> _resolveConflict(
      Usuario localUser, Map<String, dynamic> conflictInfo) async {
    final userInfo = "${localUser.email} (ID: ${localUser.id})";

    try {
      switch (conflictInfo['type']) {
        case 'cloud_newer':
          // Nuvem mais recente - atualizar local
          final cloudUserData =
              conflictInfo['cloudUser'] as Map<String, dynamic>;
          final cloudUser = Usuario.fromMap(cloudUserData);

          await _repository
              .update(cloudUser.copyWith(id: localUser.id, isSync: 1));

          print("$userInfo atualizado com versão da nuvem");
          return {
            'user_id': localUser.id,
            'email': localUser.email,
            'status': 'success',
            'action': 'updated_from_cloud',
          };

        case 'local_newer':
        default:
          // Local mais recente - forçar sincronização
          await _provider.syncToCloud(localUser);
          await _repository.markAsSynced(localUser.id!);

          print("$userInfo sincronizado forçadamente (local mais recente)");
          return {
            'user_id': localUser.id,
            'email': localUser.email,
            'status': 'success',
            'action': 'forced_sync_to_cloud',
          };
      }
    } catch (e) {
      print("$userInfo erro ao resolver conflito: $e");
      return {
        'user_id': localUser.id,
        'email': localUser.email,
        'status': 'error',
        'error': 'conflict_resolution_failed',
      };
    }
  }

  // === MÉTODOS AUXILIARES ===

  /// Verificar conectividade com internet e Supabase
  Future<bool> _checkConnection() async {
    try {
      // 1. Verificar conectividade de rede
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // 2. Testar conexão específica com Supabase
      return await _provider.testConnection();
    } catch (e) {
      print("Erro ao verificar conexão: $e");
      return false;
    }
  }

  /// Calcular estatísticas dos resultados
  Map<String, int> _calculateStats(List<Map<String, dynamic>> results) {
    return {
      'total': results.length,
      'success': results.where((r) => r['status'] == 'success').length,
      'failed': results.where((r) => r['status'] == 'failed').length,
      'error': results.where((r) => r['status'] == 'error').length,
    };
  }

  // === MÉTODOS PÚBLICOS DE MONITORAMENTO ===

  /// Verificar status do agendador
  Map<String, dynamic> getStatus() {
    return {
      'is_running': _isRunning,
      'is_syncing': _isSyncing,
      'next_sync': _isRunning
          ? DateTime.now().add(_syncInterval).toIso8601String()
          : null,
      'sync_interval_minutes': _syncInterval.inMinutes,
    };
  }

  /// Obter estatísticas de sincronização
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final pendingCount = (await _repository.findNotSynced()).length;
      final totalCount = (await _repository.findAll()).length;
      final hasConnection = await _checkConnection();

      return {
        'pending_sync': pendingCount,
        'total_users': totalCount,
        'sync_percentage': totalCount > 0
            ? ((totalCount - pendingCount) / totalCount * 100).round()
            : 100,
        'has_connection': hasConnection,
        'scheduler_status': getStatus(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // === MÉTODOS DE CONFIGURAÇÃO ===

  /// Configurar intervalo de sincronização (apenas para testes)
  void setCustomInterval(Duration interval) {
    if (_isRunning) {
      stop();
      // Reiniciar com novo intervalo seria complexo
      print("⚠️ Pare o agendador antes de alterar o intervalo");
    }
  }

  /// Limpar todos os dados não sincronizados (emergência)
  Future<void> clearPendingSync() async {
    try {
      await _repository.markAllAsSynced();
      print("Todos os usuários marcados como sincronizados");
    } catch (e) {
      print("Erro ao limpar pendências: $e");
    }
  }
}
