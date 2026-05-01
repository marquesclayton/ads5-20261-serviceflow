import 'package:serviceflow/app/core/base/base.model.dart';
import 'package:serviceflow/app/core/base/sqlite/dp.helper.dart';

abstract class BaseRepository<E extends BaseModel> {
  final _dbHelper = DbHelper.instance;

  getconnection() async {
    return await _dbHelper.database;
  }

  // Criar (Create)
  Future<int> insert(E model) async {
    final db = await _dbHelper.database;
    return await db.insert('ordens_servico', model.toMap());
  }

  // Atualizar (Update)
  Future<int> update(E model) async {
    final db = await _dbHelper.database;
    return await db.update(
      'ordens_servico',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  // Ler Todos (Read)
  Future<List<E>> findAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result =
        await db.query('ordens_servico', orderBy: 'id DESC');

    return result.map((map) => fromMap(map)).toList();
  }

  // Buscar por ID
  Future<E?> findById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'ordens_servico',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return fromMap(result.first);
    }
    return null;
  }

  E fromMap(Map<String, dynamic> map);
}
