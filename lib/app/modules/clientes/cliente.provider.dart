import 'package:serviceflow/app/core/base/base.provider.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';

/// Provider para comunicação de Clientes com APIs externas
/// Exemplo de implementação seguindo BaseProvider
class ClienteProvider extends BaseProvider<Cliente> {
  @override
  String get endpoint => '/rest/v1/clientes';

  @override
  Map<String, dynamic> toExternalFormat(Cliente cliente) {
    return {
      'id': cliente.id,
      'nome': cliente.nome,
      'email': cliente.email,
      'telefone': cliente.telefone,
      'documento': cliente.documento,
      'endereco': cliente.endereco,
      'cidade': cliente.cidade,
      'estado': cliente.estado,
      'cep': cliente.cep,
      'ativo': cliente.ativo,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  Cliente fromExternalFormat(Map<String, dynamic> data) {
    return Cliente(
      id: data['id'],
      nome: data['nome'],
      email: data['email'],
      telefone: data['telefone'],
      documento: data['documento'],
      endereco: data['endereco'],
      cidade: data['cidade'],
      estado: data['estado'],
      cep: data['cep'],
      ativo: data['ativo'] ?? true,
      isSync: 1, // Dados da API estão sincronizados
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
    );
  }

  /// Validações específicas para cliente
  @override
  Future<bool> validateBeforeSync(Cliente cliente) async {
    if (cliente.nome.isEmpty ||
        cliente.email.isEmpty ||
        cliente.telefone.isEmpty) {
      handleError('validateBeforeSync', 'Dados obrigatórios faltando');
      return false;
    }

    if (!_isValidEmail(cliente.email)) {
      handleError('validateBeforeSync', 'Email inválido');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}
