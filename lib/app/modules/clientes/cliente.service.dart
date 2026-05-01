import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/editable_text.dart';
import 'package:serviceflow/app/core/base/base.service.dart';
import 'package:serviceflow/app/modules/clientes/client.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';
import 'package:serviceflow/app/modules/clientes/cliente.validation.dart';

class ClienteService
    extends BaseService<Cliente, ClienteRepository, ClienteValidation> {
  ClienteService(ClienteValidation validation, ClienteRepository repository)
      : super(validation, repository);

  Key? get formKey => null;

  TextEditingController? get nomeController => null;

  @override
  Cliente cloneModelWthiId(Cliente model, int id) {
    return Cliente(
      id: id,
      createdAt: model.createdAt,
      nome: model.nome,
      email: model.email,
      telefone: model.telefone,
    );
  }
}
