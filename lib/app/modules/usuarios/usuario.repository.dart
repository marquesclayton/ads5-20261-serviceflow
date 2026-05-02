import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.model.dart';

class UsuarioRepository extends BaseRepository<Usuario> {
  @override
  String get tableName => 'usuarios';

  @override
  Usuario fromMap(Map<String, dynamic> map) {
    return Usuario.fromMap(map);
  }

  // Buscar por Supabase ID (UUID)
  Future<Usuario?> findBySupabaseId(String supabaseId) async {
    final db = await getConnection();
    final result = await db.query(
      tableName,
      where: 'supabase_id = ?',
      whereArgs: [supabaseId],
    );

    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    }
    return null;
  }

  // Buscar por email
  Future<Usuario?> findByEmail(String email) async {
    final db = await getConnection();
    final result = await db.query(
      tableName,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    }
    return null;
  }

  // Verificar se existe por email
  Future<bool> existsByEmail(String email) async {
    return await exists('email = ?', [email]);
  }

  // Verificar se existe por Supabase ID
  Future<bool> existsBySupabaseId(String supabaseId) async {
    return await exists('supabase_id = ?', [supabaseId]);
  }

  // Buscar usuários por grupo
  Future<List<Usuario>> findByGrupo(String grupoId) async {
    final db = await getConnection();
    final result = await db.query(
      tableName,
      where: 'grupo_id = ?',
      whereArgs: [grupoId],
      orderBy: 'nome_completo ASC',
    );

    return result.map((map) => Usuario.fromMap(map)).toList();
  }

  // Buscar usuários por perfil
  Future<List<Usuario>> findByPerfil(String perfil) async {
    final db = await getConnection();
    final result = await db.query(
      tableName,
      where: 'perfil = ?',
      whereArgs: [perfil],
      orderBy: 'nome_completo ASC',
    );

    return result.map((map) => Usuario.fromMap(map)).toList();
  }

  // Atualizar último login
  Future<void> updateUltimoLogin(
      String supabaseId, DateTime ultimoLogin) async {
    final db = await getConnection();
    await db.update(
      tableName,
      {
        'ultimo_login': ultimoLogin.toIso8601String(),
        'is_sync': 0, // Marcar para sincronizar
      },
      where: 'supabase_id = ?',
      whereArgs: [supabaseId],
    );
  }

  // Atualizar configurações do usuário
  Future<void> updateConfiguracoes(
      String supabaseId, String configuracoes) async {
    final db = await getConnection();
    await db.update(
      tableName,
      {
        'configuracoes': configuracoes,
        'is_sync': 0, // Marcar para sincronizar
      },
      where: 'supabase_id = ?',
      whereArgs: [supabaseId],
    );
  }

  // Limpar cache de usuários (logout global)
  Future<void> clearCache() async {
    final db = await getConnection();
    await db.delete(tableName);
  }

  // Inserir ou atualizar usuário (upsert)
  Future<int> upsert(Usuario usuario) async {
    final existing = await findBySupabaseId(usuario.supabaseId);

    if (existing != null) {
      // Atualizar existente
      await update(usuario.copyWith(id: existing.id));
      return existing.id!;
    } else {
      // Inserir novo
      return await insert(usuario);
    }
  }

  // Marcar todos os registros pendentes como sincronizados (para emergências)
  Future<void> markAllAsSynced() async {
    final db = await getConnection();
    await db.update(
      tableName,
      {'is_sync': 1},
      where: 'is_sync = ?',
      whereArgs: [0],
    );
  }
}
