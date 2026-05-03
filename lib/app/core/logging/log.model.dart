import 'package:serviceflow/app/core/base/base.model.dart';

/// Modelo para armazenar logs do sistema
///
/// Usado para:
/// - Logs de erro dos providers
/// - Logs de sincronização
/// - Logs de operações críticas
/// - Debugging e auditoria
class LogEntry extends BaseModel {
  final String level; // 'error', 'warning', 'info', 'debug'
  final String source; // 'UsuarioProvider', 'ClienteProvider', etc.
  final String operation; // 'syncToCloud', 'login', etc.
  final String message;
  final String? stackTrace;
  final Map<String, dynamic>? metadata;

  LogEntry({
    super.id,
    required this.level,
    required this.source,
    required this.operation,
    required this.message,
    this.stackTrace,
    this.metadata,
    super.isSync = 0, // Logs não precisam ser sincronizados por padrão
    super.createdAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'level': level,
      'source': source,
      'operation': operation,
      'message': message,
      'stack_trace': stackTrace,
      'metadata': metadata != null ? _encodeMetadata(metadata!) : null,
      'is_sync': isSync,
      'created_at': createdAt?.millisecondsSinceEpoch,
    };
  }

  LogEntry fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id']?.toInt(),
      level: map['level'] ?? 'info',
      source: map['source'] ?? '',
      operation: map['operation'] ?? '',
      message: map['message'] ?? '',
      stackTrace: map['stack_trace'],
      metadata:
          map['metadata'] != null ? _decodeMetadata(map['metadata']) : null,
      isSync: map['is_sync']?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          : null,
    );
  }

  LogEntry copyWith({
    int? id,
    String? level,
    String? source,
    String? operation,
    String? message,
    String? stackTrace,
    Map<String, dynamic>? metadata,
    int? isSync,
    DateTime? createdAt,
  }) {
    return LogEntry(
      id: id ?? this.id,
      level: level ?? this.level,
      source: source ?? this.source,
      operation: operation ?? this.operation,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      metadata: metadata ?? this.metadata,
      isSync: isSync ?? this.isSync,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Helpers para serialização de metadata
  String _encodeMetadata(Map<String, dynamic> metadata) {
    try {
      return metadata.toString(); // Simples para começar
    } catch (e) {
      return 'Error encoding metadata: $e';
    }
  }

  Map<String, dynamic>? _decodeMetadata(String metadata) {
    try {
      // Por enquanto, implementação simples
      return {'raw': metadata};
    } catch (e) {
      return {'error': 'Failed to decode metadata'};
    }
  }

  /// Factories para diferentes níveis de log
  static LogEntry error(String source, String operation, String message,
      {String? stackTrace, Map<String, dynamic>? metadata}) {
    return LogEntry(
      level: 'error',
      source: source,
      operation: operation,
      message: message,
      stackTrace: stackTrace,
      metadata: metadata,
      createdAt: DateTime.now(),
    );
  }

  static LogEntry warning(String source, String operation, String message,
      {Map<String, dynamic>? metadata}) {
    return LogEntry(
      level: 'warning',
      source: source,
      operation: operation,
      message: message,
      metadata: metadata,
      createdAt: DateTime.now(),
    );
  }

  static LogEntry info(String source, String operation, String message,
      {Map<String, dynamic>? metadata}) {
    return LogEntry(
      level: 'info',
      source: source,
      operation: operation,
      message: message,
      metadata: metadata,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return '[$level] $source.$operation: $message';
  }
}
