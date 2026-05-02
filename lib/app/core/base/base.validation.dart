import 'package:serviceflow/app/core/base/base.model.dart';
import 'package:serviceflow/app/core/base/base.repository.dart';

abstract class BaseValidation<E extends BaseModel,
    R extends BaseRepository<E>> {
  final R repository;

  BaseValidation(this.repository);

  void validateFields(E? model) {
    if (model == null) {
      throw Exception("O modelo não pode ser nulo");
    }
  }

  Future<void> validateFieldCreate(E model) async {
    validateFields(model);
    if (model.id != null && model.id! > 0) {
      throw Exception(
          "O ID não pode ser informado ou deve ser zero para criação");
    }
    // Validações específicas para criação (se necessário)
  }

  Future<void> validateFieldUpdate(E model) async {
    validateFields(model);
    if (model.id == null || model.id! <= 0) {
      throw Exception("O ID deve ser maior que zero");
    }
    // Validações específicas para atualização (se necessário)
  }

  Future<void> validateRulesCreate(E model) async {
    // Regras de negócio específicas para criação (implementar nas classes filhas)
  }

  Future<void> validateRulesUpdate(E model) async {
    // Regras de negócio específicas para atualização (implementar nas classes filhas)
  }

  Future<void> validateRulesDelete(E model) async {
    // Regras de negócio específicas para exclusão (implementar nas classes filhas)
  }
}
