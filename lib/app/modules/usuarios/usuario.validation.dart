import 'package:serviceflow/app/core/base/base.validation.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.model.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.repository.dart';

class UsuarioValidation extends BaseValidation<Usuario, UsuarioRepository> {
  UsuarioValidation(UsuarioRepository repository) : super(repository);

  @override
  void validateFields(Usuario? model) {
    if (model == null) {
      throw Exception("O usuário não pode ser nulo");
    }

    // Validar campos obrigatórios
    if (model.supabaseId.trim().isEmpty) {
      throw Exception("O ID do Supabase é obrigatório");
    }

    if (model.email.trim().isEmpty) {
      throw Exception("O email do usuário é obrigatório");
    }

    if (model.nomeCompleto.trim().isEmpty) {
      throw Exception("O nome completo do usuário é obrigatório");
    }

    if (model.grupoId.trim().isEmpty) {
      throw Exception("O grupo do usuário é obrigatório");
    }

    // Validar formato do email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(model.email)) {
      throw Exception("O email do usuário é inválido");
    }

    // Validar formato do Supabase ID (UUID)
    if (!RegExp(
            r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$')
        .hasMatch(model.supabaseId)) {
      throw Exception("O ID do Supabase deve ser um UUID válido");
    }

    // Validar perfil
    const perfisValidos = ['admin', 'tecnico', 'supervisor'];
    if (!perfisValidos.contains(model.perfil.toLowerCase())) {
      throw Exception("O perfil deve ser: ${perfisValidos.join(', ')}");
    }

    // Validar nome completo (mínimo 2 partes)
    if (model.nomeCompleto.split(' ').length < 2) {
      throw Exception("O nome completo deve ter pelo menos nome e sobrenome");
    }
  }

  @override
  Future<void> validateRulesCreate(Usuario model) async {
    // Regras de negócio para criação

    // Verificar se já existe usuário com mesmo email
    bool emailExists = await repository.existsByEmail(model.email);
    if (emailExists) {
      throw Exception("Já existe um usuário com este email");
    }

    // Verificar se já existe usuário com mesmo Supabase ID
    bool supabaseIdExists =
        await repository.existsBySupabaseId(model.supabaseId);
    if (supabaseIdExists) {
      throw Exception("Já existe um usuário com este ID do Supabase");
    }

    // Validar grupo específico do projeto
    if (!model.grupoId.startsWith('SF-GP-')) {
      throw Exception("O grupo deve seguir o padrão SF-GP-XX");
    }
  }

  @override
  Future<void> validateRulesUpdate(Usuario model) async {
    // Regras de negócio para atualização

    if (model.id == null) {
      throw Exception("ID é obrigatório para atualização");
    }

    // Verificar se existe outro usuário com mesmo email
    final existingUser = await repository.findByEmail(model.email);
    if (existingUser != null && existingUser.id != model.id) {
      throw Exception("Já existe outro usuário com este email");
    }

    // Não permitir alterar Supabase ID após criação
    final currentUser = await repository.findById(model.id!);
    if (currentUser != null && currentUser.supabaseId != model.supabaseId) {
      throw Exception("Não é possível alterar o ID do Supabase após criação");
    }
  }

  @override
  Future<void> validateRulesDelete(Usuario model) async {
    // Regras de negócio para exclusão

    if (model.id == null) {
      throw Exception("ID é obrigatório para exclusão");
    }

    // Não permitir deletar admin se for o único
    if (model.isAdmin) {
      final admins = await repository.findByPerfil('admin');
      if (admins.length <= 1) {
        throw Exception(
            "Não é possível excluir o último administrador do sistema");
      }
    }

    // Verificar se usuário tem ordens de serviço vinculadas
    // TODO: Implementar verificação quando criar o módulo de OS
    // final osRepository = OrdemServicoRepository();
    // final osVinculadas = await osRepository.findByUsuarioId(model.id!);
    // if (osVinculadas.isNotEmpty) {
    //   throw Exception("Não é possível excluir usuário com ordens de serviço vinculadas");
    // }
  }

  // Validação específica para login
  Future<void> validateLogin(String email, String senha) async {
    if (email.trim().isEmpty) {
      throw Exception("Email é obrigatório para login");
    }

    if (senha.trim().isEmpty) {
      throw Exception("Senha é obrigatória para login");
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw Exception("Email inválido");
    }

    if (senha.length < 6) {
      throw Exception("Senha deve ter pelo menos 6 caracteres");
    }
  }

  // Validação para alteração de configurações
  void validateConfiguracoes(Map<String, dynamic> configuracoes) {
    if (configuracoes.isEmpty) {
      return; // Configurações vazias são válidas
    }

    // Validar estrutura básica das configurações
    const configsValidas = ['theme', 'notifications', 'auto_sync', 'language'];

    for (final key in configuracoes.keys) {
      if (!configsValidas.contains(key)) {
        throw Exception("Configuração '$key' não é válida");
      }
    }

    // Validar valores específicos
    if (configuracoes.containsKey('theme')) {
      const temasValidos = ['light', 'dark', 'auto'];
      if (!temasValidos.contains(configuracoes['theme'])) {
        throw Exception("Tema deve ser: ${temasValidos.join(', ')}");
      }
    }

    if (configuracoes.containsKey('language')) {
      const idiomasValidos = ['pt-BR', 'en-US', 'es-ES'];
      if (!idiomasValidos.contains(configuracoes['language'])) {
        throw Exception("Idioma deve ser: ${idiomasValidos.join(', ')}");
      }
    }
  }
}
