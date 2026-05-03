import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.model.dart';
import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/core/base/base.service.dart';
import 'package:serviceflow/app/core/base/base.validation.dart';
import 'package:serviceflow/app/core/mixins/loader.mixin.dart';
import 'package:serviceflow/app/core/mixins/messages.mixin.dart';

/// BaseController abstrato que fornece estrutura padronizada para controllers
///
/// Automaticamente inclui LoaderMixin e MessagesMixin para todas as subclasses
/// Subclasses podem chamar diretamente: showLoading(), showSuccess(), withLoading(), etc.
abstract class BaseController<E extends BaseModel, R extends BaseRepository<E>,
        V extends BaseValidation<E, R>, S extends BaseService<E, R, V>>
    extends StatelessWidget with LoaderMixin, MessagesMixin {
  final S service;
  final E? model;

  BaseController(this.service, {this.model});

  /// Método abstrato que deve ser implementado pelas subclasses
  /// Subclasses têm acesso direto aos mixins através da herança
  Widget buildPage(BuildContext context, S service);

  @override
  Widget build(BuildContext context) {
    return buildPage(context, service);
  }

  /// Executa operação com loading automático e tratamento completo de exceções
  /// - Mostra loading automaticamente
  /// - Remove loading em caso de sucesso ou erro
  /// - Mostra mensagem de sucesso se especificada
  /// - Mostra mensagem de erro automaticamente para qualquer exceção
  Future<T?> executeOperation<T>(
    BuildContext context,
    Future<T> operation, {
    String? loadingMessage,
    String? successMessage,
    bool showSuccessMessage = false,
  }) async {
    try {
      showLoading(context, message: loadingMessage ?? 'Processando...');
      final result = await operation;
      
      // Remove loading em caso de sucesso
      hideLoading(context);
      
      // Mostra mensagem de sucesso se solicitado
      if (showSuccessMessage && successMessage != null) {
        showSuccess(context, successMessage);
      }
      
      return result;
    } catch (e) {
      // Remove loading em caso de erro
      hideLoading(context);
      
      // Converte todas as exceções para mensagem de erro
      _handleException(context, e);
      
      return null;
    }
  }

  /// Executa operação de listagem com tratamento completo
  Future<List<T>> executeListOperation<T>(
    BuildContext context,
    Future<List<T>> operation, {
    String? loadingMessage,
    String? errorMessage,
  }) async {
    try {
      showLoading(context, message: loadingMessage ?? 'Carregando...');
      final result = await operation;
      
      hideLoading(context);
      return result;
    } catch (e) {
      hideLoading(context);
      _handleException(context, e, customMessage: errorMessage);
      return [];
    }
  }

  /// Executa operação CRUD com confirmação prévia e feedback completo
  Future<bool> executeCrudOperation(
    BuildContext context,
    Future<void> operation, {
    String? confirmTitle,
    String? confirmMessage,
    String? loadingMessage,
    String? successMessage,
    bool requiresConfirmation = false,
  }) async {
    // Se requer confirmação, mostra dialog primeiro
    if (requiresConfirmation) {
      final confirmed = await showConfirmation(
        context,
        confirmTitle ?? 'Confirmar Operação',
        confirmMessage ?? 'Tem certeza que deseja continuar?',
      );
      
      if (confirmed != true) return false;
    }

    try {
      showLoading(context, message: loadingMessage ?? 'Processando...');
      await operation;
      
      hideLoading(context);
      
      if (successMessage != null) {
        showSuccess(context, successMessage);
      }
      
      return true;
    } catch (e) {
      hideLoading(context);
      _handleException(context, e);
      return false;
    }
  }

  /// Tratamento centralizado de todas as exceções
  /// Converte exceções de Repository, Validation, Service e bibliotecas em mensagens de erro
  void _handleException(BuildContext context, dynamic exception, {String? customMessage}) {
    String errorMessage;
    String? errorDetails;

    if (exception is FormatException) {
      errorMessage = 'Erro de formato de dados';
      errorDetails = exception.message;
    } else if (exception is ArgumentError) {
      errorMessage = 'Parâmetro inválido';
      errorDetails = exception.message.toString();
    } else if (exception is StateError) {
      errorMessage = 'Erro de estado da aplicação';
      errorDetails = exception.message;
    } else if (exception is TypeError) {
      errorMessage = 'Erro de tipo de dados';
      errorDetails = exception.toString();
    } else if (exception.toString().contains('SQL') || 
               exception.toString().contains('database') ||
               exception.toString().contains('sqlite')) {
      errorMessage = 'Erro no banco de dados';
      errorDetails = exception.toString();
    } else if (exception.toString().contains('HTTP') ||
               exception.toString().contains('Connection') ||
               exception.toString().contains('network')) {
      errorMessage = 'Erro de conexão com servidor';
      errorDetails = exception.toString();
    } else if (exception.toString().contains('validation') ||
               exception.toString().contains('Validation')) {
      errorMessage = 'Erro de validação';
      errorDetails = exception.toString();
    } else {
      // Exceção genérica - usa mensagem personalizada se fornecida
      errorMessage = customMessage ?? 'Ocorreu um erro inesperado';
      errorDetails = exception.toString();
    }

    // Mostra mensagem de erro que permanece até usuário fechar
    showError(context, errorMessage, details: errorDetails);
  }
}
