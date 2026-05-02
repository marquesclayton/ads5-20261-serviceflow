import 'package:serviceflow/app/core/base/base.validation.dart';
import 'package:serviceflow/app/modules/clientes/client.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';

class ClienteValidation extends BaseValidation<Cliente, ClienteRepository> {
  ClienteValidation(ClienteRepository repository) : super(repository);

  @override
  void validateFields(Cliente? model) {
    if (model == null || model.nome.trim().isEmpty) {
      throw Exception("O nome do cliente é obrigatório");
    }
    if (model.email.trim().isEmpty) {
      throw Exception("O email do cliente é obrigatório");
    }
    if (model.telefone.trim().isEmpty) {
      throw Exception("O telefone do cliente é obrigatório");
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(model.email)) {
      throw Exception("O email do cliente é inválido");
    }
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(model.telefone)) {
      throw Exception("O telefone do cliente é inválido");
    }
  }

  @override
  Future<void> validateRulesCreate(Cliente model) async {
    // Regras de negócio específicas para criação
    bool emailExists = await repository.existsByEmail(model.email);
    if (emailExists) {
      throw Exception("Já existe um cliente com este email");
    }

    bool nomeExists = await repository.existsByNome(model.nome);
    if (nomeExists) {
      throw Exception("Já existe um cliente com este nome");
    }
  }

  @override
  Future<void> validateRulesUpdate(Cliente model) async {
    // Regras de negócio específicas para atualização
    if (await repository.existsByEmailWithoutId(model.email, model.id!)) {
      throw Exception("Já existe um cliente com este email");
    }

    if (await repository.existsByNomeWithoutId(model.nome, model.id!)) {
      throw Exception("Já existe um cliente com este nome");
    }
  }
}
