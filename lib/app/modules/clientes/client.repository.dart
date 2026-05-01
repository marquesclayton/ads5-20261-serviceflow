import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';

class ClienteRepository extends BaseRepository<Cliente> {
  ClienteRepository() : super();

  @override
  Cliente fromMap(Map<String, dynamic> map) {
    return Cliente.fromMap(map);
  }

  Future<bool> existsByEmail(String email) async {
    return await getconnection().then(
        (db) => db.exists('cliente', where: 'email = ?', whereArgs: [email]));
  }

  Future<bool> existsByNome(String nome) async {
    return await getconnection().then(
        (db) => db.exists('cliente', where: 'nome = ?', whereArgs: [nome]));
  }

  Future<bool> existsByEmailWithoutId(String email, int id) async {
    return await getconnection().then((db) => db.exists('cliente',
        where: 'email = ? AND id != ?', whereArgs: [email, id]));
  }

  Future<bool> existsByNomeWithoutId(String nome, int id) async {
    return await getconnection().then((db) => db.exists('cliente',
        where: 'nome = ? AND id != ?', whereArgs: [nome, id]));
  }
}
