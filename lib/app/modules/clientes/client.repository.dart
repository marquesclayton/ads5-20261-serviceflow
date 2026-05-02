import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';

class ClienteRepository extends BaseRepository<Cliente> {
  @override
  String get tableName => 'clientes';

  @override
  Cliente fromMap(Map<String, dynamic> map) {
    return Cliente.fromMap(map);
  }

  Future<bool> existsByEmail(String email) async {
    return await exists('email = ?', [email]);
  }

  Future<bool> existsByNome(String nome) async {
    return await exists('nome = ?', [nome]);
  }

  Future<bool> existsByEmailWithoutId(String email, int id) async {
    return await exists('email = ? AND id != ?', [email, id]);
  }

  Future<bool> existsByNomeWithoutId(String nome, int id) async {
    return await exists('nome = ? AND id != ?', [nome, id]);
  }
}
