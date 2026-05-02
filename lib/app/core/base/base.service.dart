import 'package:serviceflow/app/core/base/base.model.dart';
import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/core/base/base.validation.dart';

abstract class BaseService<E extends BaseModel, R extends BaseRepository<E>,
    V extends BaseValidation<E, R>> {
  final V validation;
  final R repository;

  BaseService(this.validation, this.repository);

  E cloneModelWithId(E model, int id);

  Future<E> create(E model) async {
    await validation.validateFieldCreate(model);
    await validation.validateRulesCreate(model);

    beforeCreate(model);

    final id = await repository.insert(model);
    E savedModel = cloneModelWithId(model, id);
    afterCreate(savedModel);
    return savedModel;
  }

  Future<E> update(E model) async {
    await validation.validateFieldUpdate(model);
    await validation.validateRulesUpdate(model);

    beforeUpdate(model);

    await repository.update(model);
    afterUpdate(model);
    return model;
  }

  Future<List<E>> findAll() {
    return repository.findAll();
  }

  Future<List<E>> findAllActive() {
    return repository.findAllActive();
  }

  Future<List<E>> findAllInactive() {
    return repository.findAllInactive();
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

  Future<void> delete(int id) async {
    final model = await findById(id);
    if (model != null) {
      beforeDelete(model);
      await repository.delete(id);
      afterDelete(model);
    }
  }

  Future<void> softDelete(int id) async {
    final model = await findById(id);
    if (model != null) {
      beforeDelete(model);
      await repository.softDelete(id);
      afterDelete(model);
    }
  }

  Future<void> reactivate(int id) async {
    final model = await findById(id);
    if (model != null) {
      await repository.reactivate(id);
    }
  }

  void beforeCreate(E model) {}

  void afterCreate(E savedModel) {}
  void beforeUpdate(E model) {}
  void afterUpdate(E updatedModel) {}
  void beforeDelete(E model) {}
  void afterDelete(E model) {}
}
