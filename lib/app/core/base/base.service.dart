import 'package:serviceflow/app/core/base/base.model.dart';
import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/core/base/base.validation.dart';

abstract class BaseService<E extends BaseModel, R extends BaseRepository<E>,
    V extends BaseValidation<E, R>> {
  final V validation;
  final R repository;

  BaseService(this.validation, this.repository);

  E cloneModelWthiId(E model, int id);

  Future<E> create(E model) async {
    validation.validateFieldCreate(model);
    validation.validateRulesCreate(model);

    beforeCreate(model);

    return repository.insert(model).then((id) {
      E savedModel = cloneModelWthiId(model, id);
      afterCreate(savedModel);
      return savedModel;
    });
  }

  Future<E> update(E model) {
    validation.validateFieldUpdate(model);
    validation.validateRulesUpdate(model);

    beforeUpdate(model);

    return repository.update(model).then((_) {
      afterUpdate(model);
      return model;
    });
  }

  Future<List<E>> findAll() {
    return repository.findAll();
  }

  Future<E?> findById(int id) {
    return repository.findById(id).then((model) {
      if (model != null) {
        return model;
      } else {
        throw Exception("Registro com ID $id não encontrado");
      }
    });
  }

  void beforeCreate(E model) {}

  void afterCreate(E savedModel) {}
  void beforeUpdate(E model) {}
  void afterUpdate(E updatedModel) {}
  void beforeDelete(E model) {}
  void afterDelete(E model) {}
}
