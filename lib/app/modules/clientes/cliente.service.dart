import 'package:serviceflow/app/core/base/base.service.dart';
import 'package:serviceflow/app/modules/clientes/client.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';
import 'package:serviceflow/app/modules/clientes/cliente.validation.dart';

class ClienteService
    extends BaseService<Cliente, ClienteRepository, ClienteValidation> {
  ClienteService(ClienteValidation validation, ClienteRepository repository)
      : super(validation, repository);

  @override
  Cliente cloneModelWithId(Cliente model, int id) {
    return model.copyWith(
      id: id,
      createdAt: DateTime.now(),
    );
  }

  // Métodos específicos do domínio Cliente
  Future<List<Cliente>> findByNome(String nome) async {
    final db = await repository.getConnection();
    final result = await db.query(
      repository.tableName,
      where: 'nome LIKE ?',
      whereArgs: ['%$nome%'],
      orderBy: 'nome ASC',
    );

    return result.map((map) => Cliente.fromMap(map)).toList();
  }

  Future<Cliente?> findByEmail(String email) async {
    final db = await repository.getConnection();
    final result = await db.query(
      repository.tableName,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return Cliente.fromMap(result.first);
    }
    return null;
  }

  Future<List<Cliente>> listar() async {
    return await findAll();
  }
}
