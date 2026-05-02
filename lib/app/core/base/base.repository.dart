import 'package:serviceflow/app/core/base/base.model.dart';
import 'package:serviceflow/app/core/helpers/database_helper.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseRepository<E extends BaseModel> {
  final _dbHelper = DbHelper.instance;

  // Cada repositório específico deve definir sua tabela
  String get tableName;

  Future<Database> getConnection() async {
    return await _dbHelper.database;
  }

  // Criar (Create)
  Future<int> insert(E model) async {
    final db = await _dbHelper.database;
    return await db.insert(tableName, model.toMap());
  }

  // Atualizar (Update)
  Future<int> update(E model) async {
    final db = await _dbHelper.database;
    return await db.update(
      tableName,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  // Ler Todos (Read)
  Future<List<E>> findAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result =
        await db.query(tableName, orderBy: 'id DESC');

    return result.map((map) => fromMap(map)).toList();
  }

  // Buscar apenas registros ativos
  Future<List<E>> findAllActive() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'ativo = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );

    return result.map((map) => fromMap(map)).toList();
  }

  // Buscar apenas registros inativos
  Future<List<E>> findAllInactive() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'ativo = ?',
      whereArgs: [0],
      orderBy: 'id DESC',
    );

    return result.map((map) => fromMap(map)).toList();
  }

  // Buscar por ID
  Future<E?> findById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return fromMap(result.first);
    }
    return null;
  }

  // Buscar registros não sincronizados (offline-first)
  Future<List<E>> findNotSynced() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      tableName,
      where: 'is_sync = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );

    return result.map((map) => fromMap(map)).toList();
  }

  // Marcar como sincronizado
  Future<void> markAsSynced(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      tableName,
      {'is_sync': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Buscar todas as entidades com sincronização pendente
  Future<List<E>> findAllPendingSync() async {
    final db = await getConnection();
    final result = await db.query(
      tableName,
      where: 'is_sync = ? AND ativo = ?',
      whereArgs: [0, 1],
    );
    return result.map((map) => fromMap(map)).toList();
  }

  // Deletar (Delete)
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Soft Delete - Marcar como inativo
  Future<int> softDelete(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      tableName,
      {
        'ativo': 0,
        'is_sync': 0
      }, // Marca como inativo e pendente de sincronização
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Reativar registro
  Future<int> reactivate(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      tableName,
      {
        'ativo': 1,
        'is_sync': 0
      }, // Marca como ativo e pendente de sincronização
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Verificar se existe registro com condição específica
  Future<bool> exists(String whereClause, List<dynamic> whereArgs) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      tableName,
      columns: ['COUNT(*) as count'],
      where: whereClause,
      whereArgs: whereArgs,
    );

    final count = result.first['count'] as int;
    return count > 0;
  }

  // Método abstrato que cada repositório deve implementar
  E fromMap(Map<String, dynamic> map);
}
