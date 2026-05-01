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

  void validateFieldCreate(E model) {
    validateFields(model);
    if (model.id != null && model.id! > 0) {
      throw Exception(
          "O ID não pode ser informado ou deve ser zero para criação");
    } // Validações específicas para criação (se necessário)
  }

  void validateFieldUpdate(E model) {
    validateFields(model);
    if (model.id == null || model.id! <= 0) {
      throw Exception("O ID deve ser maior que zero");
    } // Validações específicas para atualização (se necessário)
  }

  void validateRulesCreate(E model) {
    // Regras de negócio específicas para criação (se necessário)
  }

  void validateRulesUpdate(E model) {
    // Regras de negócio específicas para atualização (se necessário)
  }

  void validateRulesDelete(E model) {
    // Regras de negócio específicas para exclusão (se necessário)
  }
}
