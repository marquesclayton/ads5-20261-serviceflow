import 'package:flutter/foundation.dart';
import 'package:serviceflow/app/core/logging/log.model.dart';
import 'package:serviceflow/app/core/logging/log.repository.dart';

/// Serviço centralizado de logging para toda aplicação
///
/// Features:
/// - Logging centralizado para providers e schedules
/// - Persistência automática no SQLite
/// - Cleanup automático de logs antigos
/// - Diferentes níveis de log (error, warning, info, debug)
/// - Suporte a metadata estruturada
class LogService {
  static final LogService _instance = LogService._init();
  factory LogService() => _instance;
  LogService._init();

  final LogRepository _repository = LogRepository();
  bool _isInitialized = false;

  /// Inicializar o serviço de log
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // ✅ Garantir que as tabelas existem antes de tentar cleanup
      await _repository.ensureTableExists();

      // Cleanup automático na inicialização (logs mais antigos que 30 dias)
      final deletedCount = await _repository.cleanupOldLogs();
      if (kDebugMode && deletedCount > 0) {
        print('🧹 LogService: Removidos $deletedCount logs antigos');
      }
    } catch (e) {
      // ⚠️ Não deixar que erro no cleanup impeça inicialização
      if (kDebugMode) {
        print('! LogService: Erro no cleanup: $e');
      }
    }

    _isInitialized = true;
    if (kDebugMode) {
      print('✅ LogService inicializado');
    }
  }

  /// Log de erro - nível mais alto de prioridade
  Future<void> error(String source, String operation, dynamic error,
      {Map<String, dynamic>? metadata}) async {
    await _log('error', source, operation, error.toString(),
        stackTrace: error is Error ? error.stackTrace?.toString() : null,
        metadata: metadata);

    // Em desenvolvimento, também imprimir no console para debug
    if (kDebugMode) {
      print('❌ [$source.$operation] $error');
    }
  }

  /// Log de warning - alertas que não impedem funcionamento
  Future<void> warning(String source, String operation, String message,
      {Map<String, dynamic>? metadata}) async {
    await _log('warning', source, operation, message, metadata: metadata);

    if (kDebugMode) {
      print('⚠️ [$source.$operation] $message');
    }
  }

  /// Log de informação - eventos importantes do sistema
  Future<void> info(String source, String operation, String message,
      {Map<String, dynamic>? metadata}) async {
    await _log('info', source, operation, message, metadata: metadata);

    if (kDebugMode) {
      print('ℹ️ [$source.$operation] $message');
    }
  }

  /// Log de debug - apenas em modo desenvolvimento
  Future<void> debug(String source, String operation, String message,
      {Map<String, dynamic>? metadata}) async {
    if (kDebugMode) {
      await _log('debug', source, operation, message, metadata: metadata);
      print('🔍 [$source.$operation] $message');
    }
  }

  /// Método interno para persistir logs
  Future<void> _log(
      String level, String source, String operation, String message,
      {String? stackTrace, Map<String, dynamic>? metadata}) async {
    try {
      final logEntry = LogEntry(
        level: level,
        source: source,
        operation: operation,
        message: message,
        stackTrace: stackTrace,
        metadata: metadata,
        createdAt: DateTime.now(),
      );

      await _repository.insert(logEntry);
    } catch (e) {
      // Falha no logging não deve quebrar a aplicação
      if (kDebugMode) {
        print('💥 Erro ao persistir log: $e');
      }
    }
  }

  /// === MÉTODOS DE CONSULTA ===

  /// Buscar logs recentes por nível
  Future<List<LogEntry>> getRecentLogs({
    String? level,
    Duration period = const Duration(hours: 24),
    int limit = 100,
  }) async {
    if (level != null) {
      return await _repository.findByLevel(level, limit: limit);
    }
    return await _repository.findRecent(period: period, limit: limit);
  }

  /// Buscar apenas erros recentes
  Future<List<LogEntry>> getRecentErrors({
    Duration period = const Duration(hours: 24),
    int limit = 50,
  }) async {
    return await _repository.findRecentErrors(period: period, limit: limit);
  }

  /// Estatísticas de logs
  Future<Map<String, int>> getLogStats({
    Duration period = const Duration(days: 7),
  }) async {
    return await _repository.getLogStats(period: period);
  }

  /// Buscar logs por fonte específica
  Future<List<LogEntry>> getLogsBySource(String source,
      {int limit = 100}) async {
    return await _repository.findBySource(source, limit: limit);
  }

  /// Buscar logs por termo
  Future<List<LogEntry>> searchLogs(String searchTerm,
      {int limit = 100}) async {
    return await _repository.searchLogs(searchTerm, limit: limit);
  }

  /// === MÉTODOS DE MANUTENÇÃO ===

  /// Cleanup manual de logs antigos
  Future<int> cleanupOldLogs(
      {Duration keepPeriod = const Duration(days: 30)}) async {
    return await _repository.cleanupOldLogs(keepPeriod: keepPeriod);
  }

  /// Verificar se há muitos erros recentes (health check)
  Future<bool> hasRecentErrors({
    Duration period = const Duration(hours: 1),
    int threshold = 10,
  }) async {
    final errors = await getRecentErrors(period: period, limit: threshold + 1);
    return errors.length >= threshold;
  }

  /// === HELPERS PARA PROVIDERS ===

  /// Handler padronizado para erros de providers
  Future<void> handleProviderError(
      String providerName, String operation, dynamic error,
      {Map<String, dynamic>? context}) async {
    final metadata = <String, dynamic>{
      'provider': providerName,
      'timestamp': DateTime.now().toIso8601String(),
      if (context != null) ...context,
    };

    await this
        .error('${providerName}Provider', operation, error, metadata: metadata);
  }

  /// Handler padronizado para operações de sincronização
  Future<void> logSyncOperation(String source, String operation, bool success,
      {int? recordCount, String? details}) async {
    final metadata = <String, dynamic>{
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
      if (recordCount != null) 'recordCount': recordCount,
      if (details != null) 'details': details,
    };

    if (success) {
      await info(source, operation,
          'Sincronização concluída${recordCount != null ? " ($recordCount registros)" : ""}',
          metadata: metadata);
    } else {
      await warning(source, operation,
          'Sincronização falhou${details != null ? ": $details" : ""}',
          metadata: metadata);
    }
  }
}
