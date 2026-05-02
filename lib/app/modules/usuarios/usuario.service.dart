import 'dart:convert';
import 'package:serviceflow/app/core/base/base.service.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.model.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.repository.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.validation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuarioService
    extends BaseService<Usuario, UsuarioRepository, UsuarioValidation> {
  UsuarioService(UsuarioValidation validation, UsuarioRepository repository)
      : super(validation, repository);

  @override
  Usuario cloneModelWithId(Usuario model, int id) {
    return model.copyWith(
      id: id,
      createdAt: DateTime.now(),
    );
  }

  // === OPERAÇÕES DE AUTENTICAÇÃO ===

  /// Login do usuário (Supabase + Cache local)
  Future<Usuario> login(String email, String senha) async {
    // Validar dados de login
    await validation.validateLogin(email, senha);

    try {
      // 1. Fazer login no Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: senha,
      );

      if (response.user == null) {
        throw Exception("Falha na autenticação");
      }

      // 2. Criar/atualizar usuário no cache local
      final usuario = Usuario.fromSupabase(response.user!.toJson());
      await repository.upsert(usuario);

      // 3. Atualizar último login
      await repository.updateUltimoLogin(usuario.supabaseId, DateTime.now());

      return usuario;
    } catch (e) {
      throw Exception("Erro no login: ${e.toString()}");
    }
  }

  /// Logout do usuário (Supabase + Limpar cache)
  Future<void> logout() async {
    try {
      // 1. Logout do Supabase
      await Supabase.instance.client.auth.signOut();

      // 2. Limpar cache local (opcional - manter para offline)
      // await repository.clearCache();
    } catch (e) {
      throw Exception("Erro no logout: ${e.toString()}");
    }
  }

  /// Verificar se há sessão válida
  Future<Usuario?> getUsuarioAtual() async {
    final supabaseUser = Supabase.instance.client.auth.currentUser;

    if (supabaseUser == null) {
      return null;
    }

    // Buscar no cache local primeiro (offline-first)
    Usuario? usuario = await repository.findBySupabaseId(supabaseUser.id);

    if (usuario == null) {
      // Se não encontrar localmente, criar a partir dos dados do Supabase
      usuario = Usuario.fromSupabase(supabaseUser.toJson());
      await repository.upsert(usuario);
    }

    return usuario;
  }

  // === OPERAÇÕES ESPECÍFICAS DE USUÁRIO ===

  /// Buscar usuário por email
  Future<Usuario?> findByEmail(String email) async {
    return await repository.findByEmail(email);
  }

  /// Buscar usuários por grupo
  Future<List<Usuario>> findByGrupo(String grupoId) async {
    return await repository.findByGrupo(grupoId);
  }

  /// Buscar usuários por perfil
  Future<List<Usuario>> findByPerfil(String perfil) async {
    return await repository.findByPerfil(perfil);
  }

  /// Atualizar configurações do usuário
  Future<Usuario> updateConfiguracoes(
      Usuario usuario, Map<String, dynamic> novasConfiguracoes) async {
    // Validar configurações
    validation.validateConfiguracoes(novasConfiguracoes);

    // Converter para JSON
    final configuracoes = json.encode(novasConfiguracoes);

    // Atualizar no repositório
    await repository.updateConfiguracoes(usuario.supabaseId, configuracoes);

    // Retornar usuário atualizado
    return usuario.copyWith(
      configuracoes: configuracoes,
      isSync: 0, // Marcar para sincronização
    );
  }

  /// Atualizar perfil do usuário (apenas admins podem alterar)
  Future<Usuario> updatePerfil(
      Usuario usuarioLogado, String supabaseIdAlvo, String novoPerfil) async {
    // Verificar se usuário logado é admin
    if (!usuarioLogado.isAdmin) {
      throw Exception("Apenas administradores podem alterar perfis");
    }

    // Buscar usuário alvo
    final usuarioAlvo = await repository.findBySupabaseId(supabaseIdAlvo);
    if (usuarioAlvo == null) {
      throw Exception("Usuário não encontrado");
    }

    // Validar novo perfil
    const perfisValidos = ['admin', 'tecnico', 'supervisor'];
    if (!perfisValidos.contains(novoPerfil)) {
      throw Exception("Perfil inválido");
    }

    // Atualizar usuário
    final usuarioAtualizado = usuarioAlvo.copyWith(
      perfil: novoPerfil,
      isSync: 0, // Marcar para sincronização
    );

    await update(usuarioAtualizado);
    return usuarioAtualizado;
  }

  /// Sincronizar usuários não sincronizados (Background Service)
  Future<List<Usuario>> syncPendingUsers() async {
    final usuariosPendentes = await repository.findNotSynced();
    final usuariosSincronizados = <Usuario>[];

    for (final usuario in usuariosPendentes) {
      try {
        // TODO: Implementar sync com API/Supabase
        // await _syncUserToCloud(usuario);

        // Marcar como sincronizado
        await repository.markAsSynced(usuario.id!);
        usuariosSincronizados.add(usuario);

        print("✅ Usuário ${usuario.email} sincronizado");
      } catch (e) {
        print("❌ Erro ao sincronizar usuário ${usuario.email}: $e");
      }
    }

    return usuariosSincronizados;
  }

  // === HOOKS DE CICLO DE VIDA ===

  @override
  void beforeCreate(Usuario model) {
    print("📝 Criando usuário: ${model.email}");
  }

  @override
  void afterCreate(Usuario savedModel) {
    print("✅ Usuário criado com ID: ${savedModel.id} - ${savedModel.email}");
  }

  @override
  void beforeUpdate(Usuario model) {
    print("✏️ Atualizando usuário: ${model.email}");
  }

  @override
  void afterUpdate(Usuario updatedModel) {
    print("✅ Usuário atualizado: ${updatedModel.email}");
  }

  @override
  void beforeDelete(Usuario model) {
    print("🗑️ Removendo usuário: ${model.email}");
  }

  @override
  void afterDelete(Usuario model) {
    print("✅ Usuário removido: ${model.email}");
  }

  // === MÉTODOS UTILITÁRIOS ===

  /// Obter estatísticas de usuários
  Future<Map<String, int>> getEstatisticas() async {
    final todosUsuarios = await findAll();

    return {
      'total': todosUsuarios.length,
      'admins': todosUsuarios.where((u) => u.isAdmin).length,
      'tecnicos': todosUsuarios.where((u) => u.isTecnico).length,
      'online_hoje': todosUsuarios
          .where((u) =>
              u.ultimoLogin != null &&
              DateTime.now().difference(u.ultimoLogin!).inHours < 24)
          .length,
    };
  }

  /// Verificar se é primeiro acesso (setup inicial)
  Future<bool> isPrimeiroAcesso() async {
    final usuarios = await findAll();
    return usuarios.isEmpty;
  }

  /// Criar usuário admin inicial (setup)
  Future<Usuario> criarAdminInicial(
      String email, String senha, String nomeCompleto) async {
    // Verificar se já existe algum admin
    final admins = await findByPerfil('admin');
    if (admins.isNotEmpty) {
      throw Exception("Já existe administrador no sistema");
    }

    // Cadastrar no Supabase primeiro
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: senha,
      data: {
        'nome_completo': nomeCompleto,
        'group_id': 'SF-GP-01',
        'perfil': 'admin',
      },
    );

    if (response.user == null) {
      throw Exception("Falha ao criar usuário no Supabase");
    }

    // Criar localmente
    final usuario = Usuario(
      supabaseId: response.user!.id,
      email: email,
      nomeCompleto: nomeCompleto,
      grupoId: 'SF-GP-01',
      perfil: 'admin',
      ultimoLogin: DateTime.now(),
    );

    return await create(usuario);
  }
}
