import 'package:serviceflow/app/core/base/base.model.dart';

class Usuario extends BaseModel {
  final String supabaseId; // ID do Supabase (UUID)
  final String email;
  final String nomeCompleto;
  final String grupoId;
  final String perfil; // 'admin', 'tecnico', etc.
  final DateTime? ultimoLogin;
  final String? avatarLocalPath;
  final String? configuracoes; // JSON das configurações do usuário

  Usuario({
    int? id,
    DateTime? createdAt,
    int isSync = 1, // Usuários começam sincronizados (vêm do Supabase)
    bool ativo = true, // Por padrão ativo
    required this.supabaseId,
    required this.email,
    required this.nomeCompleto,
    required this.grupoId,
    this.perfil = 'tecnico',
    this.ultimoLogin,
    this.avatarLocalPath,
    this.configuracoes,
  }) : super(id: id, createdAt: createdAt, isSync: isSync, ativo: ativo);

  // Construtor a partir do Map (SQLite)
  Usuario.fromMap(Map<String, dynamic> map)
      : supabaseId = map['supabase_id'] as String,
        email = map['email'] as String,
        nomeCompleto = map['nome_completo'] as String,
        grupoId = map['grupo_id'] as String,
        perfil = map['perfil'] as String? ?? 'tecnico',
        ultimoLogin = map['ultimo_login'] != null
            ? DateTime.tryParse(map['ultimo_login'].toString())
            : null,
        avatarLocalPath = map['avatar_local_path'] as String?,
        configuracoes = map['configuracoes'] as String?,
        super.fromMap(map);

  // Converter para Map (SQLite)
  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    return {
      ...baseMap,
      'supabase_id': supabaseId,
      'email': email,
      'nome_completo': nomeCompleto,
      'grupo_id': grupoId,
      'perfil': perfil,
      'ultimo_login': ultimoLogin?.toIso8601String(),
      'avatar_local_path': avatarLocalPath,
      'configuracoes': configuracoes,
    };
  }

  // Construtor a partir dos dados do Supabase
  factory Usuario.fromSupabase(Map<String, dynamic> supabaseData) {
    return Usuario(
      supabaseId: supabaseData['id'] as String,
      email: supabaseData['email'] as String,
      nomeCompleto:
          supabaseData['user_metadata']?['nome_completo'] as String? ?? '',
      grupoId:
          supabaseData['user_metadata']?['group_id'] as String? ?? 'SF-GP-01',
      perfil: supabaseData['user_metadata']?['perfil'] as String? ?? 'tecnico',
      ultimoLogin: DateTime.now(),
    );
  }

  // Converter para JSON do Supabase
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': supabaseId,
      'email': email,
      'user_metadata': {
        'nome_completo': nomeCompleto,
        'group_id': grupoId,
        'perfil': perfil,
      },
    };
  }

  // Criar cópia com novos valores
  Usuario copyWith({
    int? id,
    DateTime? createdAt,
    int? isSync,
    bool? ativo,
    String? supabaseId,
    String? email,
    String? nomeCompleto,
    String? grupoId,
    String? perfil,
    DateTime? ultimoLogin,
    String? avatarLocalPath,
    String? configuracoes,
  }) {
    return Usuario(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isSync: isSync ?? this.isSync,
      ativo: ativo ?? this.ativo,
      supabaseId: supabaseId ?? this.supabaseId,
      email: email ?? this.email,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      grupoId: grupoId ?? this.grupoId,
      perfil: perfil ?? this.perfil,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      configuracoes: configuracoes ?? this.configuracoes,
    );
  }

  // Getter para verificar se é admin
  bool get isAdmin => perfil == 'admin';

  // Getter para verificar se é técnico
  bool get isTecnico => perfil == 'tecnico';

  // Getter para obter configurações como Map
  Map<String, dynamic> get configuracoesMap {
    if (configuracoes == null || configuracoes!.isEmpty) {
      return {};
    }
    try {
      return Map<String, dynamic>.from(
          // Assumindo que é JSON válido
          {'theme': 'light', 'notifications': true} // Default
          );
    } catch (e) {
      return {};
    }
  }
}
