import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/core/logging/log.model.dart';

/// Repository para gerenciamento de logs do sistema
///
/// Responsabilidades:
/// - Armazenar logs no SQLite
/// - Cleanup automático de logs antigos
/// - Buscar logs por filtros (nível, fonte, período)
/// - Estatísticas de erros
class LogRepository extends BaseRepository<LogEntry> {
  static final LogRepository _instance = LogRepository._init();
  factory LogRepository() => _instance;
  LogRepository._init();

  @override
  String get tableName => 'system_logs';

  @override
  LogEntry fromMap(Map<String, dynamic> map) {
    final entry =
        LogEntry(level: 'info', source: '', operation: '', message: '');
    return entry.fromMap(map);
  }

  /// Buscar logs por nível (error, warning, info, debug)
  Future<List<LogEntry>> findByLevel(String level, {int limit = 100}) async {
    final db = await getConnection();
    final maps = await db.query(
      tableName,
      where: 'level = ?',
      whereArgs: [level],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  /// Buscar logs por fonte (UsuarioProvider, ClienteProvider, etc.)
  Future<List<LogEntry>> findBySource(String source, {int limit = 100}) async {
    final db = await getConnection();
    final maps = await db.query(
      tableName,
      where: 'source = ?',
      whereArgs: [source],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  /// Buscar logs recentes (últimas 24h por padrão)
  Future<List<LogEntry>> findRecent({
    Duration period = const Duration(hours: 24),
    int limit = 100,
  }) async {
    final db = await getConnection();
    final cutoffTime = DateTime.now().subtract(period);

    final maps = await db.query(
      tableName,
      where: 'created_at >= ?',
      whereArgs: [cutoffTime.millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  /// Buscar apenas logs de erro recentes
  Future<List<LogEntry>> findRecentErrors({
    Duration period = const Duration(hours: 24),
    int limit = 50,
  }) async {
    final db = await getConnection();
    final cutoffTime = DateTime.now().subtract(period);

    final maps = await db.query(
      tableName,
      where: 'level = ? AND created_at >= ?',
      whereArgs: ['error', cutoffTime.millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  /// Estatísticas de logs por período
  Future<Map<String, int>> getLogStats({
    Duration period = const Duration(days: 7),
  }) async {
    final db = await getConnection();
    final cutoffTime = DateTime.now().subtract(period);

    final result = await db.rawQuery('''
      SELECT level, COUNT(*) as count
      FROM $tableName 
      WHERE created_at >= ?
      GROUP BY level
    ''', [cutoffTime.millisecondsSinceEpoch]);

    final stats = <String, int>{};
    for (final row in result) {
      stats[row['level'] as String] = row['count'] as int;
    }

    return stats;
  }

  /// Cleanup automático de logs antigos
  /// Remove logs mais antigos que o período especificado
  Future<int> cleanupOldLogs({
    Duration keepPeriod = const Duration(days: 30),
  }) async {
    final db = await getConnection();
    final cutoffTime = DateTime.now().subtract(keepPeriod);

    return await db.delete(
      tableName,
      where: 'created_at < ?',
      whereArgs: [cutoffTime.millisecondsSinceEpoch],
    );
  }

  /// Método conveniente para log rápido de erro
  Future<void> logError(String source, String operation, dynamic error,
      {Map<String, dynamic>? metadata}) async {
    final logEntry = LogEntry.error(
      source,
      operation,
      error.toString(),
      stackTrace: error is Error ? error.stackTrace?.toString() : null,
      metadata: metadata,
    );

    await insert(logEntry);
  }

  /// Método conveniente para log de warning
  Future<void> logWarning(String source, String operation, String message,
      {Map<String, dynamic>? metadata}) async {
    final logEntry =
        LogEntry.warning(source, operation, message, metadata: metadata);
    await insert(logEntry);
  }

  /// Método conveniente para log de info
  Future<void> logInfo(String source, String operation, String message,
      {Map<String, dynamic>? metadata}) async {
    final logEntry =
        LogEntry.info(source, operation, message, metadata: metadata);
    await insert(logEntry);
  }

  /// Buscar logs por pattern na mensagem
  Future<List<LogEntry>> searchLogs(String searchTerm,
      {int limit = 100}) async {
    final db = await getConnection();
    final maps = await db.query(
      tableName,
      where: 'message LIKE ? OR operation LIKE ?',
      whereArgs: ['%$searchTerm%', '%$searchTerm%'],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => fromMap(map)).toList();
  }
}
