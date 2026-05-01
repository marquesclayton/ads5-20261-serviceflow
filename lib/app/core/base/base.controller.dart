import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.model.dart';
import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/core/base/base.service.dart';
import 'package:serviceflow/app/core/base/base.validation.dart';
import 'package:serviceflow/app/core/mixins/loader.mixin.dart';
import 'package:serviceflow/app/core/mixins/messages.mixin.dart';

abstract class BaseController<
    E extends BaseModel,
    R extends BaseRepository<E>,
    V extends BaseValidation<E, R>,
    S extends BaseService<E, R, V>> extends StatefulWidget {
  final S service;
  final E? model;

  BaseController(this.service, {this.model});

  @override
  _BaseControllerState<E, R, V, S> createState() =>
      _BaseControllerState<E, R, V, S>();

  Widget buildPage(BuildContext context, S service);
}

class _BaseControllerState<E extends BaseModel, R extends BaseRepository<E>,
        V extends BaseValidation<E, R>, S extends BaseService<E, R, V>>
    extends State<BaseController<E, R, V, S>> with LoaderMixin, MessagesMixin {
  @override
  Widget build(BuildContext context) {
    return widget.buildPage(context, widget.service);
  }
}
